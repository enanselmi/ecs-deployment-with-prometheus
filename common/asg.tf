resource "aws_ebs_encryption_by_default" "ebs_default_enc" {
  enabled = true
}

resource "aws_launch_configuration" "ecs_hosts" {
  image_id        = data.aws_ami.amazon-linux-2-ecs.id
  instance_type   = var.launch_configuration.instance_type
  security_groups = [aws_security_group.ecs_instance_sg.id]
  user_data       = file("../../common/templates/user_data/ecs_hosts.sh")

  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs_instances_asg" {
  launch_configuration = aws_launch_configuration.ecs_hosts.id
  vpc_zone_identifier  = aws_subnet.private_subnets[*].id

  min_size = var.asg.min_size
  max_size = var.asg.max_size

  target_group_arns = [aws_lb_target_group.ecs_instances_target.arn]
  health_check_type = var.asg.health_check_type

  dynamic "tag" {
    for_each = var.asg_tags_dynamic
    content {
      key                 = tag.value.name
      value               = tag.value.value
      propagate_at_launch = true
    }
  }

}

resource "aws_security_group" "ecs_instance_sg" {
  name        = var.asg_sg.name
  description = var.asg_sg.description
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "${local.naming_prefix}-SG-ECS-INSTANCES"
  }
}

resource "aws_security_group_rule" "prometheus_agent_ingress" {
  type                     = "ingress"
  from_port                = var.asg_sg.agent_from_port
  to_port                  = var.asg_sg.agent_to_port
  protocol                 = var.asg_sg.agent_protocol
  source_security_group_id = aws_security_group.ecs_instance_sg.id
  security_group_id        = aws_security_group.ecs_instance_sg.id
}

resource "aws_security_group_rule" "prometheus_ingress" {
  type                     = "ingress"
  from_port                = var.asg_sg.prometheus_from_port
  to_port                  = var.asg_sg.prometheus_to_port
  protocol                 = var.asg_sg.prometheus_protocol
  source_security_group_id = aws_security_group.public_alb_sg.id
  security_group_id        = aws_security_group.ecs_instance_sg.id
}

resource "aws_security_group_rule" "ecs_instances_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_instance_sg.id
}

