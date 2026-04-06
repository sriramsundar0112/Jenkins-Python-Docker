pipeline{

    agent any
    environment
    {
       LOCAL_IMAGE_NAME='python-webapp'
       DOCKER_HUB_REPO='jenkins-docker-python-webapp'
       DOCKER_PORT=8000
       HOST_PORT=8082
     
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
                      sh '''
                docker tag $LOCAL_IMAGE_NAME:V$BUILD_NUMBER $DCKR_USER/$DOCKER_HUB_REPO:V$BUILD_NUMBER
                docker push $DCKR_USER/$DOCKER_HUB_REPO:V$BUILD_NUMBER
                '''
                    }
                }
                

            }
            }

            stage('Deploy and Run Python Web Application')
            {
                steps
                {
                    sh '''
                    CONTAINER_ID=0
                    CONTAINER_ID= $(docker ps -q --filter "publish=$HOST_PORT")
                    if [ "$CONTAINER_ID" -ne 0];then
                        docker stop $CONTAINER_ID
                    fi
                    docker run -d --name $LOCAL_IMAGE_NAME-V$BUILD_NUMBER -p $HOST_PORT:$DOCKER_PORT $LOCAL_IMAGE_NAME:V$BUILD_NUMBER 
                    '''
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
