resource "aws_security_group" "db_instance" {
  vpc_id = aws_vpc.default.id
  name = "security-group--db-instance"
  description = "security-group--db-instance"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
  }

  tags = {
    Env  = "production"
    Name = "security-group--db-instance"
  }
}

resource "aws_db_subnet_group" "default" {
  name = "db-subnet-group"

  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Env  = "production"
    Name = "db-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  identifier              = "development"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  db_name                 = "mydb"
  username                = "admin"
  password                = "12345678"
  parameter_group_name    = aws_db_parameter_group.pg.name
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.db_instance.id]  
  #publicly_accessible     = true
  skip_final_snapshot     = true
}

resource "aws_db_parameter_group" "pg" {
  name   = "rds-pg"
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}