terraform {
  backend "s3" {
    bucket  = "elsevier-tio-596362325115"
    key     = "tdmp-py-lambda-file-distribution/terraform/dev/terraform.tfstate"
    region  = "eu-west-1"
    profile = "aws-ifp-nonprod"
  }
}
