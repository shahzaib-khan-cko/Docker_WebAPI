terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

module "vpc" {
  source = "./vpc"
}

# ===============================================================

resource "aws_ecs_cluster" "shahzaib_ecs_task_cluster" {
  name = "shahzaib_ecs_task_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  #   container_definitions = <<DEFINITION
  # [
  #   {
  #     "image": "registry.gitlab.com/architect-io/artifacts/nodejs-hello-world:latest",
  #     "cpu": 1024,
  #     "memory": 2048,
  #     "name": "hello-world-app",
  #     "networkMode": "awsvpc",
  #     "portMappings": [
  #       {
  #         "containerPort": 3000,
  #         "hostPort": 3000
  #       }
  #     ]
  #   }
  # ]
  # DEFINITION

  container_definitions = <<DEFINITION
[
  {
    "image": "528130383285.dkr.ecr.eu-west-2.amazonaws.com/shahzaib:ffc4843a1517e086bc010783b68f879367c55411",
    "cpu": 1024,
    "memory": 2048,
    "name": "hello-world-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "awslogs-shahzaib-webapi",
                    "awslogs-region": "eu-west-2",
                    "awslogs-stream-prefix": "awslogs-example"
                }
            }
  }
]
DEFINITION

  execution_role_arn = "arn:aws:iam::528130383285:role/ecsTaskExecutionRole"
}

# "environment": [
#         {
#         "name": "ASPNETCORE_URLS",
#         "value": "http://+:5000"
#       }
#     ]

# resource "aws_default_vpc" "default_vpc" {

# }

# resource "aws_default_subnet" "default_subnet_a" {
#     availability_zone = "eu-west-2a"
# }

# resource "aws_default_subnet" "default_subnet_b" {
#     availability_zone = "eu-west-2b"
# }
# resource "aws_default_subnet" "default_subnet_c" {
#     availability_zone = "eu-west-2c"
# }

resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = "${aws_ecs_cluster.shahzaib_ecs_task_cluster.id}"
  task_definition = "${aws_ecs_task_definition.hello_world.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["${module.vpc.public_subnet_a_id}", "${module.vpc.public_subnet_b_id}"]
    assign_public_ip = true
  }

  #   network_configuration {
  #     subnets         = ["${aws_default_subnet.default_subnet_a.id}, ${aws_default_subnet.default_subnet_b.id}, ${aws_default_subnet.default_subnet_c.id}"]
  #     assign_public_ip = true
  #   }

    load_balancer {
      target_group_arn = module.vpc.alb_target_group_arn
      container_name   = "hello-world-app"
      container_port   = 80
    }
  # depends_on = [
  #   module.vpc,
  #   aws_ecs_cluster.shahzaib_ecs_task_cluster,
  #   aws_ecs_task_definition.hello_world
  # ]
}

# =================================================
