locals {

  config = yamldecode(file("${path.module}/config/${terraform.workspace}.yaml"))

  identifier = "${local.config.identifier}"

  network = try(data.terraform_remote_state.network.outputs, null)

  db_port = 1433

  tags = merge(tomap({
    Env = terraform.workspace
  }), local.config.tags)
}

############################
# KMS Key (optional create)
############################
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS SQL Server encryption"
  enable_key_rotation     = local.config.kms_enable_rotation

  tags = local.config.tags
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${local.identifier}-sqlserver-rds"
  target_key_id = aws_kms_key.rds.key_id
}

############################
# IAM Role for S3 Backup/Restore
############################
resource "aws_iam_role" "rds_s3_backup_restore" {
  name = "${local.identifier}-rds-s3-backup-restore-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.config.tags
}

resource "aws_iam_role_policy" "rds_s3_backup_restore" {
  name = "${local.identifier}-rds-s3-backup-restore-policy"
  role = aws_iam_role.rds_s3_backup_restore.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "*"
      }
    ]
  })
}

############################
# Option Group for SQLSERVER_BACKUP_RESTORE
############################
resource "aws_db_option_group" "sqlserver_backup_restore" {
  name                     = "${local.identifier}-sqlserver-backup-restore"
  option_group_description = "Option group for SQL Server native backup/restore"
  engine_name              = "sqlserver-web"
  major_engine_version     = "15.00"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"

    option_settings {
      name  = "IAM_ROLE_ARN"
      value = aws_iam_role.rds_s3_backup_restore.arn
    }
  }

  tags = local.config.tags
}

############################
# Security groups
############################
resource "aws_security_group" "rds" {
  name        = "${local.identifier}-sqlserver-rds-sg"
  description = "Security group for SQL Server RDS"
  vpc_id      = local.network.output.vpc.vpc_id 

  tags = merge(
    local.config.tags,
    {
      Name = local.config.rds_sg_name
    }
  )
}

resource "aws_security_group_rule" "rds_ingress_cidr" {
  for_each = toset(local.config.allowed_cidr_blocks)

  type              = "ingress"
  from_port         = local.db_port
  to_port           = local.db_port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.rds.id
  description       = "SQL Server access from CIDR ${each.value}"
}

resource "aws_security_group_rule" "rds_ingress_sg" {
  for_each = toset(local.config.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.rds.id
  description              = "SQL Server access from SG ${each.value}"
}

resource "aws_security_group_rule" "rds_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds.id
}

############################
# RDS Module
############################
module "rds_sql_server" {
  source  = "terraform-aws-modules/rds/aws"
  version = "7.1.0"

  identifier = "${local.config.identifier}-sqlserver"

  engine         = local.config.db_engine
  engine_version = local.config.db_engine_version
  instance_class = local.config.db_instance_class

  major_engine_version = "15.00"
  family               = "sqlserver-web-15.0"

  allocated_storage = local.config.db_allocated_storage
  storage_type      = local.config.db_storage_type

  multi_az      = local.config.db_multi_az
  license_model = local.config.db_license_model

  storage_encrypted = true
  kms_key_id = aws_kms_key.rds.arn

  username                      = local.config.db_username
  manage_master_user_password   = true

  publicly_accessible = local.config.db_publicly_accessible

  vpc_security_group_ids = [aws_security_group.rds.id]

  option_group_name = aws_db_option_group.sqlserver_backup_restore.name

  create_db_subnet_group = true
  subnet_ids             = local.network.output.vpc.intra_subnets 

  backup_retention_period = local.config.backup_retention_period
  backup_window           = local.config.backup_window

  monitoring_interval = local.config.monitoring_interval

  tags = local.config.tags
}

