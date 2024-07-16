provider "aws" {
  region = var.region_main
}

#creating vpc
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  

  tags = {
    Name = "myvpc"
  }
}

#This subnet automatically assigns public ip to any Ec2 launched into it 
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.myvpc.id  
  cidr_block = "172.10.1.0/24"
  availability_zone = var.availability_zone_a
  map_public_ip_on_launch = true
}

#This subnet does not assign public ip to Ec2 instances
resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.myvpc.id   
  cidr_block = "172.10.2.0/24"
  availability_zone = var.availability_zone_b 
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.myvpc.id
}

#Route table for our vpc
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id  
    #This internet gateway allows all network access to our vpc
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "tf_project_rt"
  }
}


# Associating this route table with our subnet
resource "aws_route_table_association" "rt_association1" {
  subnet_id      = aws_subnet.subnet1.id  
  route_table_id = aws_route_table.rt.id
}


# resource "aws_route_table_association" "rt_association2" {
#   subnet_id      = aws_subnet.subnet2.id    
#   route_table_id = aws_route_table.rt.id
# }

#Defining NAT gateway for private subnet
resource "aws_eip" "nat_eip" {
  domain      = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet2.id  
}
#route table for private subnet
resource "aws_route_table" "private_subnet_rt" {
  vpc_id = aws_vpc.myvpc.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private_subnet_rt"
  }
}
#route table association foor private subet
resource "aws_route_table_association" "private_subnet_rt_association" {
  subnet_id      = aws_subnet.subnet2.id 
  route_table_id = aws_route_table.private_subnet_rt.id
}

# Creating security group with multiple ingress rules
resource "aws_security_group" "sg" {
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id  



  ingress {
    description = "HTTP TLS to VPC"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#Allow all traffic
  egress {
    description = "Allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#launching Ec2 into subnets
resource "aws_instance" "server1" {
  vpc_security_group_ids = [aws_security_group.sg.id ]
  ami = var.ami
  instance_type = var.instance_type 
  subnet_id = aws_subnet.subnet1.id    
}

resource "aws_instance" "server2" {
  vpc_security_group_ids = [aws_security_group.sg.id ]
  ami = var.ami
  instance_type = var.instance_type 
  subnet_id = aws_subnet.subnet2.id    
}