locals {
  subnet_count_pair = 2 # (public, priate) subnet 페어의 개수
  cidr_block_split  = split(".", var.cidr_block)
  tags = {
    Type = "network"
  }
}

# 가용영역 검색
data "aws_availability_zones" "selected" {
  state = "available"
}

# VPC
resource "aws_vpc" "my-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "${var.global_name}-vpc"
  })
}

# Public
#
# Subnet : subnet_count_pair만큼 생성하며 각각 가용영역을 다르게 생성
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.my-vpc.id

  count             = local.subnet_count_pair
  cidr_block        = "${local.cidr_block_split[0]}.${local.cidr_block_split[1]}.${count.index}.0/27"
  availability_zone = data.aws_availability_zones.selected.names[count.index]

  tags = merge(local.tags, {
    Name = "${var.global_name}-public-${count.index}"
  })
}

# Internet Gateway : 인터넷 통신을 위한 게이트웨이
resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my-vpc.id

  tags = merge(local.tags, {
    Name = "${var.global_name}-internet-gateway"
  })
  depends_on = [aws_vpc.my-vpc]
}

# Public Route Table : public subnet에 적용할 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id

  tags = merge(local.tags, {
    Name = "${var.global_name}-public-route-table"
  })
  depends_on = [aws_internet_gateway.my-internet-gateway]
}

# Public Route : 인터넷 통신을 위해 [0.0.0.0/0 -> 인터넷 게이트웨이] 라우팅
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my-internet-gateway.id
  depends_on             = [aws_internet_gateway.my-internet-gateway]
}

# Public Route Table 연결 : public route table에 public subnet을 명시적으로 연결
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id

  count      = local.subnet_count_pair
  subnet_id  = aws_subnet.public[count.index].id
  depends_on = [aws_route.public]
}
