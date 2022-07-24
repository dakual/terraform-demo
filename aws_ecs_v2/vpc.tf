resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr

  tags = {
    Env  = "production"
    Name = "vpc"
  }
}

# Create Public Subnet 1
resource "aws_subnet" "public_subnet" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = aws_vpc.default.id
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, 3 + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags   = {
    Env  = "production"
    Name = "public-subnet-1"
  }
}

# Create Private Subnet 1
resource "aws_subnet" "private_subnet" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = aws_vpc.default.id
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  
  tags = {
    Env  = "production"
    Name = "private-subnet-1"
  }
}


resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Env  = "production"
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "public" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Env  = "production"
    Name = "route-table-public"
  }

  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
  tags = {
    Env  = "production"
    Name = "route-table-private"
  }

  vpc_id = aws_vpc.default.id
}

# Associate Public Subnet to "Public Route Table"
resource "aws_route_table_association" "public_route_association" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnet to "Private Route Table"
resource "aws_route_table_association" "private_route_association" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = aws_route_table.private.id
}

resource "aws_main_route_table_association" "default" {
  route_table_id = aws_route_table.public.id
  vpc_id         = aws_vpc.default.id
}