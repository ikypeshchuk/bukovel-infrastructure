variable "cluster_id" {
  description = "The ID of the database cluster"
  type        = string
}

variable "backup_hour" {
  description = "The hour when the backup will be created"
  type        = number
}
