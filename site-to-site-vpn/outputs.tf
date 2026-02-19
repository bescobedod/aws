# VPN Connection Information
output "vpn_connection_id" {
  description = "ID of the VPN connection"
  value       = aws_vpn_connection.office.id
}

output "vpn_connection_arn" {
  description = "ARN of the VPN connection"
  value       = aws_vpn_connection.office.arn
}

# Customer Gateway Information
output "customer_gateway_id" {
  description = "ID of the customer gateway"
  value       = aws_customer_gateway.office.id
}

output "customer_gateway_ip" {
  description = "Public IP of the customer gateway (FortiGate)"
  value       = aws_customer_gateway.office.ip_address
}

# Virtual Private Gateway Information
output "vpn_gateway_id" {
  description = "ID of the virtual private gateway"
  value       = aws_vpn_gateway.main.id
}

output "vpn_gateway_asn" {
  description = "Amazon side ASN of the virtual private gateway"
  value       = aws_vpn_gateway.main.amazon_side_asn
}

# Tunnel 1 Configuration
output "tunnel1_address" {
  description = "Public IP address of the first VPN tunnel"
  value       = aws_vpn_connection.office.tunnel1_address
}

output "tunnel1_cgw_inside_address" {
  description = "RFC 6890 link-local address of the first tunnel for customer gateway"
  value       = aws_vpn_connection.office.tunnel1_cgw_inside_address
}

output "tunnel1_vgw_inside_address" {
  description = "RFC 6890 link-local address of the first tunnel for virtual private gateway"
  value       = aws_vpn_connection.office.tunnel1_vgw_inside_address
}

output "tunnel1_preshared_key" {
  description = "Pre-shared key for the first VPN tunnel"
  value       = aws_vpn_connection.office.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel1_bgp_asn" {
  description = "BGP ASN of the first tunnel"
  value       = aws_vpn_connection.office.tunnel1_bgp_asn
}

output "tunnel1_bgp_holdtime" {
  description = "BGP hold time of the first tunnel"
  value       = aws_vpn_connection.office.tunnel1_bgp_holdtime
}

# Tunnel 2 Configuration
output "tunnel2_address" {
  description = "Public IP address of the second VPN tunnel"
  value       = aws_vpn_connection.office.tunnel2_address
}

output "tunnel2_cgw_inside_address" {
  description = "RFC 6890 link-local address of the second tunnel for customer gateway"
  value       = aws_vpn_connection.office.tunnel2_cgw_inside_address
}

output "tunnel2_vgw_inside_address" {
  description = "RFC 6890 link-local address of the second tunnel for virtual private gateway"
  value       = aws_vpn_connection.office.tunnel2_vgw_inside_address
}

output "tunnel2_preshared_key" {
  description = "Pre-shared key for the second VPN tunnel"
  value       = aws_vpn_connection.office.tunnel2_preshared_key
  sensitive   = true
}

output "tunnel2_bgp_asn" {
  description = "BGP ASN of the second tunnel"
  value       = aws_vpn_connection.office.tunnel2_bgp_asn
}

output "tunnel2_bgp_holdtime" {
  description = "BGP hold time of the second tunnel"
  value       = aws_vpn_connection.office.tunnel2_bgp_holdtime
}

# Network Configuration
output "vpc_id" {
  description = "VPC ID where the VPN is attached"
  value       = data.terraform_remote_state.network.outputs.output.vpc.vpc_id
}

output "on_premise_cidrs" {
  description = "On-premise network CIDR blocks configured in static routes"
  value       = local.config.on_premise_cidrs
}

output "customer_gateway_configuration" {
  description = "Configuration information for the customer gateway (FortiGate)"
  value       = aws_vpn_connection.office.customer_gateway_configuration
  sensitive   = true
}

# VPN Logs
output "vpn_log_group_name" {
  description = "CloudWatch Log Group name for VPN logs"
  value       = aws_cloudwatch_log_group.vpn_logs.name
}

output "vpn_log_group_arn" {
  description = "CloudWatch Log Group ARN for VPN logs"
  value       = aws_cloudwatch_log_group.vpn_logs.arn
}
