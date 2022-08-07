resource "aws_lb" "public_alb" {
  name               = var.alb.name
  internal           = var.alb.internal
  load_balancer_type = var.alb.load_balancer_type
  security_groups    = [aws_security_group.public_alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = var.alb.enable_deletion_protection
  tags = {
    Name = "public_alb"
  }
}

resource "aws_lb_target_group" "ecs_instances_target" {
  health_check {
    interval            = var.alb_target_group.interval
    path                = var.alb_target_group.path
    protocol            = var.alb_target_group.protocol
    timeout             = var.alb_target_group.timeout
    healthy_threshold   = var.alb_target_group.healthy_threshold
    unhealthy_threshold = var.alb_target_group.unhealthy_threshold
    matcher             = var.alb_target_group.matcher
  }


  name        = var.alb_target_group.name
  port        = var.alb_target_group.port
  protocol    = var.alb_target_group.protocol
  target_type = var.alb_target_group.target_type
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "public_alb_listener_http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = var.public_alb_listener_http.port
  protocol          = var.public_alb_listener_http.protocol

  default_action {
    type             = var.public_alb_listener_https.type
    target_group_arn = aws_lb_target_group.ecs_instances_target.arn
  }
}


resource "aws_security_group" "public_alb_sg" {
  name        = var.public_alb_sg.name
  description = var.public_alb_sg.description
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.naming_prefix}-SG-ALB"
  }
}
