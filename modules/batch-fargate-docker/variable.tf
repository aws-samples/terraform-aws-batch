variable "app" {
  description = "Value for the app tag"
  type        = string
  default     = "mooon-lander"
}

variable "component" {
  description = "Value for component tag"
  type        = string
  default     = "import-moon-lander"
}

variable "environment" {
  description = "Environment to be used e.g dev/prod/stage "
  type        = string
  default     = "dev"
}

variable "docker_source_path" {
  description = "Path to folder containing application code"
  type        = string
  default     = null
}

variable "docker_file_path" {
  description = "Path to Dockerfile in source package"
  type        = string
  default     = "Dockerfile"
}

variable "docker_build_args" {
  description = "A map of Docker build arguments."
  type        = map(string)
  default     = {}
}

variable "ecr_lifecycle_image_days" {
  description = "The value is the maximum number of images that you want to retain in your repository."
  type        = number
  default     = 8
}

variable "image_tag" {
  description = "Image tag to use. If not provided date will be used"
  type        = string
  default     = "latest"
}

variable "ecr_repository_name" {
  description = "Name of the ECR registory to use"
  type        = string
}

variable "ecr_image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`"
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "The encryption type to use for the repository. Valid values are AES256 or KMS"
  type        = string
  default     = "AES256"
}

variable "log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = 30
}

variable "log_group_kms_key_arn" {
  description = "The ARN of the KMS Key to use when encrypting log data."
  type        = string
  default = null
}

variable "job_definition_propagate_tags" {
  description = "Specifies whether to propagate the tags from the job definition to the corresponding Amazon ECS task."
  type        = bool
  default     = false
}

variable "job_definition_command" {
  description = "The command that's passed to the container."
  type        = list(any)
}

variable "job_definition_vcpu" {
  description = "Amount of cpu to assign to a container. Possible values 0.25, 0.5, 1, 2, 4"
  type        = number
  default     = 0.25
}

variable "job_definition_memory" {
  description = "Amount of memory to assign to a container. https://docs.aws.amazon.com/batch/latest/userguide/job_definition_parameters.html#ContainerProperties-resourceRequirements-Fargate-memory-vcpu"
  type        = number
  default     = 512
}

variable "job_definition_platform_version" {
  description = "Specify the Fargate platform version. Possible values for platformVersion are 1.3.0, 1.4.0, and LATEST."
  type        = string
  default     = "LATEST"
}

variable "job_definition_environment_variables" {
  description = "List of environemnt variables to be passed onto container."
  default = null
}

variable "compute_resource_type" {
  description = "This must be either FARGATE or FARGATE_SPOT."
  type        = string
  default = "FARGATE"
}

variable "compute_resource_max_vcpus" {
  description = "The maximum number of EC2 vCPUs that an environment can reach."
  type        = number
  default = 16
}

variable "compute_resource_subnet_ids" {
  description = "List of subnet ids for aws batch compute environment."
  type        = list(string)
  default     = null
}

variable "compute_resource_security_groups" {
  description = "List of security groups for aws batch compute environment."
  type        = list(string)
  default     = null
}

variable "job_queue_state" {
  description = "The state of the job queue. Must be one of: ENABLED or DISABLED"
  type        = string
  default     = "ENABLED"
}

variable "job_queue_priority" {
  description = "The priority of the job queue"
  type        = number
  default     = 1
}

variable "job_queue_scheduling_policy_arn" {
  description = "The ARN of the fair share scheduling policy. If this parameter isn't specified, the job queue uses a first in, first out (FIFO) scheduling policy."
  type        = string
  default     = null
}

variable "event_rule_schedule_expression" {
  description = "The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)."
  default = "cron(0 20 * * ? *)"
}

variable "event_rule_is_enabled" {
  description = "Whether the rule should be enabled"
  default = true
}