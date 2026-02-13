# Virtual Private Gateway
# Create VPN Gateway and attach it to the VPC
resource "aws_vpn_gateway" "main" {
  vpc_id          = data.terraform_remote_state.network.outputs.output.vpc.vpc_id
  amazon_side_asn = local.config.amazon_side_asn

  tags = {
    Name = "${local.config.identifier}-vpn-gateway-${local.workspace_suffix}"
  }
}

# Enable route propagation for private route tables
resource "aws_vpn_gateway_route_propagation" "private" {
  count = length(data.terraform_remote_state.network.outputs.output.vpc.private_route_table_ids)

  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = data.terraform_remote_state.network.outputs.output.vpc.private_route_table_ids[count.index]
}

# Customer Gateway
# Represents the on-premise FortiGate VPN endpoint
resource "aws_customer_gateway" "office" {
  bgp_asn    = local.config.customer_gateway_bgp_asn
  ip_address = local.config.customer_gateway_ip
  type       = "ipsec.1"

  tags = {
    Name = "${local.config.identifier}-customer-gateway-office-${local.workspace_suffix}"
  }
}

# VPN Connection
# Site-to-site VPN connection between AWS and office
resource "aws_vpn_connection" "office" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.office.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "${local.config.identifier}-vpn-connection-office-${local.workspace_suffix}"
  }
}

# Static routes for on-premise networks
resource "aws_vpn_connection_route" "office_networks" {
  count = length(local.config.on_premise_cidrs)

  destination_cidr_block = local.config.on_premise_cidrs[count.index]
  vpn_connection_id      = aws_vpn_connection.office.id
}

# Transit Gateway Integration
# Route in Transit Gateway for on-premise networks
# This allows SAP VPC to reach the office network via VPN
# Note: The TGW VPC attachment for network VPC already exists in the network project
resource "aws_ec2_transit_gateway_route" "on_premise_to_vpn" {
  count = local.config.enable_transit_gateway_integration ? length(local.config.on_premise_cidrs) : 0

  destination_cidr_block         = local.config.on_premise_cidrs[count.index]
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.network[0].id
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}
