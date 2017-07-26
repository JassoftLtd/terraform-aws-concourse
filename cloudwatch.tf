resource "aws_cloudwatch_metric_alarm" "concourse_workers_high_cpu" {
  alarm_name          = "concourse-workers-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2Spot"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions {
    fleet_request_id = "${aws_spot_fleet_request.concourse_workers.id}"
  }

  alarm_description = "This metric monitors Concourse Worker cpu utilization"
  alarm_actions     = ["${aws_appautoscaling_policy.concourse_workers_scale.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "concourse_workers_low_cpu" {
  alarm_name          = "concourse-workers-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2Spot"
  period              = "360"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    fleet_request_id = "${aws_spot_fleet_request.concourse_workers.id}"
  }

  alarm_description = "This metric monitors Concourse Worker cpu utilization"
  alarm_actions     = ["${aws_appautoscaling_policy.concourse_workers_scale.arn}"]
}
