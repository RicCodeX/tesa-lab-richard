output "public_ip" {
  value       = aws_instance.richard_ec2.public_ip
  description = "Public IP of Richard EC2"
}

output "public_dns" {
  value       = aws_instance.richard_ec2.public_dns
  description = "Public DNS of Richard EC2"
}

output "ssh_command" {
  value       = "ssh -i ${path.module}/${var.name_prefix}-key.pem ubuntu@${aws_instance.richard_ec2.public_ip}"
  description = "Quick SSH command"
}
