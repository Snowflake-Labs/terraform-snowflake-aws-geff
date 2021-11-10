# Required
variable "snowflake_account" {
  type      = string
  sensitive = true
}

# Optional
variable "snowflake_integration_owner_role" {
  type    = string
  default = "ACCOUNTADMIN"
}

variable "aws_region" {
  description = "The AWS region in which the AWS infrastructure is created."
  type        = string
  default     = "us-west-2"
}

variable "prefix" {
  type        = string
  description = "this will be the prefix used to name the Resources"
  default     = "example"
}

variable "aws_cloudwatch_metric_namespace" {
  type        = string
  description = "prefix for CloudWatch Metrics that GEFF writes"
  default     = "*"
}

variable "env" {
  type    = string
  default = "prod"
}

variable "deploy_lambda_in_vpc" {
  type        = bool
  default     = false
  description = "The security group VPC ID for the lambda function."
}

variable "lambda_security_group_ids" {
  type        = list(string)
  default     = []
  description = "The security group IDs for the lambda function."
}

variable "lambda_subnet_ids" {
  type        = list(string)
  default     = []
  description = "The subnet IDs for the lambda function."
}

variable "geff_image_version" {
  type        = string
  description = "Version of the GEFF docker image."
  default     = "latest"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
