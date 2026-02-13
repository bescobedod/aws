# Data source to retrieve network project outputs
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "pinulito-shared-terraform-state"
    key    = "pinulito-network/network/backend.tfstate"
    region = "us-east-2"
  }
}

# Data source to get Transit Gateway details
data "aws_ec2_transit_gateway" "network_tgw" {
  count = local.config.enable_transit_gateway_integration ? 1 : 0

  filter {
    name   = "owner-id"
    values = ["823613469731"]  # Network account
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Data source to get Transit Gateway default route table
data "aws_ec2_transit_gateway_route_table" "default" {
  count = local.config.enable_transit_gateway_integration ? 1 : 0

  filter {
    name   = "transit-gateway-id"
    values = [data.aws_ec2_transit_gateway.network_tgw[0].id]
  }

  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }
}

# Data source to get the existing Transit Gateway VPC attachment for network VPC
# This attachment is created by the network project
data "aws_ec2_transit_gateway_vpc_attachment" "network" {
  count = local.config.enable_transit_gateway_integration ? 1 : 0

  filter {
    name   = "transit-gateway-id"
    values = [data.aws_ec2_transit_gateway.network_tgw[0].id]
  }

  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.output.vpc.vpc_id]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
