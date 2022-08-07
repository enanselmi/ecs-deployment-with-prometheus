#!/bin/bash
echo ECS_CLUSTER=ecs-eanselmi >> /etc/ecs/ecs.config
mkdir -p /etc/prometheus/
cat <<< '
scrape_configs:
- job_name: ecs
  file_sd_configs:
    - files:
      - /etc/prometheus/ecs_file_sd.yml
      refresh_interval: 10m
  # Drop unwanted labels using the labeldrop action
  metric_relabel_configs:
    - regex: task_arn
      action: labeldrop
' > /etc/prometheus/prometheus.yml
