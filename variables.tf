variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"
}

variable "buckets" {
  type = map(string)
  default = {
    landing_zone = "landing-zone-bucket-dritter"
    curated_zone = "curated-zone-bucket-dritter"
  }
}

variable "lambda_function_name" {
  type = string
  default = "DataprocLambda"
}

variable "lambda_timeout" {
  type = number
  default = 30
}

variable "lambda_role_name" {
  type    = string
  default = "lambda_exec_role"
}

variable "lambda_policy_name" {
  type    = string
  default = "lambda_s3_access_policy"
}

variable "cloudwatch_log_retention_days" {
  type    = number
  default = 14
}