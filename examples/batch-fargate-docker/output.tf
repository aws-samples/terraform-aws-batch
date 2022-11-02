
output "repository_url" {
  description = "The ECR image URI for deploying lambda"
  value       = module.batch_fargate.repository_url
}

output "repository_arn" {
  description = "The ECR image URI for deploying lambda"
  value       = module.batch_fargate.repository_arn
}

# Log Group
output "aws_cloudwatch_log_group_arn" {
  description = "Batch log group ARN"
  value       = module.batch_fargate.aws_cloudwatch_log_group_arn
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role arn"
  value       = module.batch_fargate.ecs_task_execution_role_arn
}

output "batch_job_definition_arn" {
  description = "Batch job definition arn"
  value       = module.batch_fargate.batch_job_definition_arn
}

output "compute_environment_ecs_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the underlying Amazon ECS cluster used by the compute environment."
  value       = module.batch_fargate.compute_environment_ecs_cluster_arn
}

output "compute_environment_arn" {
  description = "Batch compute environment arn"
  value       = module.batch_fargate.compute_environment_arn
}

output "compute_environment_status" {
  description = "Batch compute environment sataus"
  value       = module.batch_fargate.compute_environment_status
}

output "job_queue_arn" {
  description = "Batch job queue arn"
  value       = module.batch_fargate.job_queue_arn

}