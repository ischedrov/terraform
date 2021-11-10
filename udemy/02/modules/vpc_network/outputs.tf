//output "lbPublicIP" {
//  description = "Load Balancer Public IP"
//  value       = aws_lb.alb.dns_name
//}

output "available_azs" {
  value = {
    for subnet in aws_subnet.PublicSubnets :
    subnet.cidr_block => subnet.availability_zone
  }
}