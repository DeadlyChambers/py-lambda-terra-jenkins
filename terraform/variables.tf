variable "created" {
  default = "jenkins"
  type    = string
}

variable "sns_name" {
  default = "soinshane-lambda-sns-topic"
  type    = string
}

variable "sns_role" {
  default = "soinshane-lambda-sns-role"
  type    = string
}
variable "lambda_function_name" {
  default = "soinshane-lambda-for-sns"
}
variable "email" {
  default = "shanechambers85+slack@gmail.com"
  type    = string
}

variable "aws_profile" {
  default = "jenkins-user"
  type    = string
}
