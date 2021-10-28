locals {
  subnet_count_pair = 2         # (public, priate) subnet 페어의 개수
  ports_in          = [80, 443] # inbound 허용 포트
  ports_out         = [0]       # outbound 허용 포트 (전체)
  cidr_block_split  = split(".", var.cidr_block)
  tags = {
    Type = "network"
  }
}

# 가용영역 검색
data "aws_availability_zones" "available-zones" {
  state = "available"
}

# VPC
resource "aws_vpc" "my-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "${var.workspace}-vpc"
  })
}

# AWS에서 2개의 public subnet과 2개의 private subnet로 eks vpc를 구성하는 것을 추천
# (https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/create-public-private-vpc.html)

# Public
#
# Subnet : subnet_count_pair만큼 생성하며 각각 가용영역을 다르게 생성
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.my-vpc.id

  count             = local.subnet_count_pair
  cidr_block        = "${local.cidr_block_split[0]}.${local.cidr_block_split[1]}.${count.index}.0/27"
  availability_zone = data.aws_availability_zones.available-zones.names[count.index]

  tags = merge(local.tags, {
    Name = "${var.workspace}-public-${count.index}"
  })
  depends_on = [aws_subnet.private]
}

# Internet Gateway : 인터넷 통신을 위한 게이트웨이
resource "aws_internet_gateway" "my-internet-gateway" {
  vpc_id = aws_vpc.my-vpc.id

  tags = merge(local.tags, {
    Name = "${var.workspace}-internet-gateway"
  })
  depends_on = [aws_vpc.my-vpc]
}

# Public Route Table : public subnet에 적용할 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc.id

  tags = merge(local.tags, {
    Name = "${var.workspace}-public-route-table"
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

# Elastic IP : NAT gateway에 사용할 public IP
resource "aws_eip" "my-eip" {
  tags = merge(local.tags, {
    Name = "${var.workspace}-eks-nat"
  })
}

# NAT Gateway : [private subnet -> 인터넷] 통신을 위한 NAT 게이트웨이
resource "aws_nat_gateway" "my-nat-gateway" {
  subnet_id         = aws_subnet.public[0].id
  connectivity_type = "public"
  allocation_id     = aws_eip.my-eip.id

  tags = merge(local.tags, {
    Name = "${var.workspace}-nat-gateway"
  })
  depends_on = [aws_subnet.public, aws_eip.my-eip]
}

# Private
#
# Subnet : subnet_count_pair만큼 생성하며 각각 가용영역을 다르게 생성
resource "aws_subnet" "private" {
  vpc_id = aws_vpc.my-vpc.id

  count             = local.subnet_count_pair
  cidr_block        = "${local.cidr_block_split[0]}.${local.cidr_block_split[1]}.${count.index + local.subnet_count_pair}.0/27"
  availability_zone = data.aws_availability_zones.available-zones.names[count.index]

  tags = merge(local.tags, {
    Name                              = "${var.workspace}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = 1
  })
  depends_on = [aws_vpc.my-vpc]
}

# Private Route Table 연결 : private(default) route table에 private subnet을 명시적으로 연결
resource "aws_route_table_association" "private" {
  route_table_id = aws_vpc.my-vpc.main_route_table_id # default

  count      = local.subnet_count_pair
  subnet_id  = aws_subnet.private[count.index].id
  depends_on = [aws_route.private]
}

# Private Route : 인터넷 통신을 위해 [0.0.0.0/0 -> NAT 게이트웨이] 라우팅
resource "aws_route" "private" {
  route_table_id         = aws_vpc.my-vpc.main_route_table_id # default
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my-nat-gateway.id
  depends_on             = [aws_nat_gateway.my-nat-gateway]
}

