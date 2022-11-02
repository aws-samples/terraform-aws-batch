region = "us-east-1"

app         = "Perseverance"
component   = "import-moon-lander"
environment = "dev"
image_tag   = "latest"

docker_source_path = "src"
docker_file_path   = "Dockerfile"
docker_build_args  = {}

ecr_lifecycle_image_days = 8

ecr_repository_name      = "test-batch-job"
ecr_image_tag_mutability = "MUTABLE"
ecr_scan_on_push         = true
ecr_encryption_type      = "AES256"

log_group_retention_in_days = 30
log_group_kms_key_arn       = null

job_definition_propagate_tags        = false
job_definition_command               = ["echo", "test"]
job_definition_vcpu                  = 0.25
job_definition_memory                = 512
job_definition_platform_version      = "LATEST"
job_definition_environment_variables = [{ "name" : "MISSION-MARS", "value" : "THis is good" }, { "name" : "TEST", "value" : "beta" }]

compute_resource_security_groups = ["sg-5dabba1f"]
compute_resource_subnet_ids      = ["subnet-9a3556c6"]
compute_resource_type            = "FARGATE"
compute_resource_max_vcpus       = 16

job_queue_state                 = "ENABLED"
job_queue_scheduling_policy_arn = null
job_queue_priority              = 1

event_rule_schedule_expression = "cron(0 20 * * ? *)"
event_rule_is_enabled          = true