variable "create_www_subdomain" {
  type        = bool
  description = "Whether a www subdomain should be created"
  default     = true
}

variable "name" {
  type        = string
  description = "The Name of the application or solution  (e.g. `bastion` or `portal`)"
  default     = chinomsoikwuagwu.com
}

variable "hostname" {
  type        = string
  description = "Name of website bucket in `fqdn` format (e.g. `test.example.com`). IMPORTANT! Do not add trailing dot (`.`)"
  default     = chinomsoikwuagwu.com
}

variable "parent_zone_id" {
  type        = string
  description = "ID of the hosted zone to contain the record"
  default     = Z0044863131YEGD4T2XPV
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
  default     = us-east-2
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
