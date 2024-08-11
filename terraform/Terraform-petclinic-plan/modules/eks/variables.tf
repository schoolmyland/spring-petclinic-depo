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
# Instance type list

variable "instance_type_back" {
  type = list
}

variable "instance_type_front" {
  type = list
}

variable "instance_type_monitor" {
  type = list
}

variable "instance_type_monitorfront" {
  type = list
}

# id du groupe de sécurité public
variable "sn_pub_ids" {
  type = any
}
# id du groupe de sécurité privée
variable "sn_priv_ids" {
  type = any
}

variable "account_id" {
  type        = string
}

variable "operator_account" {
  type        = string
}
