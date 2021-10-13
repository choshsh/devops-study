locals {
  ports_in  = [22, 80, 443] # inbound 허용 포트
  ports_out = [0]           # outbound 허용 포트 (전체)
}

# Security Rule
#
# 내부 cidr은 인바운드/아웃바운드 모두 허용
resource "aws_security_group_rule" "private-ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.my-vpc.cidr_block]
  security_group_id = aws_vpc.my-vpc.default_security_group_id
}

resource "aws_security_group_rule" "private-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.my-vpc.cidr_block]
  security_group_id = aws_vpc.my-vpc.default_security_group_id
}

# Linux Default
resource "aws_security_group" "linux-default" {
  name   = "${var.global_name}-linux-default"
  vpc_id = aws_vpc.my-vpc.id

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

resource "aws_security_group" "allow_tls" {
  name        = "${var.global_name}-allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress = [
    {
      description      = "TLS from VPC"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = [aws_vpc.my-vpc.cidr_block]
      self             = false
      security_groups  = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
    },
    {
      description      = "k8s_node_port"
      from_port        = 30000
      to_port          = 32767
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.my-vpc.cidr_block]
      self             = false
      security_groups  = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
    }
  ]

  tags = merge(local.tags, {
    Name = "${var.workspace}-sg"
  })
  depends_on = [aws_vpc.my-vpc]
}
