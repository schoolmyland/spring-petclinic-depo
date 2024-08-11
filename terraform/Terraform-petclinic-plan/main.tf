
provider "aws" {
  region     = var.region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# Recupère les AZ avec le statut disponible
data "aws_availability_zones" "available" {}

# appel du modules networking
module "networking" {
  source             = "./modules/network"
  appname            = var.appname
  customer1          = var.customer1
  customer2          = var.customer2
  vpc_cidr           = var.vpc_cidr
  public_subnet_az1  = var.public_subnet_az1
  public_subnet_az2  = var.public_subnet_az2
  private_subnet_az1 = var.private_subnet_az1
  private_subnet_az2 = var.private_subnet_az2
  az_list            = [element(data.aws_availability_zones.available.names, 0), element(data.aws_availability_zones.available.names, 1)]
  eks_cluster_name   = module.eks.cluster_name
}


# appel du modules rds
module "rds" {
  source     = "./modules/rds"
  appname    = var.appname
  customer1  = var.customer1
  customer2  = var.customer2
  cus1db_name = var.cus1db_name
  cus1db_user = var.cus1db_user
  cus1db_mdp = var.cus1db_mdp
  cus2db_name = var.cus2db_name
  cus2db_user = var.cus2db_user
  cus2db_mdp = var.cus2db_mdp
  mondb_name = var.mondb_name
  mondb_user = var.mondb_user
  mondb_mdp = var.mondb_mdp
 
  vpc        = module.networking.vpc
  sg_bdd_id  = module.networking.sg_bdd_id
  bdd_sn_gn  = module.networking.bdd_subnet_group_name
  az_list    = [element(data.aws_availability_zones.available.names, 0), element(data.aws_availability_zones.available.names, 1)]
}

module "eks" {
  source     = "./modules/eks"
  appname  = var.appname
  customer1  = var.customer1
  customer2  = var.customer2  
  sn_priv_ids = module.networking.sn_priv_ids
  sn_pub_ids  = module.networking.sn_pub_ids
  instance_type_back = var.instance_type_back
  instance_type_front = var.instance_type_front
  instance_type_monitor = var.instance_type_monitor
  instance_type_monitorfront = var.instance_type_monitorfront
  account_id = var.account_id
  operator_account = var.operator_account
  az_list    = [element(data.aws_availability_zones.available.names, 0), element(data.aws_availability_zones.available.names, 1)]
}

module "route53" {
  source     = "./modules/route53"
  appname  = var.appname
  customer1  = var.customer1
  customer2  = var.customer2  
  eks_cluster_name   = module.eks.cluster_name
  domain = var.domain
    account_id = var.account_id
}



