provider "aws" {}

#Declare local variables. It's global specify tags for all resources

locals {
  commonTags = {
    Environment = "Test"
    Created     = "Ivan Schedrov"
    Purpose     = "For own website"
  }
}

resource "aws_vpc" "webSite" {
  cidr_block       = var.vpcCidrBlock
  instance_tenancy = "default"
  tags             = merge(local.commonTags, { Name = "VPC for WebSite" })
}

resource "aws_internet_gateway" "InternetGW" {
  vpc_id = aws_vpc.webSite.id
  tags   = merge(local.commonTags, { Name = "Internet GW" })
}

resource "aws_default_route_table" "PublicRouteTable" {
  default_route_table_id = aws_vpc.webSite.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGW.id
  }
  tags = merge(local.commonTags, { Name = "Public Route Table" })
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_eip" "EipNatGWs" {
  count = length(var.PrivateSubnetsCidr)
  tags  = merge(local.commonTags, { Name = "EIP for NAT GW ${count.index}" })
}

resource "aws_nat_gateway" "NatGWs" {
  count         = length(aws_eip.EipNatGWs[*].id)
  allocation_id = aws_eip.EipNatGWs[count.index].id
  subnet_id     = element(aws_subnet.PrivateSubnets[*].id, count.index)
  tags          = merge(local.commonTags, { Name = "NAT GW ${count.index}" })
}

resource "aws_subnet" "PublicSubnets" {
  count                   = length(var.PublicSubnetsCidr)
  vpc_id                  = aws_vpc.webSite.id
  map_public_ip_on_launch = true
  cidr_block              = element(var.PublicSubnetsCidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags                    = merge(local.commonTags, { Name = "Public Subnet ${count.index + 1}" })
}

resource "aws_route_table_association" "PublicRoutes" {
  count          = length(aws_subnet.PublicSubnets[*].id)
  subnet_id      = element(aws_subnet.PublicSubnets[*].id, count.index)
  route_table_id = aws_default_route_table.PublicRouteTable.id
}

resource "aws_subnet" "PrivateSubnets" {
  count             = length(var.PrivateSubnetsCidr)
  vpc_id            = aws_vpc.webSite.id
  cidr_block        = element(var.PrivateSubnetsCidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(local.commonTags, { Name = "Private Subnet ${count.index + 1}" })
}

resource "aws_route_table" "privateRouteTables" {
  count  = length(var.PrivateSubnetsCidr)
  vpc_id = aws_vpc.webSite.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGWs[count.index].id
  }
  tags = merge(local.commonTags, { Name = "Private Route Table ${count.index + 1}" })
}

resource "aws_route_table_association" "name" {
  count          = length(aws_subnet.PrivateSubnets[*].id)
  subnet_id      = aws_subnet.PrivateSubnets[count.index].id
  route_table_id = aws_route_table.privateRouteTables[count.index].id
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