output "aws_instance_public_dns" {
  # fetch loadbalancer domain name 
  value = aws_lb.GoApp.dns_name
  description = "Public DNS for application load balancer"
}