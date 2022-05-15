
data "aws_caller_identity" "current" {

}
locals {
  calling_role = data.aws_caller_identity.current.arn
  tags = {
    "soin:owned_by"   = "devops"
    "soin:contact"    = var.email
    "soin:created"    = var.created
    "soin:operations" = "restrict"
    "soin:git_repo"   = "git@github.com:DeadlyChambers/py-lambda-terra-jenkins.git"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
  default_tags {
    tags = local.tags
  }
}

resource "aws_sns_topic" "soinshane_sns_topic" {
  name = var.sns_name
  tags = {
    Name              = var.sns_name
    "soin:created_by" = local.calling_role
  }
}

resource "aws_sns_topic_policy" "soinshane_sns_topic_policy" {
  arn    = aws_sns_topic.soinshane_sns_topic.arn
  policy = data.aws_iam_policy_document.soinshane_sns_topic_policy_document.json
  #tags   = { "soin:created_by" = local.calling_role }
}

data "aws_iam_policy_document" "soinshane_sns_topic_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      resource.aws_sns_topic.soinshane_sns_topic.arn,
    ]

    sid = "__default_statement_ID"

  }
  #tags = { "soin:created_by" = local.calling_role }
}

resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = resource.aws_sns_topic.soinshane_sns_topic.arn
  protocol  = "email"
  endpoint  = var.email

  #tags      = { "soin:created_by" = local.calling_role }
}

resource "aws_iam_role" "soinshane_lambda_sns_role" {
  name = var.sns_role
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : "soinshane-sns-assume-role"
        }
      ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", aws_iam_policy.soinshane_lambda_role_policy.arn]
  tags                = { "soin:created_by" = local.calling_role }
}

resource "aws_iam_policy" "soinshane_lambda_role_policy" {
  policy = jsonencode(
    {
      "Version" : "2012-10-17"
      "Statement" : [
        {
          "Action" : [
            "sns:Publish"
          ],
          "Resource" : "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:${var.sns_name}",
          "Effect" : "Allow"
        }
      ]
  })
  tags = {
    Name = "soinshane-lambda-role-policy"
  "soin:created_by" = local.calling_role }
}

resource "aws_lambda_function" "soinshane_lambda" {
  filename         = "../lambda/simple-message-lambda.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.soinshane_lambda_sns_role.arn
  handler          = "send_sns.lambda_handler"
  description      = "Lambda function packaged and deployed from CICD that just sends a message to an SNS topic"
  source_code_hash = filebase64sha256("../lambda/simple-message-lambda.zip")
  runtime          = "python3.9"
  tags             = { "soin:created_by" = local.calling_role }
}


output "function_name" {
  description = "The name of the Lambda function created"
  value       = resource.aws_lambda_function.soinshane_lambda.function_name
}

