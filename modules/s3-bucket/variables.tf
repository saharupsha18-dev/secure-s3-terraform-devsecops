variable "bucket_name" {
  type        = string
  description = "Used to store the bucket name"
}

variable "environment" {
  type        = string
  description = "Used to store the environment"
}

variable "enable_versioning" {
  type        = bool
  description = "Controls whether versioning is enabled for the S3 bucket"
}

variable "enforce_secure_transport" {
  type        = bool
  description = "Controls whether HTTP requests to the S3 bucket are denied"
}

variable "enable_access_logging" {
  type        = bool
  default     = false
  description = "Controls whether server access logging is enabled for the S3 bucket"
}

variable "logging_target_bucket" {
  type        = string
  default     = null
  description = "Name of the S3 bucket where access logs will be stored"
}
