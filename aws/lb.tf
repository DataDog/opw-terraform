resource "aws_lb" "opw" {
  name                             = "opw-lb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.subnet-ids
  enable_cross_zone_load_balancing = var.cross-zone-lb
}

resource "aws_lb_listener" "opw-tcp" {
  for_each = local.tcp-ports

  load_balancer_arn = aws_lb.opw.arn

  protocol = "TCP"
  port     = tonumber(each.value)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.opw-tcp[each.key].arn
  }
}

resource "aws_lb_target_group" "opw-tcp" {
  for_each = local.tcp-ports

  port     = tonumber(each.value)
  protocol = "TCP"
  vpc_id   = var.vpc-id

  depends_on = [
    aws_lb.opw
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "opw-tcp" {
  for_each = local.tcp-ports

  autoscaling_group_name = aws_autoscaling_group.opw.name
  lb_target_group_arn    = aws_lb_target_group.opw-tcp[each.value].arn
}

resource "aws_lb_listener" "opw-udp" {
  for_each = local.udp-ports

  load_balancer_arn = aws_lb.opw.arn

  protocol = "UDP"
  port     = tonumber(each.value)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.opw-udp[each.key].arn
  }
}

resource "aws_lb_target_group" "opw-udp" {
  for_each = local.udp-ports

  port     = tonumber(each.value)
  protocol = "UDP"
  vpc_id   = var.vpc-id

  depends_on = [
    aws_lb.opw
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "opw-udp" {
  for_each = local.udp-ports

  autoscaling_group_name = aws_autoscaling_group.opw.name
  lb_target_group_arn    = aws_lb_target_group.opw-udp[each.value].arn
}
