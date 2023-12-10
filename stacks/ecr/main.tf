terraform {
  backend "s3" {
    bucket = "fgms-infra-05122023"
    key    = "ecr.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}



resource "aws_ecr_repository" "fgms-uno" {
  name = "fgms-uno"
}

resource "aws_ecr_repository" "fgms-due" {
  name = "fgms-due"
}

resource "aws_ecr_repository" "fgms-tre" {
  name = "fgms-tre"
}
