# Declare the data source for availability zone
data "aws_availability_zones" "available" {
  state = "available"
}

# Creating virtual private cloud(logically isolated virtual network we define)
resource "aws_vpc" "vpc" {
  # Class A IPv4 Classless inter-Domain Routing, 65,536 IP Address 
  cidr_block = "10.0.0.0/16"

  # Dns Resolution(vpc internal) Enabled by Default but not DNS Hostnames(Domain name system)
  enable_dns_hostnames = true

  # Tags to lable and categorize resource(organzing, identifying, and managing resource)
  tags = local.common_tags

}

# Communication b/w VPC and the Internet
resource "aws_internet_gateway" "igw" {
  # attaching to vpc 
  vpc_id = aws_vpc.vpc.id
}

# creating public subnets
resource "aws_subnet" "public_subnet1" {
  # attach to vpc 
  vpc_id = aws_vpc.vpc.id

  # subnet having 256 ips out of 65,536 IP(VPC), 4 reserved ips Network(10.0.0.0),Gateway(10.0.0.1),reserved(.2), Broadcast address(.255)
  cidr_block = var.vpc_subnets_cidr_block[0]

  # If need to have public ip for instance while launching in subnet inside VPC(Auto assign IP)
  map_public_ip_on_launch = true

  # availibility zone in which subnet is created 
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = local.common_tags
}

resource "aws_subnet" "public_subnet2" {

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_subnets_cidr_block[1]
  map_public_ip_on_launch = var.map_public_ip_on_launch

  # This Subnet launch on diffrent avavlability zone
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = local.common_tags

}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    # destination
    cidr_block = "0.0.0.0/0"
    # target
    gateway_id = aws_internet_gateway.igw.id
  }

}

# can assosiate subntes to route table
resource "aws_route_table_association" "rt_subnet1" {
  # adding subnet to private route table
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.public_subnet1.id
}

resource "aws_route_table_association" "rt_subnet2" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.public_subnet2.id
}

# Security Groups

# GoApp security group
resource "aws_security_group" "GoApp_sg" {
  # name of security group
  name = "GoApp-sg"

  # security group will be created inside vpc
  vpc_id = aws_vpc.vpc.id

  # ingress block defines a rule from allowing incoming traffic to resource with this sg
  # HTTP access from anywhere
  ingress {
    # From and To specify the port range for allowed inbound rule 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Allows traffic from Address that are inside the vpc 
    cidr_blocks = [var.vpc_cidr_block]
  }

  #SSH access 
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress outgoin traffic from resource, for internet access
  egress {
    from_port = 0
    to_port   = 0
    # -1 All protocol is allowed for outbound traffic
    protocol = "-1"
    # access from anywhere is not recmmended for production, can replace with your public ip/32
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags

}

# ALB security Groups
resource "aws_security_group" "alb_sg" {

  name   = "GoApp-alb-sg"
  vpc_id = aws_vpc.vpc.id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
