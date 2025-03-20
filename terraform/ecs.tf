data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = aws_secretsmanager_secret.db_secret.id
}

resource "aws_ecs_cluster" "ruby_cluster" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "ruby_task" {
  depends_on = [aws_db_instance.ruby_db, aws_cloudwatch_log_group.ruby_app_log_group]
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn


  container_definitions = jsonencode([
    {
      name      = "init-db",
      image     = "${aws_ecr_repository.ruby_app.repository_url}:latest",
      essential = false,
      command   = ["bundle", "exec", "rake", "db:create", "db:migrate"],
      environment = [
        { name = "RAILS_ENV", value = "development" },
        { name = "DB_HOST", value =  split(":", aws_db_instance.ruby_db.endpoint)[0] },
        { name = "DB_USERNAME", value = "${aws_secretsmanager_secret.db_secret.arn}:username::" },
        { name = "DB_PASSWORD", value = "${aws_secretsmanager_secret.db_secret.arn}:password::" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}",
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "init-db"
        }
      }
    },
    {
      name      = "ruby-app",
      image     = "${aws_ecr_repository.ruby_app.repository_url}:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000
        }
      ],
       environment = [
        { name = "RAILS_ENV", value = "development" },
        { name = "DB_HOST", value =  split(":", aws_db_instance.ruby_db.endpoint)[0] },
        { name = "DB_USERNAME", value = "${aws_secretsmanager_secret.db_secret.arn}:username::" },
        { name = "DB_PASSWORD", value = "${aws_secretsmanager_secret.db_secret.arn}:password::" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}",
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "ruby-app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ruby_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ruby_cluster.id
  task_definition = aws_ecs_task_definition.ruby_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_id
    assign_public_ip = true
  }

   deployment_controller {
    type = "ECS"
  }
}
