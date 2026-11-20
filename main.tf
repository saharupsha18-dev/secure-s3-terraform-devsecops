module "dev_bucket" {
  source                   = "./modules/s3-bucket"
  bucket_name              = var.dev_bucket
  environment              = "dev"
  enable_versioning        = var.dev_versioning
  enforce_secure_transport = var.dev_secure_transport
  enable_access_logging    = true
  logging_target_bucket    = "secure-s3-project-access-logs-202611"
}

module "test_bucket" {
  source                   = "./modules/s3-bucket"
  bucket_name              = var.test_bucket
  environment              = "test"
  enable_versioning        = var.test_versioning
  enforce_secure_transport = var.test_secure_transport
  enable_access_logging    = true
  logging_target_bucket    = "secure-s3-project-access-logs-202611"
}

module "prod_bucket" {
  source                   = "./modules/s3-bucket"
  bucket_name              = var.prod_bucket
  environment              = "production"
  enable_versioning        = var.prod_versioning
  enforce_secure_transport = var.prod_secure_transport
  enable_access_logging    = true
  logging_target_bucket    = "secure-s3-project-access-logs-202611"
}

module "access_logs_bucket" {
  source                   = "./modules/s3-bucket"
  bucket_name              = "secure-s3-project-access-logs-202611"
  environment              = "logging"
  enable_versioning        = true
  enforce_secure_transport = false
  enable_access_logging    = false
}

resource "aws_s3_bucket_policy" "central_access_logs_policy" {
  bucket = module.access_logs_bucket.bucket_name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowS3AccessLogDelivery"
        Effect = "Allow"

        Principal = {
          Service = "logging.s3.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = [
          "${module.access_logs_bucket.bucket_arn}/dev/*",
          "${module.access_logs_bucket.bucket_arn}/test/*",
          "${module.access_logs_bucket.bucket_arn}/production/*",
          "${module.access_logs_bucket.bucket_arn}/crr-source/*"
        ]

        Condition = {
          "StringEquals" = {
            "aws:SourceAccount" = "000000000000"
          }

          "ArnEquals" = {
            "aws:SourceArn" = [
              module.dev_bucket.bucket_arn,
              module.test_bucket.bucket_arn,
              module.prod_bucket.bucket_arn,
              "arn:aws:s3:::crr-source-bucket"
            ]
          }
        }
      }
    ]
  })
}