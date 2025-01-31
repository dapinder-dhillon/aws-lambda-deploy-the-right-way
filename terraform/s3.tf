resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = data.aws_s3_bucket.lambda_input_bucket.id

  lambda_function {
    id = join("-", [
      var.create_s3_presigned_url_lambda_name,
    var.environment])
    lambda_function_arn = aws_lambda_function.create_s3_presigned_url_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
