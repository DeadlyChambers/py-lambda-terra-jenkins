variable "created" {
  default = "manual"
  type    = string
}

variable "sns_name" {
  default = "ds-operations-lambda-sns-topic"
  type    = string
}

variable "sns_role" {
  default = "ds-operations-lambda-sns-role"
  type    = string
}

variable "email" {
  default = "shanechambers85+slack@gmail.com"
  type    = string
}
