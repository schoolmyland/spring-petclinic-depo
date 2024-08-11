
# BDD group
resource "aws_db_parameter_group" "mysql_rds_group" {
  name   = "petclinic-rds-group"  
  family = "mysql8.0"

}


#RDS
resource "aws_db_instance" "rds_mysql_cus1" {
  identifier              = "main-cus1"
  instance_class          = "db.t3.micro"
  db_name                 = var.cus1db_name
  username                = var.cus1db_user
  password                = var.cus1db_mdp
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "8.0" 
  db_subnet_group_name    = var.bdd_sn_gn
  vpc_security_group_ids  = [var.sg_bdd_id]
  skip_final_snapshot     = true
  parameter_group_name    = aws_db_parameter_group.mysql_rds_group.name
  multi_az                = true
  #Back up retention is mandatori to create the replication 
  backup_retention_period = 3
  tags = {
    "Name" = "${var.appname}-RDS-MYSQL"
    "Application" = var.appname
    "Customer" = var.customer1
  }
}

resource "aws_db_instance" "rds_mysql_cus2" {
  identifier              = "main-cus2"
  instance_class          = "db.t3.micro"
  db_name                 = var.cus2db_name
  username                = var.cus2db_user
  password                = var.cus2db_mdp
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "8.0" 
  db_subnet_group_name    = var.bdd_sn_gn
  vpc_security_group_ids  = [var.sg_bdd_id]
  skip_final_snapshot     = true
  parameter_group_name    = aws_db_parameter_group.mysql_rds_group.name
  multi_az                = true
  #Back up retention is mandatori to create the replication 
  backup_retention_period = 3
  tags = {
    "Name" = "${var.appname}-RDS-MYSQL"
    "Application" = var.appname
    "Customer" = var.customer2
  }
}


resource "aws_db_instance" "rds_mysql_monitor" {
  identifier              = "main-mon"
  instance_class          = "db.t3.micro"
  db_name                 = var.mondb_name
  username                = var.mondb_user
  password                = var.mondb_mdp
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "8.0" 
  db_subnet_group_name    = var.bdd_sn_gn
  vpc_security_group_ids  = [var.sg_bdd_id]
  skip_final_snapshot     = true
  parameter_group_name    = aws_db_parameter_group.mysql_rds_group.name
  multi_az                = true
  #Back up retention is mandatori to create the replication 
  backup_retention_period = 3
  tags = {
    "Name" = "${var.appname}-Monitoring-RDS-MYSQL"
    "Application" = "Grafana"
  }
}




#resource "aws_db_instance" "RDS_mysql_replica" {
#  identifier              = "replica"
#  replicate_source_db     = aws_db_instance.rds_mysql_main.identifier   
#  instance_class          = "db.t3.micro"   
#  apply_immediately       = true   
#  vpc_security_group_ids  = [var.sg_bdd_id]
#  skip_final_snapshot     = true
#  multi_az                = true
#  backup_retention_period = 3
#  parameter_group_name   = aws_db_parameter_group.mysql_rds_group.name 
#  tags = {
#    "Name" = "${var.appname}-RDS-MYSQL-replica"
#  }
#}
