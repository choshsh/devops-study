# Security Group
#
# VPC Default : private cidr은 인바운드/아웃바운드 모두 허용
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
  vpc_id = aws_vpc.my-vpc.id
  name   = "linux-default"

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
