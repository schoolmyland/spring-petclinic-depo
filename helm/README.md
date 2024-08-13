# Helm Charts used in the project
Here you will find the different Helm chart used into the project.

<b>petclinic-dev :</b> It's the first helm chart made with variables, it feat the need for the test environment. It has been deployed on the Jenkins VPS for the local installation of the application petclinic.


<b>petclinic-prod-https :</b>  It is the helm chart used to deploy the production environment. The deployement.yaml is adapted to target nodeGroup of the EKS using node selector.
Also the service.yaml use option to integrate the ACM certificate directly into the listeners of the ELB.


<b>Prometheus-install-pack :</b> This directory doesn't contain directly a helm chart, but an installation script that deploy the prometheus-community/kube-prometheus-stack and customize it to our needs.
It's made to set-up SMTP and Database servers, and initiate a different password than the default one used in Grafana admin account. 
Also, the script build target scrap config file to add the Petclinic microservices as target for Prometheus, before using the script you have to modify the file Front.yaml to add the arn of the certificate generated with ACM.
The script allows us to use the node selector to deploy the pod on the groupNode Monitoring. The front.yaml will be deployed on the Monitorfront groupeNode, it's only a reverse proxy for the Grafana webpage.
The fronttarget.yaml is a reverse proxy to see the target on Prometheus, it's a tool to check the installation but the pod is not meant to stay on the environment.

<b>To use the script you have to export this variables :</b>

<b>Variables for the databases </b>

Bdd_Grafana_host

Bdd_Grafana_name

Bdd_Grafana_user

Bdd_Grafana_pwd



<b>Varaibles for the SMTP</b>

Smtp_Grafana_host

Smtp_Grafana_mail

Smtp_Grafana_pwd



After exporting this list of variable you can use the script like : "install-monitoring.sh %pass-of-your-grafana-admin% "

<b>Remember that after the first setup the password for the Grafana admin user cannot be changed by the script but only on the user interface.  </b>
 
