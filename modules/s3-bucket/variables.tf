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