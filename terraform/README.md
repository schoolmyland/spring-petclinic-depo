# Terraform deployment 


The plan is divvied on 4 components:

rds : contain the different database for the two customers and the monitoring.
network : contain the VPC, subnets , table route and route 
eks : contain the cluster and different nodegroup depending of the subnet wished for the pods. It contains the policies and add-on but also the set-up of the right for the user used for continuous deployment.
r53 : create the hosted zone, create the AWS ACM certificate for each front. Create the CNAME record to validate those record.
