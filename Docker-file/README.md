# DOCKERFILE


<b>STEP 1 :</b> Use the Jar made with the maeven wrapper into the first Jenkins pipeline.
Problem : The version of Java that build the jar is dependent of the Jenkins

<b>STEP 2 :</b> Build the Jar with a JDK image and use the Jar as entrypoint 
problem : The final image is way more heavy 

<b>STEP 3 :</b> Use the JDK image as builder to build the Jar with the maeven wrapper then retrieve the jar and use it as an entrypoint into a JRE image


You can find an exemple of the different step size into the <a href="https://hub.docker.com/repository/docker/poissonchat13/spring-petclinic-vets-service/tags?page=&page_size=&ordering=&name=step">docker-hub repo</a> 
with the tags img-step1 img-step2 img-step3

