terraform {
  backend "s3" {
    bucket = "fgms-infra-05122023"
    key    = "services-tre.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}



data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "fgms-infra-05122023"
    key    = "vpc.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket = "fgms-infra-05122023"
    key    = "dns.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "fgms-infra-05122023"
    key    = "alb.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"
  config = {
    bucket = "fgms-infra-05122023"
    key    = "ecs.tfstate"
    region = "us-east-1"
  }
}




resource "aws_iam_policy" "fgms_tre_task_role_policy" {
  name        = "fgms_tre_task_role_policy"
  description = "fgms tre task role policy"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect : "Allow",
          Action : [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          Resource : "*"
        }
      ]
    }
  )
}


resource "aws_iam_role" "fgms_tre_task_role" {
  name = "fgms_tre_task_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect : "Allow",
          Principal : {
            Service : "ecs-tasks.amazonaws.com"
          },
          Action : [
            "sts:AssumeRole"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.fgms_tre_task_role.name
  policy_arn = aws_iam_policy.fgms_tre_task_role_policy.arn
}


resource "aws_ecs_task_definition" "fgms_tre_td" {
  family                   = "fgms_tre_td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.fgms_tre_task_role.arn

  container_definitions = jsonencode(
    [
      {
        cpu : 256,
        image : "quangtung20/tre:latest",
        memory : 512,
        name : "fgms-tre",
        networkMode : "awsvpc",
        portMappings : [
          {
            containerPort : 3000,
            hostPort : 3000
          }
        ]
      }
    ]
  )
}

resource "aws_ecs_service" "fgms_tre_td_service" {
  name            = "fgms_tre_td_service"
  cluster         = data.terraform_remote_state.ecs_cluster.outputs.fgms_ecs_cluster_id
  task_definition = aws_ecs_task_definition.fgms_tre_td.arn
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.ecs_tasks_sg_tre.id}"]
    subnets         = ["${data.terraform_remote_state.vpc.outputs.fgms_private_subnets_ids[0]}"]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.fgms_tre_service.arn
  }
}

resource "aws_security_group" "ecs_tasks_sg_tre" {
  name        = "ecs_tasks_sg_tre"
  description = "allow inbound access from the ALB only"
  vpc_id      = data.terraform_remote_state.vpc.outputs.fgms_vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = "3000"
    to_port     = "3000"
    cidr_blocks = ["13.0.0.0/16"]
  }

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_service_discovery_service" "fgms_tre_service" {
  name = var.fgms_tre_service_namespace

  dns_config {
    namespace_id = data.terraform_remote_state.dns.outputs.fgms_dns_discovery_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 2
  }
}

