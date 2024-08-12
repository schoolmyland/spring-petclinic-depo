variable "region" {
  description = "AWS région"
  default     = "eu-west-3"
  type        = string
}

variable "domain" {
  description = "Domain name created"
  default     = "pet-clinic-tpr.cloudns.ph"
  type        = string
}

variable "appname" {
  description = "Name of the app"
  default     = "Petclinic"
  type        = string
}

variable "customer1" {
  description = "Name of the first customer"
  default     = "bleu"
  type        = string
}

variable "customer2" {
  description = "Name of the second customer"
  default     = "violet"
  type        = string
}

variable "instance_type_back" {
  description = "instance type launch by the EKS node group"
  default     = ["t3.medium"]
  type        = list
}

variable "instance_type_front" {
  description = "instance type launch by the EKS node group"
  default     = ["t3.small"]
  type        = list
}

variable "instance_type_monitor" {
  description = "instance type launch by the EKS node group"
  default     = ["t3.small"]
  type        = list
}

variable "instance_type_monitorfront" {
  description = "instance type launch by the EKS node group"
  default     = ["t3.small"]
  type        = list
}

# variable reseau block address
variable "vpc_cidr" {
  description = " VPC CIDR"
  default     = "172.32.0.0/16"
  type = string
}

variable "public_subnet_az1" {
  description = " subnet public az1 network address"
  default     = "172.32.0.0/20"
  type = string
}
variable "public_subnet_az2" {
  description = " subnet public az2 network address"
  default     = "172.32.16.0/20"
  type = string
}

variable "private_subnet_az1" {
  description = " subnet private az1 network address"
  default     = "172.32.32.0/20"
  type = string
}
variable "private_subnet_az2" {
  description = " subnet private az2 network address"
  default     = "172.32.48.0/20" 
  type = string
}



# AWS id param

variable "AWS_ACCESS_KEY_ID" {
  description = "AWS ID KEY"
  default     = ""
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS SECRET KEY"
  default     = ""
  type        = string
}

variable "account_id" {
  description = "AWS account id, allow us to target account"
  default     = ""
  type        = string
}

variable "operator_account" {
  description = "AWS account name of the operator"
  default     = ""
  type        = string
}

### BDD

# Customer 1 db
variable "cus1db_name" {
  description = "Name for the database "
  default     = ""
  type        = string
}
variable "cus1db_user" {
  description = "User for the database"
  default     = ""
  type        = string
}
variable "cus1db_mdp" {
  description = "Password for the database"
  default     = ""
  type        = string
}

# Customer 2 db
variable "cus2db_name" {
  description = "Name for the database "
  default     = ""
  type        = string
}
variable "cus2db_user" {
  description = "User for the database"
  default     = ""
  type        = string
}
variable "cus2db_mdp" {
  description = "Password for the database"
  default     = ""
  type        = string
}

# Monitoring db
variable "mondb_name" {
  description = "Name for the database "
  default     = ""
  type        = string
}
variable "mondb_user" {
  description = "User for the database"
  default     = ""
  type        = string
}
variable "mondb_mdp" {
  description = "Password for the database"
  default     = ""
  type        = string
}

