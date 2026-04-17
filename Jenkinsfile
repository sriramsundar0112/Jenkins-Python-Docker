pipeline{

    agent any
    parameters 
    {
       string(name: 'LOCAL_IMAGE_NAME', defaultValue: 'python-webapp', description: 'Name of the Docker Image')
       string(name: 'DOCKER_HUB_REPO', defaultValue: 'jenkins-docker-python-webapp', description: 'Name of the Docker Hub Repository')
       string(name: 'DOCKER_PORT', defaultValue: '8000', description: 'Docker Port on which application will run')
       string(name: 'HOST_PORT', defaultValue: '8082', description: 'Host Port on which application will be mapped with Docker Port')
       string(name: 'CLIENT_PRIVATEIP', defaultValue: '172.31.65.173', description: 'Client IP on which the docker application will be deployed ')
          
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
                sh """
                     /opt/sonar-scanner-8.0.1.6346-linux-x64/bin/sonar-scanner \
                     -Dsonar.projectBaseDir=. \
                     -Dsonar.sources=app \
                     -Dsonar.projectKey=sonarqube-Jenkins \
                     -Dsonar.projectName=sonarqube-jenkins \
					 -Dsonar.exclusions=**/__pycache__/**,**/.git/**,**/*.md

                    """
              }
            }
                
            }
        
        stage('Sonar Qube Quality Gate Check'){

            steps {
                timeout(time:5,unit: 'MINUTES'){
                    waitForQualityGate abortPipeline: true
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
                        sh """
                            echo "Connecting with user: $DCKR_USER"
                            echo "$DCKR_PASS" | docker login -u $DCKR_USER --password-stdin
                        
                        """
                    }
                }
            }

        }

        stage('Build')
        {
            steps
            {
               sh """docker build -t ${params.LOCAL_IMAGE_NAME}:V$BUILD_NUMBER ."""
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
                      env.IMAGE_NAME_REPO="$DCKR_USER/${params.DOCKER_HUB_REPO}:V$BUILD_NUMBER"
                      sh """
                docker tag ${params.LOCAL_IMAGE_NAME}:V$BUILD_NUMBER $IMAGE_NAME_REPO
                docker push $IMAGE_NAME_REPO
                """
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
                sh """
                    set -e

                    echo "Connecting through SSH with IP: ${params.CLIENT_PRIVATEIP} ..."

                    ssh -o StrictHostKeyChecking=no \\
                        -o UserKnownHostsFile=/dev/null \\
                        -i "$SSH_KEY" \\
                        $SSH_USER@${params.CLIENT_PRIVATEIP} \\
                        "bash -s $IMAGE_NAME_REPO ${params.HOST_PORT} ${params.LOCAL_IMAGE_NAME} $BUILD_NUMBER ${params.DOCKER_PORT}" \\
                         < Scripts/deploy.sh
                """
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
