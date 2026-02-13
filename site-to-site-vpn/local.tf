locals {
  validate          = terraform.workspace == "default" ? tobool("Default workspace is not allowed") : true
  config            = yamldecode(file("${path.module}/config/${terraform.workspace}.yaml"))
  workspace_suffix  = terraform.workspace
  
  # Use data source TGW ID if integration is enabled, otherwise use config value
  transit_gateway_id = local.config.enable_transit_gateway_integration ? data.aws_ec2_transit_gateway.network_tgw[0].id : null
  transit_gateway_route_table_id = local.config.enable_transit_gateway_integration ? data.aws_ec2_transit_gateway_route_table.default[0].id : null
}
