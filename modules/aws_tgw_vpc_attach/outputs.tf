output "vpc_attachment" {
  description = "Object with the Transit Gateway VPC attachment attributes"
  value       = aws_ec2_transit_gateway_vpc_attachment.this
}
