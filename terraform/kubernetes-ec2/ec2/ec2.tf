locals {
  tags = {
    Service = "Kubernetes"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "ssh-keypair" {
  key_name   = "ssh-keypair"
  public_key = file("${path.module}/aws-key.pub")
}

// 마스터 노드
resource "aws_instance" "master" {
  count = var.master_node_count

  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = var.master_node_instance_type
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  key_name                    = aws_key_pair.ssh-keypair.key_name
  user_data                   = file("${path.module}/install_k8s.sh")
  vpc_security_group_ids      = [var.linux_sg_id, var.allow_tls_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.k8s-control-plane.name
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    tags = {
      EC2 = "${var.global_name}-master-${count.index}"
    }
  }
  tags = merge(local.tags, {
    Name = "${var.global_name}-master-${count.index}",
    Role = "master"
  })
  depends_on = [aws_key_pair.ssh-keypair]
}

// 워커 노드
resource "aws_instance" "worker" {
  count = var.worker_node_count

  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = var.worker_node_instance_type
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  key_name                    = aws_key_pair.ssh-keypair.key_name
  user_data                   = file("${path.module}/install_k8s.sh")
  vpc_security_group_ids      = [var.linux_sg_id, var.allow_tls_sg_id]
  iam_instance_profile        = aws_iam_instance_profile.k8s-node.name
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    tags = {
      EC2 = "${var.global_name}-worker-${count.index}"
    }
  }
  tags = merge(local.tags, {
    Name = "${var.global_name}-worker-${count.index}",
    Role = "Worker"
  })
  depends_on = [aws_key_pair.ssh-keypair]
}

# // Bestion EC2
# resource "aws_instance" "bestion" {
#   ami                         = data.aws_ami.amazon-linux-2.id
#   associate_public_ip_address = true
#   instance_type               = "t2.micro"
#   subnet_id                   = var.public_subnet_ids[0]
#   key_name                    = aws_key_pair.ssh-keypair.key_name
#   vpc_security_group_ids      = [var.linux_sg_id]
#   root_block_device {
#     volume_type           = "gp3"
#     delete_on_termination = true
#     tags = {
#       EC2 = "${var.global_name}-bestion"
#     }
#   }
#   tags = merge(local.tags, {
#     Name = "${var.global_name}-bestion",
#     Role = "Bestion"
#   })
#   depends_on = [aws_key_pair.ssh-keypair]
# }
