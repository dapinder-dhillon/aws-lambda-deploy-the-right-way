data "aws_lambda_layer_version" "file_distribution_function_dependencies" {
  layer_name = "${var.file_distribution_lambda_name}-dependencies-${var.aws_account_env}"
}

data "aws_s3_bucket" "lambda_input_bucket" {
  bucket = var.lambda_s3_sns_name
}

data "aws_sns_topic" "lambda_input_sns_tpic" {
  name = var.lambda_s3_sns_name
}
