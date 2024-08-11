

# appel du module vpc qu'on va importer grâce à la commande terraform init, le lien du module vous fournit une documentation du module vpc "terraform-aws-modules/vpc/aws"
module "vpc" {
  source = "terraform-aws-modules/vpc/aws" #chemin depuis le registre .s'il était en local on aurait du écrire "./terraform-aws-modules/vpc/aws"
  name                             = "${var.appname}-vpc"
  cidr                             = var.vpc_cidr
  azs                              = var.az_list
  # NECESSARY OPTION OR Node group creation will fail "  Instances failed to join the kubernetes cluster "
  enable_dns_hostnames = true
  enable_dns_support   = true

# tag kubernetes  
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }


}



resource "aws_internet_gateway" "web_gateway" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name        = "${var.appname}-internet-gateway"
  }
}



#---------------
#   SUBNET
#---------------

#----Pub-AZ1

resource "aws_subnet" "public_subnet_az1" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.public_subnet_az1
  availability_zone = var.az_list[0] 
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.appname}-public-subnet-az1"
  }
}
 
resource "aws_eip" "eip_az1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.web_gateway]

  tags = {
    Name        = "${var.appname}-eip-AZ1"
  }
}

# Creation NAT_gateway sur le public subnet az1
resource "aws_nat_gateway" "nat_az1" {
  allocation_id = aws_eip.eip_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags = {
    Name        = "${var.appname}-nat-gateway-AZ1"
  }
}



#----Pub-AZ2

resource "aws_subnet" "public_subnet_az2" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.public_subnet_az2
  availability_zone = var.az_list[1] 
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.appname}-public-subnet-az2"
  }
}

resource "aws_eip" "eip_az2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.web_gateway]
  tags = {
    Name        = "${var.appname}-eip-AZ2"
  }
}

resource "aws_nat_gateway" "nat_az2" {
  allocation_id = aws_eip.eip_az2.id
  subnet_id     = aws_subnet.public_subnet_az2.id

  tags = {
    Name        = "${var.appname}-nat-gateway-AZ2"
  }
}


#---Private

resource "aws_subnet" "private_subnet_az1" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.private_subnet_az1
  availability_zone = var.az_list[0] 
  map_public_ip_on_launch = false
  
  tags = {
    Name = "${var.appname}-private-subnet-az1"
  }
}

resource "aws_subnet" "private_subnet_az2" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.private_subnet_az2
  availability_zone = var.az_list[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.appname}-private-subnet-az2"
  }
}

#--------------
# GROUP 
#--------------



# Authorize the connection from the privates subnets 
resource "aws_security_group" "allow_bdd_priv" {
  name        = "${var.appname}-allow_bdd_priv"
  description = "authorize trafic from the privates subnets"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "DB trafic only from private subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_az1,var.private_subnet_az2]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.appname}-allow_bdd_priv"
  }
}


# subnet group BDD

resource "aws_db_subnet_group" "bdd_subnet_group" {
  name       = "db_priv_subgroup"
  subnet_ids = ["${aws_subnet.private_subnet_az1.id}", "${aws_subnet.private_subnet_az2.id}"]

  tags = {
    Name = "bdd_rds_group"
  }
}

#-------------------------------
# ROUTE TABLE
#-------------------------------

#--- Pub subnet

resource "aws_route_table" "public_rt" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Name        = "${var.appname}-public-route-table" 
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web_gateway.id
}

resource "aws_route_table_association" "subnet_rt_public_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_rt_public_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

#--- Priv subnet AZ1

resource "aws_route_table" "private_rt_az1" {
  vpc_id = module.vpc.vpc_id           
  tags = {
    Name        = "${var.appname}-priv-rt-AZ1" 
  }
}

resource "aws_route" "private_nat_gateway_az1" {
  route_table_id         = aws_route_table.private_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az1.id
}

resource "aws_route_table_association" "subnet_rt_private_az1" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_rt_az1.id
}


#--- Priv subnet AZ2

resource "aws_route_table" "private_rt_az2" {
  vpc_id = module.vpc.vpc_id           
  tags = {
    Name        = "${var.appname}-priv-rt-AZ2" 
  }
}

resource "aws_route" "private_nat_gateway_az2" {
  route_table_id         = aws_route_table.private_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az2.id
}


resource "aws_route_table_association" "subnet_rt_private_az2" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_rt_az2.id
}





