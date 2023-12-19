module "cloudtrail" {
  source = "./modules/cloudtrail"

  create_cloudtrail = var.create_cloudtrail
}


module "vpc_flow_logs" {
  source = "./modules/vpc_flow_logs"

  create_vpc_flow_logs = var.create_vpc_flow_logs
  vpc_id = var.vpc_id
}


module "cloudwatch_dashboards" {
  source = "./modules/cloudwatch_dashboards"
  
  cloudtrail_log_group = var.create_cloudtrail ? module.cloudtrail.log_group_name[0] : var.cloudtrail_log_group_name
  vpc_log_group = var.create_vpc_flow_logs? module.vpc_flow_logs.vpc_log_group_name[0] : var.vpc_flow_logs_name
  region = var.region
}
