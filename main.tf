provider "aws" {
  alias = "aws"
}

provider "aws" {
  alias = "aws_app"
}

# Create Backup Role
resource "aws_iam_role" "backup_role" {
  name = var.backup-role-name

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principle": {
          "Service": "backup.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# Create Backup Policy
resource "aws_iam_policy" "backup_policy" {
  name = var.backup-policy-name
  description = ""

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "elasticfilesystem:DescribeBackupPolicy",
          "elasticfilesystem:DescribeTags",
          "elasticfilesystem:UntagResource",
          "elasticfilesystem:Backup",
          "elasticfilesystem:PutBackupPolicy",
          "elasticfilesystem:TagResource",
          "elasticfilesystem:CreateTags",
          "elasticfilesystem:DeleteTags",
        ]
        "Resource": [
          "arn:aws:elasticfilesystem:*:${var.account_id}:access-point/*",
          "arn:aws:elasticfilesystem:*:${var.account_id}:file-system/*"
        ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "attach-backup-policy" {
  role = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.backup_policy.arn
}

# Create Backup Vault
resource "aws_backup_vault" "backup-vault" {
  provider = aws.aws_app
  for_each = var.dataobject
  name = each.value.aws_backup_vault-name
}

# Create Backup Plan
resource "aws_backup_plan" "backup-plan" {
  provider = aws.aws_app
  for_each = var.dataobject
  name = "${each.value.backup-vault-name}-backup-plan"

  rule {
    rule_name = "${each.value.backup-vault-name}-${each.value.rule_name}"
    target_vault_name = aws_backup_vault.backup-vault[each.value.backup-vault-name].id
    schedule = each.value.schedule
    completion_window = each.value.completion_window

    lifecycle {
      cold_storage_after = each.value.lifecycle.cold_storage_after
      delete_after = each.value.lifecycle.delete_after
    }
  }

  depends_on = [ aws_backup_vault.backup-vault ]
}

# Assign Resource
resource "aws_backup_selection" "backup-selection" {
  provider = aws.aws_app
  for_each = var.dataobject
  iam_role_arn = aws_iam_role.backup_role.arn
  name = "${each.value.backup-vault-name}-backup-selection"
  plan_id = aws_backup_plan.backup-plan[each.value.backup-vault-name].id

  resources = [ each.value.backup-resource-arn ]
}