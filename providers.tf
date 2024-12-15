terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.64.0"
    }
  }

  cloud {

    organization = "FIAP-Lanchonete-G41"

    workspaces {
      name = "lambda-authorizer"
    }
  }

}

provider "aws" {
  region = "us-east-1"
}
