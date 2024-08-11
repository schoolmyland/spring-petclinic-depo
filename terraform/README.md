# Terraform deployment 


The plan is divvied on 4 components:


<b>RDS :</b> contain the different database for the two customers and the monitoring.


<b>NETWORK :</b> contain the VPC, subnets , table route and route 


<b>EKS :</b> contain the cluster and different nodegroup depending of the subnet wished for the pods. It contains the policies and add-on but also the set-up of the right for the user used for continuous deployment.


<b>R53 :</b> create the hosted zone, create the AWS ACM certificate for each front. Create the CNAME record to validate those record.

