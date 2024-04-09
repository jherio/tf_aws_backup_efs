# Terraform AWS Backup for EFS

This module was design to create an automated backup of an EFS in AWS Backup

## Example

''' terraform
module "backup-module" {
source = jherio/tf_aws_backup_efs
account_id = local.account_id
backup-role-name = "${local.project_name}-role"
  backup-policy-name = "${local.project_name}-policy"
backup-vault-names = var.backup-vault-names
rules = var.rules
backup-resource-arn = var.backup-resource-arn
}
'''

## Variables

| variable name       | type         | description                    |
| ------------------- | ------------ | ------------------------------ |
| account_id          | string       | AWS Account ID                 |
| backup-role-name    | string       | AWS Backup Role Name           |
| backup-policy-name  | string       | AWS Backup Policy Name         |
| backup-resource-arn | list(string) | List of EFS Arns               |
| backup-vault-name   | list(string) | List of AWS Backup Vault Names |
