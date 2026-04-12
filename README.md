This devops - project focuses on an End - End implemenation of all the devops - tools learned so far. It involves, making a commit to the Github, which triggers the Jenkins-Job with the required changes. The jenkins pipeline job (Pipeline as Code ) will checkout the latest code changes from github, then do static code analyis using - Sonar Qube, Build the corresponding Docker Image from it, then push it to docker hub.

Once the push is done, We will be able to pull the docker image on the remote machine, deploy it.

Browse the url to see the actual application can be run.

