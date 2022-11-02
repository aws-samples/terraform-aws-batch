data "aws_region" "current" {}

data "aws_caller_identity" "this" {}

data "aws_ecr_authorization_token" "token" {}

locals {
  account_id     = data.aws_caller_identity.this.account_id
  ecr_address    = format("%v.dkr.ecr.%v.amazonaws.com", local.account_id, data.aws_region.current.name)
  ecr_repo       = aws_ecr_repository.compute_image.id
  image_tag      = coalesce(var.image_tag, formatdate("YYYYMMDDhhmmss", timestamp()))
  ecr_image_name = format("%v/%v:%v", local.ecr_address, local.ecr_repo, local.image_tag)
}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "docker_registry_image" "build_image" {
  name = local.ecr_image_name

  build {
    context    = var.docker_source_path
    dockerfile = var.docker_file_path
    build_args = var.docker_build_args
  }
}

resource "aws_ecr_repository" "compute_image" {
  name                 = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }
  encryption_configuration {
    encryption_type = var.ecr_encryption_type
  }
  tags = {
    app         = var.app
    component   = var.component
    environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = aws_ecr_repository.compute_image.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Only keep ${var.ecr_lifecycle_image_days} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.ecr_lifecycle_image_days}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_cloudwatch_log_group" "batch_log_group" {
  name              = "/aws/batch/${var.app}/${var.component}/${var.environment}"
  retention_in_days = var.log_group_retention_in_days
  kms_key_id    = var.log_group_kms_key_arn
}

resource "aws_iam_role" "batch_service_role" {
  name = "batch-service-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "batch.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"]
  tags = {
    app         = var.app
    component   = var.component
    environment = var.environment
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_instance_role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy","arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess","arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
}

resource "aws_batch_job_definition" "batch_job_definition" {
  name           = "${var.component}-${var.environment}-${var.app}"
  type           = "container"
  propagate_tags = var.job_definition_propagate_tags
  platform_capabilities = [
    "FARGATE",
  ]
  container_properties = jsonencode({
    command = var.job_definition_command
    image = local.ecr_image_name
    resourceRequirements = [
      {
        type = "VCPU"
        value = "${tostring(var.job_definition_vcpu)}"
      },
      {
        type = "MEMORY"
        value = "${tostring(var.job_definition_memory)}"
      }
    ]
    fargatePlatformConfiguration = {
      platformVersion = var.job_definition_platform_version
    }
    networkConfiguration = {
      assignPublicIp = "ENABLED"
    }
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group = aws_cloudwatch_log_group.batch_log_group.name
        awslogs-region = data.aws_region.current.name
      }
    }
    executionRoleArn = aws_iam_role.ecs_task_execution_role.arn
    environment = var.job_definition_environment_variables
  })
#   container_properties = <<CONTAINER_PROPERTIES
# {
#   "command": ${jsonencode(var.command)}, 
#   "image": "${local.ecr_image_name}",
#   "fargatePlatformConfiguration": {
#     "platformVersion": "${var.platform_version}"
#   },
#   "resourceRequirements": [
#     {"type": "VCPU", "value": "${var.vcpu}"},
#     {"type": "MEMORY", "value": "${var.mem}"}
#   ],
#   "logConfiguration":{
#     "logDriver": "awslogs",
#     "options": {
#       "awslogs-group": "${aws_cloudwatch_log_group.batch_log_group.name}",
#       "awslogs-region": "${data.aws_region.current.name}"
#     }
#   },
#   "environment": ${jsonencode(var.environment_variables)},
#   "executionRoleArn": "${aws_iam_role.ecs_task_execution_role.arn}"
# }
# CONTAINER_PROPERTIES 
  tags = {
    app         = var.app
    component   = var.component
    environment = var.environment
  }
}

resource "aws_batch_compute_environment" "compute_environment" {
  compute_environment_name = "${var.component}-${var.environment}-${var.app}"
  type                     = "MANAGED"
  compute_resources {
    subnets            = var.compute_resource_subnet_ids
    security_group_ids = var.compute_resource_security_groups
    type               = var.compute_resource_type
    max_vcpus          = var.compute_resource_max_vcpus
  }
  service_role = aws_iam_role.batch_service_role.arn
  tags = {
    app         = var.app
    component   = var.component
    environment = var.environment
  }
  depends_on = [aws_iam_role.batch_service_role]
}

resource "aws_batch_job_queue" "job_queue" {
  name                  = "${var.component}-${var.environment}-${var.app}"
  state                 = var.job_queue_state
  priority              = var.job_queue_priority
  scheduling_policy_arn = var.job_queue_scheduling_policy_arn
  compute_environments = [
    aws_batch_compute_environment.compute_environment.arn
  ]
  tags = {
    app         = var.app
    component   = var.component
    environment = var.environment
  }
}

resource "aws_iam_role" "event_rule_batch_execution_role" {
  name = "event_rule_batch-execution-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSBatchServiceEventTargetRole"]
  tags = {
    app         = var.app
    component   = var.component
    environment = var.environment
  }
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name = "${var.component}-${var.environment}-${var.app}"
  description = "Event Rule to trigger batch job"
  schedule_expression = var.event_rule_schedule_expression
  role_arn = aws_iam_role.event_rule_batch_execution_role.arn
  is_enabled = var.event_rule_is_enabled
  tags = {
    app         = var.app
    component   = var.component
    environment = var.environment
  }
}

resource "aws_cloudwatch_event_target" "batch_event_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "Batch"
  role_arn = aws_iam_role.event_rule_batch_execution_role.arn
  arn = aws_batch_job_queue.job_queue.arn
  batch_target {
    job_definition = aws_batch_job_definition.batch_job_definition.arn
    job_name = "${var.component}-${var.environment}-${var.app}"
  }
}

