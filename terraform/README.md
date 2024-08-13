# Terraform deployment 


The plan is divvied on 4 modules:


<b>RDS :</b> contain the different database for the two customers and the monitoring.


<b>NETWORK :</b> contain the VPC, subnets , table route and route 


<b>EKS :</b> contain the cluster and different nodegroup depending of the subnet wished for the pods. It contains the policies and add-on but also the set-up of the right for the user used for continuous deployment.


<b>ROUTE53 :</b> create the hosted zone, create the AWS ACM certificate for each front. Create the CNAME record to validate those record.



<b>To use this plan, you have to export this list of variables :</b>


<b>The account used to create the infrastructure </b>

TF_VAR_AWS_ACCESS_KEY_ID

TF_VAR_AWS_SECRET_ACCESS_KEY


<b>This variables are used to give right on the EKS for the user that will be setup as the Jenkins AWS credential </b>

TF_VAR_account_id

TF_VAR_operator_account


<b>Parameters for the RDS database of the first customer </b>

TF_VAR_cus1db_name

TF_VAR_cus1db_user

TF_VAR_cus1db_mdp


<b>Parameters for the RDS database of the second customer </b> 

TF_VAR_cus2db_name

TF_VAR_cus2db_user

TF_VAR_cus2db_mdp


<b>Parameters for the RDS database for Grafana </b> 

TF_VAR_mondb_name

TF_VAR_mondb_user

TF_VAR_mondb_mdp
