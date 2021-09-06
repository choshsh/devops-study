# private subnet에서 NAT를 통한 인터넷 엑세스 테스트

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

# EC2
resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.linux_sg_id]
  key_name                    = aws_key_pair.ssh-keypair.key_name
  tags = {
    Name = "public"
  }
}
output "public-ec2-public-ip" {
  value = aws_instance.public.public_ip
}
output "public-ec2-private-ip" {
  value = aws_instance.public.private_ip
}

resource "aws_instance" "private" {
  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  subnet_id                   = var.private_subnet_ids[0]
  key_name                    = aws_key_pair.ssh-keypair.key_name
  tags = {
    Name = "private"
  }
}
output "private-ec2-private-ip" {
  value = aws_instance.private.private_ip
}
