# JENKINS PIPELINE & TOOLS


checkNamespaceUse.sh : 


Script used into the pipeline to check if pod are actif on the namespace, if it's use the script tempo 5 minute and retry 12 time to wait one hour or fail the pipeline


checkpod.sh : 


Script used to check the pod health after deployment, 

If the pod have restart it show the java error cause into the pipeline and writte the full log into the logs directory. 

If the pod are not in running state, it print the event list from the description of the pod ( cmd : kubectl describe pod ).


client-list.csv :

Exemple of the csv file with the parameters used by the Jenkins child api-gateway pipeline, the parameters are clientName;colorHexCode;nodePort. 



Jenkinsfile-gateway :



Jenkinsfile-service : 



Jenkinsfile-child-gateway :



