resource "aws_appautoscaling_target" "concourse_workers_target" {
  min_capacity       = "${var.concourse_workers_min_instances}"
  max_capacity       = "${var.concourse_workers_max_instances}"
  resource_id        = "spot-fleet-request/${aws_spot_fleet_request.concourse_workers.id}"
  role_arn           = "${aws_iam_role.concourse_workers_scaling.arn}"
  scalable_dimension = "ec2:spot-fleet-request:TargetCapacity"
  service_namespace  = "ec2"
}

resource "aws_appautoscaling_policy" "concourse_workers_scale" {
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Maximum"
  name                    = "concourse-workers-scaling"
  resource_id             = "spot-fleet-request/${aws_spot_fleet_request.concourse_workers.id}"
  scalable_dimension      = "ec2:spot-fleet-request:TargetCapacity"
  service_namespace       = "ec2"

  step_adjustment {
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 10
    scaling_adjustment          = 1
  }

  step_adjustment {
    metric_interval_lower_bound = 10
    metric_interval_upper_bound = 20
    scaling_adjustment          = 2
  }

  step_adjustment {
    metric_interval_lower_bound = 20
    scaling_adjustment          = 3
  }

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }

  depends_on = ["aws_appautoscaling_target.concourse_workers_target"]
}

resource "aws_iam_role" "concourse_workers_scaling" {
  name = "iam_for_concourse_workers_scaling"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["application-autoscaling.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "concourse_workers_scaling" {
  "statement" = {
    "effect" = "Allow"

    "actions" = [
      "application-autoscaling:RegisterScalableTarget",
      "cloudwatch:DescribeAlarms",
      "ec2:DescribeSpotFleetRequests",
      "ec2:ModifySpotFleetRequest",
    ]

    "resources" = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "concourse_workers_scaling" {
  name   = "iam_for_concourse_workers_scaling"
  role   = "${aws_iam_role.concourse_workers_scaling.id}"
  policy = "${data.aws_iam_policy_document.concourse_workers_scaling.json}"
}
