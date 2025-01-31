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

variable "lambda_dependencies_zip_name" {
  type    = string
  default = "lib_dependencies.zip"
}
variable "file_distribution_lambda_layer_name" {
  type    = string
  default = "tdmp-aws-py-file-distribution-dependencies"
}
variable "aws_account_env" {
  type = string
}

variable "runtime" {
  default = "python3.8"
}
