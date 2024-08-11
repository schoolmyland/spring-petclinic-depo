output "vpc" {
  description = "VPC as object"
  value = module.vpc
}


output "sg_bdd_id" {
    description = "Security group RDS"
  value = aws_security_group.allow_bdd_priv.id
}

output "sn_priv_ids" {
  description = "Subnet private IDs"
  value = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
}

output "sn_pub_ids" {
  description = "Subnet public IDs"
  value = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
}

output "bdd_subnet_group_name" {
  description = "Subnet group name of the Database"
  value       = aws_db_subnet_group.bdd_subnet_group.name
}
