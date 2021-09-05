locals {
  subnet_count_pair = 1
  ports_in          = [443, 80, 22]
  ports_out         = [0]
  tags = {
    Type = "network"
  }
}

data "aws_availability_zones" "available-zones" {
  state = "available"
}

# VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "192.168.0.0/16"
  tags = merge(local.tags, {
    Name = "${var.workspace}-vpc"
  })
}

### Public
# Subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.my-vpc.id
  count             = local.subnet_count_pair
  cidr_block        = "192.168.${count.index * 16}.0/20"
  depends_on        = [aws_subnet.private]
  availability_zone = data.aws_availability_zones.available-zones.names[count.index]
  tags = merge(local.tags, {
    Name = "${var.workspace}-public-${count.index}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my-vpc.id
  tags = merge(local.tags, {
    Name = "${var.workspace}-internet-gateway"
  })
  depends_on = [aws_vpc.my-vpc]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id
  tags = merge(local.tags, {
    Name = "${var.workspace}-public-route-table"
  })
  depends_on = [aws_internet_gateway.my-internet-gateway]
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my-internet-gateway.id
  depends_on             = [aws_internet_gateway.my-internet-gateway]
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  count          = local.subnet_count_pair
  subnet_id      = aws_subnet.public[count.index].id
  depends_on     = [aws_route.public]
}

# Elastic IP
resource "aws_eip" "my-eip" {
  tags = merge(local.tags, {
    Name = "${var.workspace}-eks-nat"
  })
}

# NAT Gateway
resource "aws_nat_gateway" "my-nat-gateway" {
  subnet_id         = aws_subnet.public[0].id
  connectivity_type = "public"
  allocation_id     = aws_eip.my-eip.id
  tags = merge(local.tags, {
    Name = "${var.workspace}-nat-gateway"
  })
  depends_on = [aws_subnet.public, aws_eip.my-eip]

}

### Private
# Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.my-vpc.id
  count             = local.subnet_count_pair
  cidr_block        = "192.168.${(count.index + local.subnet_count_pair) * 16}.0/20"
  availability_zone = data.aws_availability_zones.available-zones.names[count.index]
  tags = merge(local.tags, {
    Name = "${var.workspace}-private-${count.index}"
  })
  depends_on = [aws_vpc.my-vpc]

}


resource "aws_route_table_association" "private" {
  count          = local.subnet_count_pair
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_vpc.my-vpc.main_route_table_id # default
  depends_on     = [aws_route.private]
}

resource "aws_route" "private" {
  route_table_id         = aws_vpc.my-vpc.main_route_table_id # default
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my-nat-gateway.id
  depends_on             = [aws_nat_gateway.my-nat-gateway]
}

# Security Group
resource "aws_security_group" "default-sg" {
  vpc_id = aws_vpc.my-vpc.id
  name   = "default-sg"

  dynamic "ingress" {
    for_each = toset(local.ports_in)
    content {
      description = "Default Allow Port In"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = toset(local.ports_out)
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = merge(local.tags, {
    Name = "${var.workspace}-sg"
  })
  depends_on = [aws_vpc.my-vpc]
}
