terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.62"
    }
  }

  # Configuração parcial: bucket, tabela de lock e região vêm do backend.hcl
  # (terraform init -backend-config=backend.hcl).
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
