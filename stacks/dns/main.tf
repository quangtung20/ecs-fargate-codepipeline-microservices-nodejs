terraform {
  backend "s3" {
    bucket = "fgms-infra-05122023"
    key    = "dns.tfstate"
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


resource "aws_service_discovery_private_dns_namespace" "fgms_dns_discovery" {
  name        = var.fgms_private_dns_namespace
  description = "fgms dns discovery"
  vpc         = data.terraform_remote_state.vpc.outputs.fgms_vpc_id
}
