module "dev_bucket" {
  source                   = "./modules/s3-bucket"
  bucket_name              = var.dev_bucket
  environment              = "dev"
  enable_versioning        = var.dev_versioning
  enforce_secure_transport = var.dev_secure_transport
}

module "test_bucket" {
  source                   = "./modules/s3-bucket"
  bucket_name              = var.test_bucket
  environment              = "test"
  enable_versioning        = var.test_versioning
  enforce_secure_transport = var.test_secure_transport
}

module "prod_bucket" {
  source                   = "./modules/s3-bucket"
  bucket_name              = var.prod_bucket
  environment              = "production"
  enable_versioning        = var.prod_versioning
  enforce_secure_transport = var.prod_secure_transport
}