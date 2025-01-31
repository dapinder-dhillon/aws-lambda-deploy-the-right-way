data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda_file_distribution"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "file_distribution_function" {
  function_name = join("-", [
    var.file_distribution_lambda_name,
  var.environment])
  filename         = "lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn
  description      = "TDMP AWS File distribution lambda"
  handler          = "file_distribution_lambda.lambda_handler"
  runtime          = var.runtime
  timeout          = 30
  layers = [
  data.aws_lambda_layer_version.file_distribution_function_dependencies.arn]
  environment {
    variables = {
      TARGET_SNS_TOPIC  = var.lambda_s3_sns_name
      ENVIRONMENT       = var.environment
      SLACK_WEBHOOK_SSM = aws_ssm_parameter.alerts_slack_token.value
    }
  }
  tags = merge(local.common_tags, {
    "Name" = join("-", [
      var.file_distribution_lambda_name,
    var.environment]), "Description" = "TDMP AWS File distribution lambda."
  })

}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_distribution_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.lambda_input_bucket.arn
}
