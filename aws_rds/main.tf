resource "aws_db_instance" "education" {
  identifier           = "education"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = aws_db_parameter_group.education.name
  db_subnet_group_name = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.education.id]  
  publicly_accessible = true
  skip_final_snapshot = true
}

resource "aws_db_parameter_group" "education" {
  name   = "rds-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}