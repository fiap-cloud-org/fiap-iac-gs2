# Application Load Balancer público na frente da interface web do Nagios.

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-sg-alb"
  description = "HTTP da internet para o ALB do Nagios"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP da internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP para as instancias da VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.name_prefix}-sg-alb"
  }
}

resource "aws_lb" "nagios" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "nagios" {
  name     = "${var.name_prefix}-nagios-tg"
  protocol = "HTTP"
  port     = 80
  vpc_id   = var.vpc_id

  # A página / é pública (index.html criado pelo user-data); /nagios pede login.
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.name_prefix}-nagios-tg"
  }
}

resource "aws_lb_target_group_attachment" "nagios" {
  for_each = var.target_instance_ids

  target_group_arn = aws_lb_target_group.nagios.arn
  target_id        = each.value
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nagios.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nagios.arn
  }
}
