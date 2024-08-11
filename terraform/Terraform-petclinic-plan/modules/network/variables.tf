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

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_az1" {
  type = string
}
variable "public_subnet_az2" {
  type = string
}

variable "private_subnet_az1" {
  type = string
}
variable "private_subnet_az2" {
  type = string
}

variable "eks_cluster_name" {
  description = "Name of the cluster for the subnet tags"
  type = string
}
