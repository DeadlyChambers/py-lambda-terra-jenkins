
data "aws_caller_identity" "current" {
}
locals {
  calling_role = data.aws_caller_identity.current.arn
  tags = {
    "ds:owned_by"   = "devops"
    "ds:contact"    = "ds-dev-ops-notificati-aaaaglkan4mbjlugcphmgtgxjy@datassential.slack.com"
    "ds:created"    = var.created
    "ds:operations" = "restrict"
    "ds:git_repo"   = "https://bitbucket.org/datassential/jenkins/src/master/"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "jenkins-deployer"
  default_tags {
    tags = local.tags
  }
}

resource "aws_iam_role" "ds_operations_lambda_sns_role" {
  name = "ds-operations-lambda-sns-role"
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
          "Sid" : ""
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
          "Resource" : "arn:aws:sns:us-east-1:047476809233:ds-operations-lambda-sns-MySnsTopic-LZYME5CPK0NF",
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
