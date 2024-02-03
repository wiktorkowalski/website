terraform {
  backend "s3" {
    bucket = "wiktorkowalski-terraform-state"
    key    = "website/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "wiktorkowalski-terraform-state"
    encrypt = false
  }
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.33.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
}

provider "aws" {
  alias   = "us-east-1"
  region  = "us-east-1"
}