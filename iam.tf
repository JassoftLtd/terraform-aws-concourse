resource "aws_iam_role" "concourse_worker_role" {
  name = "concourse_worker_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "Service": [
            "spotfleet.amazonaws.com",
            "ec2.amazonaws.com"
          ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "concourse_worker_role_policy_attachment" {
  role       = "${aws_iam_role.concourse_worker_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole"
}

resource "aws_iam_instance_profile" "concourse_profile" {
  name = "concourse_profile"
  role = "${aws_iam_role.concourse_role.name}"
}

resource "aws_iam_role" "concourse_role" {
  name = "concourse_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "concourse_role" {
  "statement" = {
    "effect" = "Allow"

    "actions" = [
      "s3:*",
    ]

    "resources" = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "concourse_role" {
  name   = "concourse_role"
  role   = "${aws_iam_role.concourse_role.id}"
  policy = "${data.aws_iam_policy_document.concourse_role.json}"
}
