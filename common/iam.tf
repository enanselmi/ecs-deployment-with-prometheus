data "aws_iam_policy_document" "ecs-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ssm_managed_instance_policy" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ecs-service-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-instance-role" {
  name               = "ecs-instance-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs-instance-policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_policy" {
  role       = aws_iam_role.ecs-instance-role.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_policy.arn
}

resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs-instance-role.id

}

resource "aws_iam_policy" "ecs_task_policy" {
  name = "ecs_task_policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEcsTaskPolicy",
        "Effect" : "Allow",
        "Action" : [
          "ecs:ListClusters",
          "ecs:ListTasks",
          "ecs:DescribeTask",
          "ec2:DescribeInstances",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}



