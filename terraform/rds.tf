resource "aws_db_subnet_group" "ruby_db_subnet_group" {
  name       = "ruby-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Ruby DB Subnet Group"
  }
}


resource "aws_db_instance" "ruby_db" {
  identifier            = "ruby-app-db"
  engine                = "postgres"
  engine_version        = "13.18"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  storage_type          = "gp2"
  username              = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["username"]
  password              = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["password"]
  db_subnet_group_name  = aws_db_subnet_group.ruby_db_subnet_group.name
  vpc_security_group_ids = ["sg-0b4bdadc20b84a176"]
  skip_final_snapshot   = true    
}

resource "aws_cloudwatch_log_group" "ruby_app_log_group" {
  name = "/ecs/ruby-app"
  retention_in_days = 7
}
