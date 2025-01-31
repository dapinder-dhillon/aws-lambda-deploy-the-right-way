resource "aws_ssm_parameter" "alerts_slack_token" {
  name = join("-", [
    var.create_s3_presigned_url_lambda_name,
    var.environment,
  "slack-token"])
  description = "Slack API token, for the slack."
  type        = "SecureString"
  value       = "VALUE_NOT_SET"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }
  tags = local.common_tags
}
