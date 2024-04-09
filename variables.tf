variable "backup-role-name" {
  type = string
}

variable "backup-policy-name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "dataobject" {
  type = map(object({
    rule_name = string
    schedule = string
    completion_window = number

    lifecycle = object({
      delete_after = string
      cold_storage_after = string
    })
    backup-vault-name = string
    backup-resource-arn = string
  }))
  description = "List of Rule Objects"
}