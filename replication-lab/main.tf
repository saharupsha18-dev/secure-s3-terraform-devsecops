resource "aws_s3_bucket" "source" {
  bucket = "crr-source-bucket"
}

resource "aws_s3_bucket" "destination" {
  bucket   = "crr-destination-bucket"
  provider = aws.destination
}

resource "aws_s3_bucket_versioning" "source_versioning" {
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_versioning" "destination_versioning" {
  bucket   = aws_s3_bucket.destination.id
  provider = aws.destination
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket     = aws_s3_bucket.source.id
  role       = aws_iam_role.s3_replication_role.arn
  depends_on = [aws_s3_bucket_versioning.source_versioning, aws_s3_bucket_versioning.destination_versioning]
  rule {
    id     = "replicate-all-objects"
    status = "Enabled"
    filter {
      prefix = ""
    }
    destination {
      bucket = aws_s3_bucket.destination.arn
    }
  }
}