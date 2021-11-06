resource "aws_lb" "public" {
  name               = var.global_name
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  tags = merge(local.tags, {
    Name = "${var.global_name}-nlb"
  })
}

data "aws_acm_certificate" "amazon_issued" {
  domain      = "*.${var.domain}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = data.aws_acm_certificate.amazon_issued.arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_target_group" "http" {
  name     = "http"
  port     = 30080
  protocol = "TCP"
  health_check {
    protocol = "TCP"
    port     = 30021
  }
  vpc_id = var.vpc_id
}

resource "aws_lb_target_group" "https" {
  name     = "https"
  port     = 30443
  protocol = "TCP"
  vpc_id   = var.vpc_id
  health_check {
    protocol = "TCP"
    port     = 30021
  }
}

resource "aws_lb_target_group_attachment" "http-master" {
  count = var.master_node_count

  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.master[count.index].id
  port             = 30080

  depends_on = [aws_instance.master]
}

resource "aws_lb_target_group_attachment" "https-master" {
  count = var.master_node_count

  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.master[count.index].id
  port             = 30443

  depends_on = [aws_instance.master]
}

resource "aws_lb_target_group_attachment" "http-worker" {
  count = var.worker_node_count

  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.worker[count.index].id
  port             = 30080

  depends_on = [aws_instance.worker]
}

resource "aws_lb_target_group_attachment" "https-worker" {
  count = var.worker_node_count

  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.worker[count.index].id
  port             = 30443

  depends_on = [aws_instance.worker]
}
