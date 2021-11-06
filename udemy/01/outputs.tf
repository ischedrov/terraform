output "webServer" {
  description = "EC2 Instance ID"
  value       = aws_instance.webServer.id
  sensitive = true
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.webServer.public_ip
}

output "availableAZs" {
  description = "List Available AZs"
  value = data.aws_availability_zones.availableAZs.names
}

output "latestAmazonLinux" {
  description = "Most Recent Amazon Linux"
  value = data.aws_ami.latestAmazonLinux.description
}

output "password" {
  description = "Generated password"
  value = random_password.testPassword
  sensitive = true 
}