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

# data "aws_acm_certificate" "amazon_issued" {
#   domain      = "*.${var.domain}"
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true
# }

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.public.arn
#   port              = "80"
#   protocol          = "TCP"

#   default_action {
#     type = "forward"
#   }
# }

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.public.arn
#   port              = "443"
#   protocol          = "TLS"
#   certificate_arn   = data.aws_acm_certificate.amazon_issued.arn

#   default_action {
#     type = "forward"
#   }
# }
