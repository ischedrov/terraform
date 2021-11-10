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
  tags  = merge(local.commonTags, { Name = "EIP for NAT GW ${count.index + 1}" })
}

resource "aws_nat_gateway" "NatGWs" {
  count         = length(aws_eip.EipNatGWs[*].id)
  allocation_id = aws_eip.EipNatGWs[count.index].id
  subnet_id     = element(aws_subnet.PrivateSubnets[*].id, count.index)
  tags          = merge(local.commonTags, { Name = "NAT GW ${count.index + 1 }" })
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