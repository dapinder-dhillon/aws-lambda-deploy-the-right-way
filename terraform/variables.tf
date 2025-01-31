#----------------------------
# Common Vars
#----------------------------

variable "account_id" {
  description = "The account id"
  type        = string
}

variable "aws_profile" {
  description = "The account profile name"
  type        = string
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "bucket" {
  type    = string
  default = ""
}
variable "key" {
  type    = string
  default = ""
}
variable "region" {
  type    = string
  default = ""
}
variable "profile" {
  type    = string
  default = ""
}

variable "environment" {
  description = "The environment (labs, nonprod, uat, prod)"
  type        = string

  validation {
    condition     = contains(["labs", "sit", "dev", "uat", "prod"], var.environment)
    error_message = "Valid values for var: environment are (labs, sit, dev, uat, prod)."
  }
}

variable "cw_log_retention_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. 0 indicates the logs never expire"
  type        = number
}

variable "tag_description" {
  description = "The description"
  default     = "This AWS Lambda function listens for S3 events, generates a pre-signed URL for accessing an object, and publishes it to an SNS topic. If any errors occur, it logs the issue and sends a Slack notification."
  type        = string
}

variable "create_s3_presigned_url_lambda_name" {
  type    = string
  default = "create_s3_presigned_url"
}

variable "lambda_s3_sns_name" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "aws_account_env" {
  type = string
}
