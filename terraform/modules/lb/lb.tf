resource "aws_lb_target_group" "ec2_lb_tg" {
    name     = "ec2-lb-tg"
    protocol = "HTTP"
    port     = "80"
    vpc_id   = var.vpc10_id
}

resource "aws_lb_target_group_attachment" "ec2_lb_tg-instance_nagios_core" {
    target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
    target_id        = var.nagios-core_id
    port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_lb_tg-instance_node_a_id" {
    target_group_arn = aws_lb_target_group.ec2_lb_tg.arn
    target_id        = var.node_a_id
    port             = 80
}

