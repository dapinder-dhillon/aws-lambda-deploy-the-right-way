resource "aws_s3_bucket" "example_bucket" {
  bucket = "aws-lambda-deploy-right-way-${var.environment}"

  tags = {
    Name        = "aws-lambda-deploy-right-way-${var.environment}"
    Environment = var.environment
    Owner       = "Dapinder Singh"
  }
}

resource "aws_s3_bucket_public_access_block" "block_all" {
  bucket = aws_s3_bucket.example_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

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
