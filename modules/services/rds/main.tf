resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [var.private_subnets[0], var.private_subnets[1]]
}

resource "aws_db_instance" "primary" {
  identifier           = "primary-db"
  engine               = "postgres"
  engine_version       = "14.3"
  instance_class       = "db.t2.micro"
  username             = "postgres"
  password             = "postgres"
  allocated_storage    = 20
  db_subnet_group_name = aws_db_subnet_group.main.name
  availability_zone    = "us-east-1a"
}

resource "aws_db_instance" "replica" {
  identifier           = "replica-db"
  replicate_source_db  = aws_db_instance.primary.identifier
  instance_class       = "db.t2.micro"
  db_subnet_group_name = aws_db_subnet_group.main.name
  availability_zone    = "us-east-1b"
}