provider "aws" {
  region = "us-east-1"
}

module "app-deployment" {
    source = "./module/vpc" 
    ami = "ami-06c68f701d8090592"
    instance_type = "t2.micro"
}