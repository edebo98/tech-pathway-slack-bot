#!/bin/bash

# Log everything so you can debug if something goes wrong
exec > /var/log/user_data.log 2>&1

echo "Starting setup..."

# Update the server
apt update -y
apt upgrade -y

# Install Python, Git, and AWS CLI
apt install python3 python3-pip python3-venv git awscli -y

echo "Dependencies installed"

# Go to ubuntu home directory
cd /home/ubuntu

# Clone your GitHub repository
git clone https://github.com/yourusername/tech-pathway-slack-bot.git

cd tech-pathway-slack-bot

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install -r requirements.txt

echo "Project installed"

# ─────────────────────────────────────────
# FETCH SECRETS FROM SSM PARAMETER STORE
# This replaces the .env file completely
# The server reads secrets directly from AWS
# ─────────────────────────────────────────

# Fetch the Slack bot token from SSM
SLACK_BOT_TOKEN=$(aws ssm get-parameter \
  --name "/${project_name}/SLACK_BOT_TOKEN" \
  --with-decryption \
  --region ${aws_region} \
  --query "Parameter.Value" \
  --output text)

# Fetch the Slack signing secret from SSM
SLACK_SIGNING_SECRET=$(aws ssm get-parameter \
  --name "/${project_name}/SLACK_SIGNING_SECRET" \
  --with-decryption \
  --region ${aws_region} \
  --query "Parameter.Value" \
  --output text)

echo "Secrets fetched from SSM"

# Write the secrets to a .env file for the app to use
cat > .env << EOF
SLACK_BOT_TOKEN=$SLACK_BOT_TOKEN
SLACK_SIGNING_SECRET=$SLACK_SIGNING_SECRET
PORT=3000
EOF

echo ".env file created"

# ─────────────────────────────────────────
# SUPERVISOR SETUP
# Keeps your bot running 24/7
# Restarts it automatically if it crashes
# ─────────────────────────────────────────

apt install supervisor -y

# Create supervisor config for the bot
cat > /etc/supervisor/conf.d/slackbot.conf << EOF
[program:slackbot]
command=/home/ubuntu/tech-pathway-slack-bot/venv/bin/python app/main.py
directory=/home/ubuntu/tech-pathway-slack-bot
user=ubuntu
autostart=true
autorestart=true
stderr_logfile=/var/log/slackbot.err.log
stdout_logfile=/var/log/slackbot.out.log
environment=HOME="/home/ubuntu",USER="ubuntu"
EOF

# Start supervisor and the bot
supervisorctl reread
supervisorctl update
supervisorctl start slackbot

echo "Bot started successfully"