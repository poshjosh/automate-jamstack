variable "create_www_subdomain" {
  type        = bool
  description = "Whether a www subdomain should be created"
  default     = ${AWS_S3_CREATE_WWW_SUBDOMAIN}
}

variable "name" {
  type        = string
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
  default     = ${AWS_S3_BUCKET_NAME}
}

variable "hostname" {
  type        = string
  description = "Name of website bucket in `fqdn` format (e.g. `test.example.com`). IMPORTANT! Do not add trailing dot (`.`)"
  default     = ${AWS_S3_BUCKET_NAME}
}

variable "parent_zone_id" {
  type        = string
  description = "ID of the hosted zone to contain the record"
  default     = ${AWS_HOSTED_ZONE_ID}
}

variable "index_document" {
  type        = string
  default     = "index.html"
  description = "Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders"
}

variable "error_document" {
  type        = string
  default     = "404.html"
  description = "An absolute path to the document to return in case of a 4XX error"
}

variable "region" {
  type        = string
  default     = ${AWS_REGION}
  description = "AWS region this bucket should reside in"
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable versioning"
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Delete all objects from the bucket so that the bucket can be destroyed without error (e.g. `true` or `false`)"
}
