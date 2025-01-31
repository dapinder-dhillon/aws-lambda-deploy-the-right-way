resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.lambda_input_bucket.id

  lambda_function {
    id = join("-", [
      var.file_distribution_lambda_name,
    var.environment])
    lambda_function_arn = aws_lambda_function.file_distribution_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
