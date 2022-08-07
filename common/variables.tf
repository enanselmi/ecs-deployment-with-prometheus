variable "vpc" {
  description = "VPC Variables"
  type        = any

}

variable "public_subnets" {
  description = "List of public subnets"
  type        = any
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = any
}

variable "azs" {
  description = "List of AZs"
  type        = any
}

variable "region" {
  type        = string
  description = "Region where to deploy"
}

variable "tags" {
  description = "List of default tags"
  type        = map(any)
}

variable "alb" {
  description = "List of variables fot ALB"
  type        = any
}

variable "alb_target_group" {
  description = "List of variables fot ALB target group"
  type        = any
}

variable "public_alb_listener_http" {
  description = "List of variables fot ALB http listener"
  type        = any
}

variable "public_alb_listener_https" {
  description = "List of variables fot ALB https listener"
  type        = any
}

variable "public_alb_sg" {
  description = "List of variables fot ALB"
  type        = any
}

variable "launch_configuration" {
  description = "List of launch configuration variables"
  type        = any
}

variable "asg" {
  description = "List of ASG variables"
  type        = any
}

variable "asg_sg" {
  description = "List of ASG SG variables"
  type        = map(any)
}

variable "asg_tags_dynamic" {
  description = "List of tags for ASG"
  type        = list(map(string))
}


