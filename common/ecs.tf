resource "aws_ecs_cluster" "cluster" {
  name = "ecs-eanselmi"
  tags = {
    name = "ecs-cluster-eanselmi"
  }
}

resource "aws_ecs_service" "service_node_exporter" {
  cluster         = aws_ecs_cluster.cluster.id
  desired_count   = "2"
  launch_type     = "EC2"
  name            = "Webapp_node"
  task_definition = aws_ecs_task_definition.task_node_exporter.arn
}

resource "aws_ecs_task_definition" "task_node_exporter" {
  family                   = "Webapp_node"
  network_mode             = "bridge"
  memory                   = "1024"
  cpu                      = "512"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "Webapp"
      image     = "quay.io/prometheus/node-exporter:latest"
      cpu       = 10
      memory    = 128
      essential = true
      portMappings = [
        {
          containerPort = 9100
          hostPort      = 9100
        }
      ]
      dockerLabels = {
        PROMETHEUS_EXPORTER_PORT = "9100"
      }
    }
  ])
}


resource "aws_ecs_service" "services_prometheus" {
  cluster         = aws_ecs_cluster.cluster.id
  desired_count   = "2"
  launch_type     = "EC2"
  name            = "Webapp_prometheus"
  task_definition = aws_ecs_task_definition.task_prometheus.arn
}

resource "aws_ecs_task_definition" "task_prometheus" {
  family                   = "Webapp_prometheus"
  network_mode             = "bridge"
  memory                   = "1024"
  cpu                      = "512"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["EC2"]

  volume {
    name      = "prometheus-conf"
    host_path = "/etc/prometheus"
  }
  container_definitions = <<TASK_DEFINITION
  [
    {
      "name": "Webapp_prometheus",
      "image": "bitnami/prometheus",
      "cpu": 10,
      "memory": 128,
      "essential": true,
      "mountPoints": [{
        "sourceVolume": "prometheus-conf",
        "containerPath": "/etc/prometheus"
      }],
      "portMappings": [
        {
          "containerPort": 9090,
          "hostPort": 9090
        }
      ]
    },  
    {
      "name": "prometheus-ecs-discovery",
      "image": "tkgregory/prometheus-ecs-discovery:latest",
      "cpu": 10,
      "memory": 128,
      "essential": true,
      "command": [
        "-config.write-to=/etc/prometheus/ecs_file_sd.yml"
      ],
      "mountPoints": [{
        "sourceVolume": "prometheus-conf",
        "containerPath": "/etc/prometheus"
      }],
      "environment": [
      {"name": "AWS_REGION", "value": "${var.region}"}
    ]
    }
  ]
TASK_DEFINITION

}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "Webapp"
  tags = {
    Environment = "production"
  }
}
