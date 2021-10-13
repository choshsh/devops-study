resource "aws_lb" "public" {
  name               = var.global_name
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.public.*.id

  depends_on = [aws_subnet.public]
  tags = merge(local.tags, {
    Name = "${var.global_name}-nlb"
  })
}
