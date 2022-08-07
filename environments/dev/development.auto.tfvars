env = {
  name       = "dev"
  prefix     = "dev"
  region     = "us-east-1"
  key_name   = "development"
  project    = "template"
  costCenter = "CloudEng"
  owner      = "default"
}

vpc = {
  cidr_block = "10.100.0.0/16"
  newbits    = "3"
}

ecs_cluster = {
  asg_min_size                = "1"
  asg_max_size                = "1"
  asg_desired_capacity        = "1"
  name                        = "ecs-cluster"
  launch_config_instance_type = "t2.medium"
}
