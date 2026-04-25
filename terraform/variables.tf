# AWS region where everything gets created
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Project name used to label all resources consistently
variable "project_name" {
  description = "Name of the project used to tag resources"
  type        = string
  default     = "tech-pathway-slack-bot"
}

# EC2 instance type - t2.micro is free tier eligible
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Slack bot token - passed in at apply time, never hardcoded
variable "slack_bot_token" {
  description = "Slack bot token"
  type        = string
  sensitive   = true
}

# Slack signing secret - passed in at apply time, never hardcoded
variable "slack_signing_secret" {
  description = "Slack signing secret"
  type        = string
  sensitive   = true
}