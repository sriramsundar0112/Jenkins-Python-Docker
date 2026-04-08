pipeline{

    agent any
    environment
    {
       LOCAL_IMAGE_NAME='python-webapp'
       DOCKER_HUB_REPO='jenkins-docker-python-webapp'
       DOCKER_PORT=8000
       HOST_PORT=8082
       CLIENT_PRIVATEIP='172.31.65.173'
     
    }

    stages{
       	stage('Validate Agent')
        {
            steps
            {
               sh 'hostname'
			   sh 'whoami'
			   sh 'pwd'
            }
        }	
                
		
			stage('SonarQube Code Analysis'){
		steps{
            withSonarQubeEnv('sonarserver') {
                sh '''
                     /opt/sonar-scanner-8.0.1.6346-linux-x64/bin/sonar-scanner \
                     -Dsonar.projectBaseDir=. \
                     -Dsonar.sources=app \
                     -Dsonar.projectKey=sonarqube-Jenkins:$BUILD_NUMBER-$BUILD_ID \
                     -Dsonar.projectName=sonarqube-jenkins:$BUILD_NUMBER-$BUILD_ID \

                    '''
              }
            }
                
            }

        stage('Connect with DockerHub using Valid Credentials') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'jenkins-dockerhub', // The ID you set in Step 1
                            usernameVariable: 'DCKR_USER',               // Name of the environment variable for the username
                            passwordVariable: 'DCKR_PASS'                // Name of the environment variable for the password
                        )
                    ]) {
                        // The environment variables EXT_USER and EXT_PASS are available here
                        sh '''
                            echo "Connecting with user: $DCKR_USER"
                            echo "$DCKR_PASS" | docker login -u $DCKR_USER --password-stdin
                        
                        '''
                    }
                }
            }

        }

        stage('Build')
        {
            steps
            {
               sh 'docker build -t $LOCAL_IMAGE_NAME:V$BUILD_NUMBER .'
            }
        }

             stage('Push to Docker Hub') {
            steps 
                {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'jenkins-dockerhub', // The ID you set in Step 1
                            usernameVariable: 'DCKR_USER',               // Name of the environment variable for the username
                            passwordVariable: 'DCKR_PASS'                // Name of the environment variable for the password
                        )
                    ]) {
                      env.IMAGE_NAME_REPO="$DCKR_USER/$DOCKER_HUB_REPO:V$BUILD_NUMBER"
                      sh '''
                docker tag $LOCAL_IMAGE_NAME:V$BUILD_NUMBER $IMAGE_NAME_REPO
                docker push $IMAGE_NAME_REPO
                '''
                    }
                }
                

            }
            }

stage('Deploy and Run Python Web Application') {
    steps {
        script {
            withCredentials([
                sshUserPrivateKey(
                    credentialsId: 'Amazon-EC2-Client',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )
            ]) 
            {
                sh '''
                    set -e

                    echo "Connecting through SSH with IP: $CLIENT_PRIVATEIP ..."

                    ssh -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -i "$SSH_KEY" \
                        $SSH_USER@$CLIENT_PRIVATEIP <<EOF

                    hostname
					whoami
					pwd
					echo "Pulling image: ${IMAGE_NAME_REPO}"
                    sudo docker pull ${IMAGE_NAME_REPO}
                    sudo docker ps -q --filter "publish=${HOST_PORT}"
                    CONTAINER_ID=\$(sudo docker ps -q --filter "publish=${HOST_PORT}")
                    echo $CONTAINER_ID
                    if [ -n "$CONTAINER_ID" ]; then
                        echo "Stopping container running on port ${HOST_PORT}: $CONTAINER_ID"
                        sudo docker stop "$CONTAINER_ID"
                    else
                        echo "No existing container found on port ${HOST_PORT}"
                    fi

                    echo "Starting new container..."
                    sudo docker run -d \
                        --name ${LOCAL_IMAGE_NAME}-V${BUILD_NUMBER} \
                        -p ${HOST_PORT}:${DOCKER_PORT} \
                        ${IMAGE_NAME_REPO}

                    echo "Deployment completed successfully."
                EOF
                '''
            }
        }
    }
}

            
    }

    
post
            {
                always
                {
                    emailext attachLog: true, body: '''<html>
                                    <body>
                                    <h1>Jenkins Build Notification: ${PROJECT_NAME} - Build #${BUILD_NUMBER}</h1>
                                    <p>Status: <b>${BUILD_STATUS}</b></p>
                                    <p>Check the build details here: <a href="${BUILD_URL}">${BUILD_URL}</a></p>
                                    </body>
                                    </html>''', mimeType: 'text/html', subject: 'Build Notification: ${PROJECT_NAME} - Build #${BUILD_NUMBER} - Status : ${BUILD_STATUS}', to: 'sriram.sundaramoorthy@gmail.com'
                }
            }


}
