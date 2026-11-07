variable "s3_endpoint" {
  type        = string
  description = "Endpoint URL used to connect Terraform to the S3 service"
}

variable "dev_bucket" {
  type        = string
  description = "Name of the S3 bucket for the Dev environment"
}

variable "test_bucket" {
  type        = string
  description = "Name of the S3 bucket for the Test environment"
}

variable "prod_bucket" {
  type        = string
  description = "Name of the S3 bucket for the Production environment"
}

variable "dev_versioning" {
  type        = bool
  description = "Controls versioning for the Dev bucket"
}

variable "test_versioning" {
  type        = bool
  description = "Controls versioning for the Test bucket"
}

variable "prod_versioning" {
  type        = bool
  description = "Controls versioning for the Production bucket"
}

variable "dev_secure_transport" {
  type        = bool
  description = "Controls HTTPS enforcement for Dev"
}

variable "test_secure_transport" {
  type        = bool
  description = "Controls HTTPS enforcement for Test"
}

variable "prod_secure_transport" {
  type        = bool
  description = "Controls HTTPS enforcement for Production"
}