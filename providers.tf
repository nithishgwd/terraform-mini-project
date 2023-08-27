# Terraform config

# terraform block with required providers(Ex: aws) for project 
terraform {
  # Required provider block
  required_providers {
    aws = {
      # Can specify source in this case its official AWS provider from harshicrop
      source = "hashicorp/aws"

      # terraform will find latest plugin of 5.x, constrain means to any version in 5.x series that is acceptable
      # =,>,<,=>,=<.~> all this constrains can be used
      version = "~>5.0"
    }
  }
}

# aws provider for perticular region 
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}


# An instance of aws provider is limited to one region 
# if need more than one region, we have to create seprate provider instance using alias argument
provider "aws" {
  alias  = "region2"
  region = "us-west-2" # Change to another desired region
}
