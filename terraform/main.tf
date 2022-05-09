
data "aws_caller_identity" "current" {

}
locals {
  calling_role = data.aws_caller_identity.current.arn
  tags = {
    "ds:owned_by"   = "devops"
    "ds:contact"    = var.email
    "ds:created"    = var.created
    "ds:operations" = "restrict"
    "ds:git_repo"   = "https://bitbucket.org/datassential/jenkins/src/master/"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
  default_tags {
    tags = local.tags
  }
}

resource "aws_sns_topic" "ds_sns_topic" {
  name = var.sns_name
  tags = { "ds:created_by" = local.calling_role }
}

resource "aws_sns_topic_policy" "ds_sns_topic_policy" {
  arn    = aws_sns_topic.ds_sns_topic.arn
  policy = data.aws_iam_policy_document.ds_sns_topic_policy_document.json
  #tags   = { "ds:created_by" = local.calling_role }
}

data "aws_iam_policy_document" "ds_sns_topic_policy_document" {
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
      resource.aws_sns_topic.ds_sns_topic.arn,
    ]

    sid = "__default_statement_ID"

  }
  #tags = { "ds:created_by" = local.calling_role }
}

resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = resource.aws_sns_topic.ds_sns_topic.arn
  protocol  = "email"
  endpoint  = var.email

  #tags      = { "ds:created_by" = local.calling_role }
}

resource "aws_iam_role" "ds_operations_lambda_sns_role" {
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
          "Sid" : "ds-sns-assume-role"
        }
      ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", aws_iam_policy.ds_operations_lambda_role_policy.arn]
  tags                = { "ds:created_by" = local.calling_role }
}

resource "aws_iam_policy" "ds_operations_lambda_role_policy" {
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
  tags = { "ds:created_by" = local.calling_role }
}

resource "aws_lambda_function" "ds_operations_lambda" {
  filename         = "../lambda/simple-message-lambda.zip"
  function_name    = "ds-operations-lambda-sns"
  role             = aws_iam_role.ds_operations_lambda_sns_role.arn
  handler          = "send_sns.lambda_handler"
  description      = "Lambda function packaged and deployed from CICD that just sends a message to an SNS topic"
  source_code_hash = filebase64sha256("../lambda/simple-message-lambda.zip")
  runtime          = "python3.9"
  tags             = { "ds:created_by" = local.calling_role }
}


output "function_name" {
  description = "The name of the Lambda function created"
  value       = resource.aws_lambda_function.ds_operations_lambda.function_name
}

