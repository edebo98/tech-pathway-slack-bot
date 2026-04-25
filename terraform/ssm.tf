# ─────────────────────────────────────────
# IAM ROLE FOR EC2
# This gives your EC2 server an identity
# so it can talk to AWS services like SSM
# ─────────────────────────────────────────

# Create the IAM role that EC2 will assume
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-ec2-role"

  # This trust policy allows EC2 to use this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# Attach the AWS managed SSM policy to the role
# This gives the server permission to connect via SSM Session Manager
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create a custom policy that allows the server to read
# only the parameters it needs from SSM Parameter Store
resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "${var.project_name}-ssm-param-policy"
  description = "Allow EC2 to read Slack secrets from SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        # Only allow access to parameters under our project path
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_name}/*"
      }
    ]
  })
}

# Attach the custom parameter policy to the role
resource "aws_iam_role_policy_attachment" "ssm_parameter_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.ssm_parameter_policy.arn
}

# Create an instance profile
# This is what actually links the IAM role to the EC2 server
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}


# ─────────────────────────────────────────
# SSM PARAMETER STORE
# This is where your secrets live securely
# The server reads them at startup
# ─────────────────────────────────────────

# Store the Slack bot token as a SecureString
# SecureString means AWS encrypts it automatically
resource "aws_ssm_parameter" "slack_bot_token" {
  name        = "/${var.project_name}/SLACK_BOT_TOKEN"
  description = "Slack bot token for Tech Pathway Bot"
  type        = "SecureString"
  value       = var.slack_bot_token

  tags = {
    Name = "${var.project_name}-slack-bot-token"
  }
}

# Store the Slack signing secret as a SecureString
resource "aws_ssm_parameter" "slack_signing_secret" {
  name        = "/${var.project_name}/SLACK_SIGNING_SECRET"
  description = "Slack signing secret for Tech Pathway Bot"
  type        = "SecureString"
  value       = var.slack_signing_secret

  tags = {
    Name = "${var.project_name}-slack-signing-secret"
  }
}