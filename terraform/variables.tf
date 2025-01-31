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

#----------------------------
# Lambda - File Distribution
#----------------------------

variable "cw_log_retention_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. 0 indicates the logs never expire"
  type        = number
}

#----------------------------
# Tags
#----------------------------

variable "tag_product" {
  description = "The product"
  default     = "tdmp"
  type        = string
}

variable "tag_description" {
  description = "The description"
  default     = "Shared file distribution handler"
  type        = string
}

variable "tag_sub_product" {
  description = "Used when there are two or more products within the same account (see standards docs)"
  default     = "file_distribution"
  type        = string
}

variable "tag_orchestration" {
  description = "Git repo used to create the infrastructure (for tagging)"
  default     = "https://github.com/elsevier-bts/tdmp-aws-pylambda-file-distribution/tree/main/terraform"
  type        = string
}

variable "tag_costcode" {
  description = "The costcentre label to tag resources"
  default     = "20869"
  type        = string
}

variable "tag_contact" {
  description = "The contact label to tag resources"
  default     = "elstechtiobtscloud@Elsevier.com"
  type        = string
}


variable "file_distribution_lambda_name" {
  type    = string
  default = "tdmp-aws-py-file-distribution"
}

variable "lambda_s3_sns_name" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.8"
}

variable "aws_account_env" {
  type = string
}
