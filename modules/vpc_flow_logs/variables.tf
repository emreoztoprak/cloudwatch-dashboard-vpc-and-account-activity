variable "create_vpc_flow_logs" {
  description = "Set to true to create the resource, or false to skip it."
  type        = bool
  default     = false
}


variable "vpc_id" {
  description = "Set to true to create the resource, or false to skip it."
  type        = string
}
