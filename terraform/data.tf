data "aws_lambda_layer_version" "create_s3_presigned_url_lambda_dependencies" {
  layer_name = "${var.create_s3_presigned_url_lambda_name}-dependencies-${var.aws_account_env}"
}

data "aws_s3_bucket" "lambda_input_bucket" {
  bucket = var.lambda_s3_sns_name
}

data "aws_sns_topic" "lambda_input_sns_tpic" {
  name = var.lambda_s3_sns_name
}
