# -------------------------------------------------------------------------------
# Security Groups
# -------------------------------------------------------------------------------
resource "aws_security_group" "eks_node" {
  name_prefix = "${var.cluster_name}-node-"
  vpc_id      = var.vpc_id

  ingress {
    description = "Self"

    from_port = 0
    to_port   = 0
    protocol  = "all"
    self      = true
  }

  egress {
    description = "All traffic"

    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                     = "${var.cluster_name}-node"
    "karpenter.sh/discovery" = var.cluster_name
  }

  lifecycle {
    ignore_changes = [ingress]
  }
}

resource "aws_security_group_rule" "eks_cluster_to_node" {
  description              = "Cluster API to Node"
  security_group_id        = aws_security_group.eks_node.id
  source_security_group_id = module.eks.cluster_security_group_id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "all"
}