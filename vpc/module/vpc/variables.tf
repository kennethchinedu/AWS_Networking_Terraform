variable "region_main" {
  default = "us-east-1"
}

variable "cidr" {
  default = "172.10.0.0/16"
}

variable "availability_zone_a" {
  default = "us-east-1a" 
}

variable "availability_zone_b" {
  default = "us-east-1b" 
}

variable "ami" {
   description = "ami-06c68f701d8090592"
}

variable "instance_type" {
  default = "t2.micro"
}