variable "create_cloudtrail" {
  description = "Set to true to create the resource, or false to skip it."
  type        = bool
}


variable "create_vpc_flow_logs" {
  description = "Set to true to create the resource, or false to skip it."
  type        = bool
}

variable "vpc_id" {
  description = "The ID of the VPC where you want to enable VPC Flow Logs."
  type        = string
}


variable "region" {
  description = "The AWS region where you want to deploy the resources."
  type        = string
}

variable "cloudtrail_log_group_name" {
  description = "The ID of the VPC where you want to enable VPC Flow Logs."
  type        = string
  default     = "cloudtrail_log_group_name"
}

variable "vpc_flow_logs_name" {
  description = "The ID of the VPC where you want to enable VPC Flow Logs."
  type        = string
  default     = "vpc_flow_logs_name"
}