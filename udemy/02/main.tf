provider "aws" {}

#Declare local variables. It's globale specify tags for all resources

locals {
  commonTags = {
    Environment = "Test"
    Created     = "Ivan Schedrov"
    Purpose     = "For own website"
  }
}

#Creating VPC

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

resource "aws_route_table" "privateRouteTable1" {
  vpc_id = aws_vpc.webSite.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGW1.id
  }
  tags = merge(local.commonTags, { Name = "Private Route Table 1" })
}

resource "aws_route_table" "privateRouteTable2" {
  vpc_id = aws_vpc.webSite.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGW2.id
  }
  tags = merge(local.commonTags, { Name = "Private Route Table 2" })
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "publicSubnet1" {
  vpc_id                  = aws_vpc.webSite.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = var.PublicSubnet1Cidr
  map_public_ip_on_launch = true
  tags                    = merge(local.commonTags, { Name = "Public Subnet 1" })
}

resource "aws_route_table_association" "publicSubnet1" {
  subnet_id      = aws_subnet.publicSubnet1.id
  route_table_id = aws_default_route_table.PublicRouteTable.id
}

resource "aws_subnet" "publicSubnet2" {
  vpc_id                  = aws_vpc.webSite.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = var.PublicSubnet2Cidr
  map_public_ip_on_launch = true
  tags                    = merge(local.commonTags, { Name = "Public Subnet 2" })
}

resource "aws_route_table_association" "publicSubnet2" {
  subnet_id      = aws_subnet.publicSubnet2.id
  route_table_id = aws_default_route_table.PublicRouteTable.id
}

resource "aws_subnet" "privateSubnet1" {
  vpc_id            = aws_vpc.webSite.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = var.PrivateSubnet1Cidr
  tags              = merge(local.commonTags, { Name = "Private Subnet 1" })
}

resource "aws_route_table_association" "privateSubnet1" {
  subnet_id      = aws_subnet.privateSubnet1.id
  route_table_id = aws_route_table.privateRouteTable1.id
}

resource "aws_subnet" "privateSubnet2" {
  vpc_id            = aws_vpc.webSite.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = var.PrivateSubnet2Cidr
  tags              = merge(local.commonTags, { Name = "Private Subnet 2" })
}

resource "aws_route_table_association" "privateSubnet2" {
  subnet_id      = aws_subnet.privateSubnet2.id
  route_table_id = aws_route_table.privateRouteTable2.id
}
resource "aws_eip" "EipNatGW1" {
  tags = merge(local.commonTags, { Name = "EIP for NAT GW1" })
}

resource "aws_eip" "EipNatGW2" {
  tags = merge(local.commonTags, { Name = "EIP for NAT GW2" })
}
resource "aws_nat_gateway" "NatGW1" {
  subnet_id     = aws_subnet.publicSubnet1.id
  allocation_id = aws_eip.EipNatGW1.id
  tags          = merge(local.commonTags, { Name = "NAT GW 1" })
}

resource "aws_nat_gateway" "NatGW2" {
  allocation_id = aws_eip.EipNatGW2.id
  subnet_id     = aws_subnet.publicSubnet2.id
  tags          = merge(local.commonTags, { Name = "NAT GW 2" })
}

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
/* FOR FUTURE PURPOSES

resource "aws_lb" "alb" {
  name               = "HTTP"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asgGroup.id]
  subnets            = [aws_subnet.publicSubnet1.id, aws_subnet.publicSubnet2.id]
}
*/
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

