data "aws_availability_zone" "current" {
  name = var.availability_zone
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { "Name" = "vpc.${var.project}" })
}

resource "aws_vpc_dhcp_options" "vpc-options" {
  domain_name         = "${data.aws_availability_zone.current.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags                = var.tags
}

resource "aws_vpc_dhcp_options_association" "vpc-options-assoc" {
  dhcp_options_id = aws_vpc_dhcp_options.vpc-options.id
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_subnet" "private-subnet" {
  cidr_block        = var.private_subnet
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zone
  tags = merge(var.tags, {
    "Name"       = "private-subnet.${var.availability_zone}.${var.project}"
    "SubnetType" = "private"
  })
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.public_subnet
  tags = merge(var.tags, {
    "Name"       = "public-subnet.${var.availability_zone}.${var.project}"
    "SubnetType" = "public"
  })
}

resource "aws_route" "public-route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gw.id
  route_table_id         = aws_route_table.public-route-table.id
}

resource "aws_route" "private-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private-route-table.id
  network_interface_id   = data.aws_instance.nat.network_interface_id
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { "Name" = "private-rtb.${var.project}" })
}

resource "aws_route_table" "public-route-table" {
  tags   = merge(var.tags, { "Name" = "public-rtb.${var.project}" })
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "private-route-table-assoc" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet.id
}

resource "aws_route_table_association" "public-route-table-assoc" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet.id
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { "Name" = "igw.${var.project}" })
}

module "nat" {
  source          = "git::https://github.com/PiotrKuligowski/terraform-aws-spot-nat.git"
  ami_id          = var.ami_id
  project         = var.project
  component       = var.component
  tags            = var.tags
  security_groups = var.security_groups
  ssh_key_name    = var.ssh_key_name
  subnet_ids      = [aws_subnet.public-subnet.id]
  vpc_id          = aws_vpc.vpc.id
  vpc_cidr        = aws_vpc.vpc.cidr_block
}

data "aws_instance" "nat" {
  depends_on = [module.nat]
  filter {
    name   = "tag:Name"
    values = ["${var.project}-${var.component}"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}