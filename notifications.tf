resource "aws_sqs_queue" "s3_notifications" {
  name                       = "secure-s3-project-notifications" #Actual queue name in Floci
  visibility_timeout_seconds = 30                                #How long a received message stays hidden from other consumers
  sqs_managed_sse_enabled    = true

  tags = { #Metadata used to identify the queue
    Name        = "secure-s3-project-notifications"
    Environment = "shared"
    Purpose     = "S3 event notifications"
  }
}

resource "aws_sqs_queue_policy" "s3_notifications_policy" {
  queue_url = aws_sqs_queue.s3_notifications.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sqs:SendMessage"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Resource = aws_sqs_queue.s3_notifications.arn

        Condition = {
          "StringEquals" = {
            "aws:SourceAccount" = "000000000000"
          }

          "ArnEquals" = {
            "aws:SourceArn" = [
              module.dev_bucket.bucket_arn,
              module.test_bucket.bucket_arn,
              module.prod_bucket.bucket_arn
            ]
          }
        }
    }]
  })
}

resource "aws_s3_bucket_notification" "dev_notifications" {
  bucket = module.dev_bucket.bucket_name
  queue {
    queue_arn = aws_sqs_queue.s3_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sqs_queue_policy.s3_notifications_policy]

}
resource "aws_s3_bucket_notification" "test_notifications" {
  bucket = module.test_bucket.bucket_name
  queue {
    queue_arn = aws_sqs_queue.s3_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sqs_queue_policy.s3_notifications_policy]

}
resource "aws_s3_bucket_notification" "prod_notifications" {
  bucket = module.prod_bucket.bucket_name
  queue {
    queue_arn = aws_sqs_queue.s3_notifications.arn
    events    = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_sqs_queue_policy.s3_notifications_policy]

}