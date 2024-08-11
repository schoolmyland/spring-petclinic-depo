# environnement de déploiement
variable "appname" {
  type = string
}


variable "customer1" {
  type        = string
}

variable "customer2" {
  type        = string
}

variable "az_list" {
  type = list  
}

# Customer 1 db
variable "cus1db_name" {
  type        = string
}
variable "cus1db_user" {
  type        = string
}
variable "cus1db_mdp" {
  type        = string
}

# Customer 2 db
variable "cus2db_name" {
  type        = string
}
variable "cus2db_user" {
  type        = string
}
variable "cus2db_mdp" {
  type        = string
}

# Monitoring db
variable "mondb_name" {
  type        = string
}
variable "mondb_user" {
  type        = string
}
variable "mondb_mdp" {
  type        = string
}

# VPC
variable "vpc" {
  type = any
}
# id du groupe de sécurité BDD
variable "sg_bdd_id" {
  type = any
}

variable "bdd_sn_gn" {
  description = "Subnet group name of the Database"
  type        = string
}
