
output "repository_url" {
  description = "The ECR image URI for deploying lambda"
  value       = aws_ecr_repository.compute_image.repository_url
}

output "repository_arn" {
  description = "The ECR image URI for deploying lambda"
  value       = aws_ecr_repository.compute_image.arn
}

# Log Group
output "aws_cloudwatch_log_group_arn" {
  description = "Batch log group ARN"
  value       = aws_cloudwatch_log_group.batch_log_group.arn
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role arn"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "batch_job_definition_arn" {
  description = "Batch job definition arn"
  value       = aws_batch_job_definition.batch_job_definition.arn
}

output "compute_environment_arn" {
  description = "Batch compute environment arn"
  value       = aws_batch_compute_environment.compute_environment.ecs_cluster_arn
}

output "compute_environment_ecs_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the underlying Amazon ECS cluster used by the compute environment."
  value       = aws_batch_compute_environment.compute_environment.arn
}

output "compute_environment_status" {
  description = "Batch compute environment sataus"
  value       = aws_batch_compute_environment.compute_environment.status
}

output "job_queue_arn" {
  description = "Batch job queue arn"
  value       = aws_batch_job_queue.job_queue.arn

}