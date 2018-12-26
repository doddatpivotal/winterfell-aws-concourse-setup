provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "concourse_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = "${merge(var.tags, map("Name", "${var.env_name}-vpc"))}"
}

resource "aws_subnet" "concourse_public_subnet" {
  vpc_id            = "${aws_vpc.concourse_vpc.id}"
  cidr_block        = "${local.public_cidr}"
  availability_zone = "${element(var.availability_zones, 0)}"

  tags = "${merge(var.tags, map("Name", "${var.env_name}-public-subnet"))}"
}

resource "aws_route_table_association" "public" {

  subnet_id      = "${aws_subnet.concourse_public_subnet.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}
resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.concourse_private_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_subnet" "concourse_private_subnet" {
  vpc_id            = "${aws_vpc.concourse_vpc.id}"
  cidr_block        = "${local.private_cidr}"
  availability_zone = "${element(var.availability_zones, 0)}"

  tags = "${merge(var.tags, map("Name", "${var.env_name}-private-subnet"))}"
}

resource "aws_eip" "bosh_eip" {}
resource "aws_eip" "concourse_eip" {}
resource "aws_eip" "nat" {}

resource "aws_internet_gateway" "concourse_igw" {
  vpc_id = "${aws_vpc.concourse_vpc.id}"

  tags = {
    Name = "concourse_igw"
  }
}
resource "aws_nat_gateway" "concourse_nat_gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.concourse_public_subnet.id}"

  tags = {
    Name = "Concourse NAT GW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.concourse_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.concourse_igw.id}"
  }

  tags = {
    Name = "public_subnet_route_table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.concourse_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = "${aws_nat_gateway.concourse_nat_gw.id}"
  }

  tags = {
    Name = "private_subnet_route_table"
  }
}

resource "aws_security_group" "bosh" {
  name        = "bosh"
  description = "bosh security group"
  vpc_id      = "${aws_vpc.concourse_vpc.id}"

  ingress {
    cidr_blocks = ["${var.vpc_cidr}"]
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["${var.vpc_cidr}"]
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 25555
    to_port     = 25555
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 6868
    to_port     = 6868
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = "${merge(var.tags, map("Name", "${var.env_name}-bosh-security-group"))}"
}

resource "aws_security_group" "concourse-web" {
  name        = "concourse-web"
  description = "concourse-web security group"
  vpc_id      = "${aws_vpc.concourse_vpc.id}"

  ingress {
    cidr_blocks = ["${var.vpc_cidr}"]
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "web"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    description = "uaa"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8844
    to_port     = 8844
    protocol    = "tcp"
    description = "credhub"
  }

  tags = "${merge(var.tags, map("Name", "${var.env_name}-concourse-web-security-group"))}"
}

output "concourse_ip" {
  value = "${aws_eip.concourse_eip.public_ip}"
}
output "bosh_ip" {
  value = "${aws_eip.bosh_eip.public_ip}"
}

output "public_subnet_id" {
  value = "${aws_subnet.concourse_public_subnet.id}"
}

output "private_subnet_id" {
  value = "${aws_subnet.concourse_private_subnet.id}"
}