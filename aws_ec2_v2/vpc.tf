# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc-cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "Test_VPC"
  }
}

# Create Internet Gateway and Attach it to VPC
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway"
  }
} 

# Create Route Table and Add Public Route
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Associate Public Subnet 1 to "Public Route Table"
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  #count          = "${length(data.aws_availability_zones.available.names)}"
  #subnet_id      = "${element(aws_subnet.public-subnet-1.*.id, count.index)}"
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}

# Create Public Subnet 1
resource "aws_subnet" "public-subnet-1" {
  #count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.Public_Subnet_1}"
  #availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags   = {
    Name = "public-subnet-1"
  }
}

# Create Private Subnet 1
resource "aws_subnet" "private-subnet-1" {
  #count                    = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                   = "${aws_vpc.vpc.id}"
  cidr_block               = "${var.Private_Subnet_1}"
  #availability_zone        = "${element(data.aws_availability_zones.available.names, count.index)}"
  availability_zone        = "eu-west-2a"
  map_public_ip_on_launch  = false
  
  tags = {
    Name = "private-subnet-1"
  }
}