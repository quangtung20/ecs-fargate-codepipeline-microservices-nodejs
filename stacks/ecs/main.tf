terraform {
  backend "s3" {
    bucket = "fgms-infra-05122023"
    key    = "ecs.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}


resource "aws_ecs_cluster" "fgms_ecs_cluster" {
  name = "fgms_ecs_cluster"
}
