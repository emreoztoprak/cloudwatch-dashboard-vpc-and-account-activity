resource "aws_cloudwatch_log_group" "example" {
  count = var.create_cloudtrail ? 1 : 0
  name = "my-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"  # Update with your desired log group name
}

resource "aws_s3_bucket" "example" {
  count = var.create_cloudtrail ? 1 : 0
  bucket = "my-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"  # Update with your desired S3 bucket name
}

resource "aws_s3_bucket_policy" "example" {
  count = var.create_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.example[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.example[0].arn
      },
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.example[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role" "example" {
  count = var.create_cloudtrail ? 1 : 0
  name = "cloudtrail-role"  # Update with your desired role name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
    }]
  })
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  count = var.create_cloudtrail ? 1 : 0
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]  # Adjust the resource to restrict access if necessary
  }
}

resource "aws_iam_policy" "cloudwatch_logs" {
  count = var.create_cloudtrail ? 1 : 0
  name        = "cloudwatch-logs-policy"
  description = "IAM policy for CloudWatch Logs access"
  policy      = data.aws_iam_policy_document.cloudwatch_logs[0].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  count = var.create_cloudtrail ? 1 : 0
  policy_arn = aws_iam_policy.cloudwatch_logs[0].arn
  role       = aws_iam_role.example[0].name
}

resource "aws_cloudtrail" "example" {
  count = var.create_cloudtrail ? 1 : 0
  name                          = "my-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.example[0].id
  cloud_watch_logs_group_arn     = "${aws_cloudwatch_log_group.example[0].arn}:*"
  cloud_watch_logs_role_arn      = aws_iam_role.example[0].arn
  is_organization_trail         = false
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  # Specifies which management events you want to log and which ones to exclude
  event_selector {
    read_write_type = "All"
    include_management_events = true
  }

  depends_on = [
    aws_cloudwatch_log_group.example,
    aws_iam_role_policy_attachment.cloudwatch_logs,
    aws_s3_bucket.example,
    aws_s3_bucket_policy.example
  ]
}