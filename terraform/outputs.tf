# Public IP of your server
output "server_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.bot_server.public_ip
}

# The URL to paste into Slack Event Subscriptions
output "slack_events_url" {
  description = "Paste this URL into Slack Event Subscriptions Request URL"
  value       = "http://${aws_instance.bot_server.public_ip}:3000/slack/events"
}

# Health check URL to confirm the server is running
output "health_check_url" {
  description = "Visit this URL to confirm your bot is running"
  value       = "http://${aws_instance.bot_server.public_ip}:3000/health"
}

# SSM connect command - use this instead of SSH to access your server
output "ssm_connect_command" {
  description = "Run this command in your terminal to connect to your server via SSM"
  value       = "aws ssm start-session --target ${aws_instance.bot_server.id} --region ${var.aws_region}"
}

# Instance ID - useful for SSM and AWS CLI commands
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.bot_server.id
}