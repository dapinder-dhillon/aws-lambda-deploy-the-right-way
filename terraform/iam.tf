// IAM Role and Policies for Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = join("-", [
    "role",
    var.file_distribution_lambda_name,
  var.environment])
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = merge(local.common_tags, {
    "Name" = join("-", [
      "role",
      var.file_distribution_lambda_name,
    var.environment]), "Description" = var.tag_description
  })
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      data.aws_sns_topic.lambda_input_sns_tpic.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:ListTopics",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]

    resources = [
      "${aws_cloudwatch_log_group.lambda_cloudwatch_log_group.arn}:*"
    ]
  }
  statement {
    sid    = "AllowInvokingLambdas"
    effect = "Allow"

    resources = [
      aws_lambda_function.file_distribution_function.arn
    ]

    actions = [
      "lambda:AddPermission",
      "lambda:RemovePermission"
    ]
  }
  statement {
    sid       = "AllowAllSSMDescribe"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ssm:DescribeParameters"]
  }
  statement {
    sid       = "AllowSSM"
    effect    = "Allow"
    resources = [aws_ssm_parameter.alerts_slack_token.arn]
    actions   = ["ssm:GetParameters"]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = join("-", [
    "policy",
    var.file_distribution_lambda_name,
  var.environment])
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}
