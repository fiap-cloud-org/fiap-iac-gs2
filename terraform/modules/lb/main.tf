resource "aws_lb_target_group" "nagios" {
  name     = "nagios-tg"
  protocol = "HTTP"
  port     = 80
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "nagios" {
  for_each = var.target_instance_ids

  target_group_arn = aws_lb_target_group.nagios.arn
  target_id        = each.value
  port             = 80
}
