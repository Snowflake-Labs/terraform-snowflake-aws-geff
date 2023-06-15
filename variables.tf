# Required Variables
variable "prefix" {
  type        = string
  description = "This will be the prefix used to name the Resources."
}

# Optional Variables
variable "aws_region" {
  description = "The AWS region in which the AWS infrastructure is created."
  type        = string
  default     = "us-west-2"
}

variable "aws_cloudwatch_metric_namespace" {
  type        = string
  description = "prefix for CloudWatch Metrics that GEFF writes"
  default     = "*"
}

variable "log_retention_days" {
  description = "Log retention period in days."
  default     = 0 # Forever
}

variable "env" {
  type        = string
  description = "Dev/Prod/Staging or any other custom environment name."
  default     = "dev"
}

variable "snowflake_integration_user_roles" {
  type        = list(string)
  default     = []
  description = "List of roles to which GEFF infra will GRANT USAGE ON INTEGRATION perms."
}

variable "deploy_lambda_in_vpc" {
  type        = bool
  description = "The security group VPC ID for the lambda function."
  default     = false
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

variable "vpc_id" {
  type        = string
  description = "The VPC ID for creating the lambda and security group ID."
  default     = null
}

variable "geff_image_version" {
  type        = string
  description = "Version of the GEFF docker image."
  default     = "latest"
}

variable "data_bucket_arns" {
  type        = list(string)
  default     = []
  description = "List of Bucket ARNs for the s3_reader role to read from."
}

variable "geff_secret_arns" {
  type        = list(string)
  default     = ["*"]
  description = "GEFF Secrets."
}

variable "geff_dsn" {
  type        = string
  description = "GEFF project Sentry DSN."
  default     = ""
}

variable "sentry_driver_dsn" {
  type        = string
  description = "Snowflake errors project Sentry DSN."
  default     = ""
}

variable "arn_format" {
  type        = string
  description = "ARN format could be aws or aws-us-gov. Defaults to non-gov."
  default     = "aws"
}

variable "create_batch_locking_table" {
  type        = bool
  description = "Boolean for if a DynamoDB table is to be created for batch locking."
  default     = true
}

variable "batch_locking_table_name" {
  type        = string
  description = "DynamoDB table name for batch-locking, used either for an existing user-created table when 'create_batch_locking_table' is false, or as a table name for the module-created table when 'create_batch_locking_table' is true."
  default     = null
}

variable "batch_locking_table_ttl" {
  type        = number
  description = "TTL for items in the batch locking DynamoDB table."
  default     = 86400 # 1 day
}

variable "create_rate_limiting_table" {
  type        = bool
  description = "Boolean for if a DynamoDB table is to be created for rate limiting."
  default     = true
}

variable "rate_limiting_table_name" {
  type        = string
  description = "DynamoDB table name for rate limiting, used either for an existing user-created table when 'create_rate_limiting_table' is false, or as a table name for the module-created table when 'create_rate_limiting_table' is true."
  default     = null
}

variable "rate_limiting_table_ttl" {
  type        = number
  description = "TTL for items in the rate limiting DynamoDB table."
  default     = 86400 # 1 day
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name
}

locals {
  lambda_image_repo = "${local.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/geff"
}

locals {
  lambda_image_repo_version = "${local.lambda_image_repo}:${var.geff_image_version}"
}

locals {
  inferred_api_gw_invoke_url = "https://${aws_api_gateway_rest_api.ef_to_lambda.id}.execute-api.${local.aws_region}.amazonaws.com/"
  geff_prefix                = "${var.prefix}-geff"
}

locals {
  lambda_function_name    = "${local.geff_prefix}-lambda"
  api_gw_caller_role_name = "${local.geff_prefix}-api-gateway-caller"
  api_gw_logger_role_name = "${local.geff_prefix}-api-gateway-logger"
}
