terraform {
  backend "s3" {
    bucket               = "pinulito-shared-terraform-state"
    workspace_key_prefix = "alisa-site-to-site-vpn"
    key                  = "backend.tfstate"
    region               = "us-east-2"
    dynamodb_table       = "terraform-lock"
  }
}
