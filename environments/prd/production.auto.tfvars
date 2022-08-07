public_subnets = {
  default = ["10.200.0.0/24", "10.200.1.0/24"]
}

private_subnets = {
  default = ["10.200.2.0/24", "10.200.3.0/24"]
}

azs = {
  default = ["us-east-1a", "us-east-1b"]
}

region = "us-east-1"


tags = {
  owner          = "eanselmi@edrans.com"
  Name           = "onboarding"
  environment    = "tst"
  costCenter     = "SYSENG"
  tagVersion     = 1
  role           = "tst"
  project        = "onboarding"
  expirationDate = "12/12/2023"
}

alb = {
  name                       = "public-alb"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false

}

alb_target_group = {
  interval            = 10
  path                = "/"
  protocol            = "HTTP"
  timeout             = 5
  healthy_threshold   = 5
  unhealthy_threshold = 2
  name                = "ecs-instances-target"
  port                = 9090
  protocol            = "HTTP"
  target_type         = "instance"
  matcher             = "200,300,302"

}

public_alb_listener_http = {
  port     = "80"
  protocol = "HTTP"
  #type              = "redirect"
  type              = "forward"
  port_redirect     = "443"
  redirect_protocol = "HTTPS"
  status_code       = "HTTP_301"
}

public_alb_listener_https = {
  port            = "443"
  protocol        = "HTTPS"
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:947941747067:certificate/af8bf54c-9a00-4159-b2e6-1832ba666213"
  type            = "forward"
}

public_alb_sg = {
  name        = "public_alb_sg"
  description = "Allow HTTPS inbound traffic"
}

vpc = {
  cidr                 = "10.200.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

}

launch_configuration = {
  instance_type = "t2.medium"
}

asg = {
  min_size                         = 2
  max_size                         = 4
  health_check_type                = "EC2"
  warm_pool_state                  = "Stopped"
  warm_min_size                    = 2
  warm_max_group_prepared_capacity = 6
}

asg_sg = {
  name                 = "webserver_sg"
  description          = "Allow HTTPS inbound traffic from ALB"
  agent_from_port      = 9100
  agent_to_port        = 9100
  agent_protocol       = "tcp"
  prometheus_from_port = 9090
  prometheus_to_port   = 9090
  prometheus_protocol  = "tcp"

}

asg_tags_dynamic = [
  {
    name  = "environment"
    value = "prod"
  },
  {
    name  = "role"
    value = "production"
  },
  {
    name  = "Name"
    value = "PRD-ASG-WEB-SERVER"
  },
  {
    name  = "owner"
    value = "eanselmi@edrans.com"
  },
  {
    name  = "costCenter"
    value = "SYSENG"
  },
  {
    name  = "tagVersion"
    value = 1
  },
  {
    name  = "project"
    value = "onboarding"
  },
  {
    name  = "expirationDate"
    value = "12/12/2022"
  }
]

