# aws_lb
resource "aws_lb" "GoApp" {
  name = "tf-GoApp-web-alb"
  # Creating public facing load balancer(so false)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  # Delete loadbalancer when termination, protection is set to false
  enable_deletion_protection = false

  tags = local.common_tags

}

# aws_lb_target_group
resource "aws_lb_target_group" "GoApp_alb_tg" {
  name     = "tf-GoApp-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = local.common_tags
}


# aws_lb_listener
resource "aws_lb_listener" "GoApp_lb_l" {
  load_balancer_arn = aws_lb.GoApp.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.GoApp_alb_tg.arn
  }

  tags = local.common_tags
}

# aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "GoApp_server_1" {
  target_group_arn = aws_lb_target_group.GoApp_alb_tg.arn
  target_id        = aws_instance.GoApp_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "GoApp_server_2" {
  target_group_arn = aws_lb_target_group.GoApp_alb_tg.arn
  target_id        = aws_instance.GoApp_server_2.id
  port             = 80
}

