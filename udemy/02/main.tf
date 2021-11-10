provider "aws" {}

module "vpcNetworking" {
  source = "./modules/vpc_network"
}

/*
resource "aws_security_group" "albGroup" {
  name        = "Allow_HTTP_ALB"
  vpc_id      = aws_vpc.webSite.id
  description = "Allow HTTP to ALB"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Inbound HTTP"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Any Outbound"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = merge(local.commonTags, { Name = "Allow HTTP" })

}
/*
resource "aws_security_group" "asgGroup" {
  name        = "Allow_HTTP_ASG_from_ALB"
  vpc_id      = aws_vpc.webSite.id
  description = "Allow HTTP to ASG from ALB"

  ingress {
    security_groups = [aws_security_group.albGroup.id]
    description     = "Allow Inbound HTTP"
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
  }
 
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow Any Outbound"
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  
  tags = merge(local.commonTags, { Name = "Allow HTTP" })
}

data "aws_ami" "latestAmazonLinux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_elb" "classicLB" {
  name            = "classicHTTPBalancer"
  subnets         = [aws_subnet.publicSubnet1.id, aws_subnet.publicSubnet2.id]
  tags            = local.commonTags
  security_groups = [aws_security_group.albGroup.id]
  listener {
    instance_protocol = "http"
    instance_port     = 80
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 10
  }
}
/////////////////////
/* FOR FUTURE PURPOSES

resource "aws_lb" "alb" {
  name               = "HTTP"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asgGroup.id]
  subnets            = [aws_subnet.publicSubnet1.id, aws_subnet.publicSubnet2.id]
}
////////////////////
resource "aws_launch_template" "webSiteTemplate" {
  name                   = "Website_node_template"
  instance_type          = "t2.micro"
  image_id               = data.aws_ami.latestAmazonLinux.id
  user_data              = filebase64(var.userdataPath)
  vpc_security_group_ids = [aws_security_group.asgGroup.id]
  key_name               = "home"
}

resource "aws_autoscaling_group" "webSite" {
  name = "ASG_for_WebSite"
  launch_template {
    id = aws_launch_template.webSiteTemplate.id
  }
  max_size            = 4
  min_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.privateSubnet1.id, aws_subnet.privateSubnet2.id]
  load_balancers      = [aws_elb.classicLB.name]
}

*/