provider "aws" {}

data "aws_availability_zones" "availableAZs" {
  all_availability_zones = true
  state = "available"
}

data "aws_ami" "latestAmazonLinux" {
  most_recent = true
  owners = [ "137112412989" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm*" ]
  }
}

resource "random_password" "testPassword" {
  length = 12
  special = true
  upper = true
}

resource "aws_ssm_parameter" "testPassword" {
  name = "testPassword"
  type = "SecureString"
  value = random_password.testPassword.result
  description = "Custom password"
}

resource "aws_instance" "webServer" {
  ami                    = data.aws_ami.latestAmazonLinux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.Allow_HTTP.id]
  key_name               = "home"
  user_data              = file(var.userdataPath)
  tags                   = merge(var.tags, { Name = "${var.tags["Stage"]} Web Server" })
  availability_zone = data.aws_availability_zones.availableAZs.names[2]

//  provisioner "local-exec" {
//    command = "echo $(date) >> /var/log/terraformLocalExec.log"
//  }
}

resource "aws_security_group" "Allow_HTTP" {
  name        = "Allow_HTTP_SSH"
  description = "Allow HTTP and SSH"
  tags        = var.tags
  dynamic "ingress" {
    for_each = [80, 22]
    content {
      cidr_blocks = ["0.0.0.0/0"]
      description = "value"
      from_port   = ingress.value
      protocol    = "tcp"
      to_port     = ingress.value
    }
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "value"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}