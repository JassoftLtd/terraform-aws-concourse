resource "aws_db_instance" "concourse-db" {
  identifier           = "concourse-db"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "9.5.4"
  instance_class       = "db.t2.micro"
  name                 = "concourse"
  username             = "concourse"
  password             = "concourse"
  db_subnet_group_name = "${aws_db_subnet_group.concourse_rds_subnet_group.name}"
  parameter_group_name = "default.postgres9.5"
  vpc_security_group_ids = ["${aws_security_group.concourse_db_security_group.id}"]
  skip_final_snapshot = true
}