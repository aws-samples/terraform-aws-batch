provider "aws" {
  region = var.region
}

module "batch_fargate" {
  source = "../../modules/batch-fargate-docker"

  app         = var.app
  component   = var.component
  environment = var.environment
  image_tag   = var.image_tag

  docker_source_path = var.docker_source_path
  docker_file_path   = var.docker_file_path
  docker_build_args  = var.docker_build_args

  ecr_lifecycle_image_days = var.ecr_lifecycle_image_days

  ecr_repository_name      = var.ecr_repository_name
  ecr_image_tag_mutability = var.ecr_image_tag_mutability
  ecr_scan_on_push         = var.ecr_scan_on_push
  ecr_encryption_type      = var.ecr_encryption_type

  log_group_retention_in_days = var.log_group_retention_in_days
  log_group_kms_key_arn       = var.log_group_kms_key_arn

  job_definition_propagate_tags        = var.job_definition_propagate_tags
  job_definition_command               = var.job_definition_command
  job_definition_vcpu                  = var.job_definition_vcpu
  job_definition_memory                = var.job_definition_memory
  job_definition_platform_version      = var.job_definition_platform_version
  job_definition_environment_variables = var.job_definition_environment_variables

  compute_resource_security_groups = var.compute_resource_security_groups
  compute_resource_subnet_ids      = var.compute_resource_subnet_ids
  compute_resource_type            = var.compute_resource_type
  compute_resource_max_vcpus       = var.compute_resource_max_vcpus

  job_queue_state                 = var.job_queue_state
  job_queue_scheduling_policy_arn = var.job_queue_scheduling_policy_arn
  job_queue_priority              = var.job_queue_priority

  event_rule_schedule_expression = var.event_rule_schedule_expression
  event_rule_is_enabled          = var.event_rule_is_enabled
}