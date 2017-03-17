resource "aws_iam_role" "iam_fleet_role" {
  name = "iam_fleet_role"
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

resource "aws_iam_role_policy_attachment" "iam_fleet_role_policy_attachment" {
  role = "${aws_iam_role.iam_fleet_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole"
}