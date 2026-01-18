output "public_dns_nginx1" {
  value       = "http://${aws_instance.nginx1.public_dns}:${var.http_port}"
  description = "The Public DNS of the website"
}

output "vpc_id" {
  value       = aws_vpc.app.id
  description = "The ID of the VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public_subnet1.id
  description = "The ID of the public subnet"
}
