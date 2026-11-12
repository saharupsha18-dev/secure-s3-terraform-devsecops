terraform {
  backend "s3" {
    bucket       = "terraform-state"
    key          = "secure-s3-project/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    access_key   = "test"
    secret_key   = "test"

    endpoints = {
      s3 = "http://localhost:4566"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
}    