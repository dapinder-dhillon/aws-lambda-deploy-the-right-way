resource "aws_cloudwatch_log_group" "lambda_cloudwatch_log_group" {
  name              = format("/aws/lambda/${var.file_distribution_lambda_name}-%s", var.environment)
  retention_in_days = var.cw_log_retention_days
}
