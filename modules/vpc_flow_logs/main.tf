# Create an IAM policy for VPC Flow Logs to CloudWatch Logsresource "aws_iam_policy" "vpc_flow_logs_policy" {
  resource "aws_iam_policy" "vpc_flow_logs_policy" {
  count = var.create_vpc_flow_logs ? 1 : 0
  name        = "VPCFlowLogsToCloudWatchPolicy-${data.aws_caller_identity.current.account_id}"
  description = "IAM policy for VPC Flow Logs to CloudWatch Logs"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

# Create an IAM role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  count = var.create_vpc_flow_logs ? 1 : 0
  name = "VPCFlowLogsToCloudWatchRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_policy_attachment" "vpc_flow_logs_policy_attachment" {
  count = var.create_vpc_flow_logs ? 1 : 0
  name       = "vpc_flow_logs_policy_attachment"
  policy_arn = aws_iam_policy.vpc_flow_logs_policy[0].arn
  roles      = [aws_iam_role.vpc_flow_logs_role[0].name]
}

# Create a CloudWatch Logs Log Group
resource "aws_cloudwatch_log_group" "vpc_flow_logs_log_group" {
  count = var.create_vpc_flow_logs ? 1 : 0
  name = "/vpc/flow-logs-${data.aws_caller_identity.current.account_id}"
}

# Enable VPC Flow Logs for your VPC
resource "aws_flow_log" "example" {
  count = var.create_vpc_flow_logs ? 1 : 0
  iam_role_arn          = aws_iam_role.vpc_flow_logs_role[0].arn
  log_destination       = aws_cloudwatch_log_group.vpc_flow_logs_log_group[0].arn
  max_aggregation_interval = 60
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id # Replace with your VPC ID
}
