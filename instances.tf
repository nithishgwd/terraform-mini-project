/* Data Object, get ami value using AWS Systems Manager Parameter store
referance ---> https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html
*/

data "aws_ssm_parameter" "amz2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"

}

// Creating AWS instance 
resource "aws_instance" "GoApp_server_1" {
  # Uses default aws provider instance if not specified
  provider = aws

  # Amazon machine image value
  ami = nonsensitive(data.aws_ssm_parameter.amz2_linux.value)

  # 1 cpu and 1GB of ram part of T2 instance family
  instance_type = var.instance_type

  # Launching instance in subnet
  subnet_id = aws_subnet.public_subnet1.id

  # Security group associated with instance 
  vpc_security_group_ids = [aws_security_group.GoApp_sg.id]

  # This Block will be executed when instance is launched 
  user_data = <<EOF
    #! /bin/bash
    sudo yum update -y
    sudo yum install git -y
    sudo yum install golang -y
    git clone https://github.com/nithishgwd/go_webDev.git
    cd go_webDev/simple_go_web/
    chmod +x amz_GoApp_server1
    sudo nohup ./amz_GoApp_server1 &
    EOF

  # attaching tags to instance 
  tags = local.common_tags
}

resource "aws_instance" "GoApp_server_2" {

  ami                    = nonsensitive(data.aws_ssm_parameter.amz2_linux.value)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet2.id
  vpc_security_group_ids = [aws_security_group.GoApp_sg.id]


  user_data = <<EOF
    #! /bin/bash
    sudo yum update -y
    sudo yum install git -y
    sudo yum install golang -y
    git clone https://github.com/nithishgwd/go_webDev.git
    cd go_webDev/simple_go_web/
    chmod +x amz_GoApp_server2
    sudo nohup ./amz_GoApp_server2 &
    EOF

  tags = local.common_tags
}

