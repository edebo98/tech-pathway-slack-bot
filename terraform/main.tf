# Tell Terraform to use AWS and which region
provider "aws" {
  region = var.aws_region
}

# Automatically get the latest Ubuntu 22.04 image
# So you never have to manually look up an AMI ID
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group - firewall rules for your server
# Notice there is NO port 22 rule because SSM replaces SSH completely
resource "aws_security_group" "bot_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Tech Pathway Slack Bot"

  # Allow traffic on port 3000 so Slack can reach your bot
  ingress {
    description = "App port for Slack events"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP traffic
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic so the server can reach
  # the internet, AWS services, and SSM endpoints
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# The EC2 server itself
resource "aws_instance" "bot_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  # Attach the SSM instance profile
  # This is what gives the server its AWS identity and SSM access
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [aws_security_group.bot_sg.id]

  # Run the startup script when the server first boots
  # Pass the project name and region so the script knows
  # where to fetch secrets from SSM Parameter Store
  user_data = templatefile("${path.module}/user_data.sh", {
    project_name = var.project_name
    aws_region   = var.aws_region
  })

  subnet_id = "subnet-0781f0fa10499d9d4"

  tags = {
    Name = var.project_name
  }
}