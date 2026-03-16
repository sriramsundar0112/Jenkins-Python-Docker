pipeline{

    agent any
    environment
    {
        GITHUB_URL='https://github.com/sriramsundar0112/Jenkins-Python-Docker.git'
        GITHUB_BRANCH='main'
        LOCAL_IMAGE_NAME='python-webapp'
        DOCKER_HUB_REPO='jenkins-docker-python-webapp'
     
    }

    stages{
        stage("Checkout")
        {
            steps
            {
                git branch:"${env.GITHUB_BRANCH}",credentialsId:'github-token',url:"${env.GITHUB_URL}"
            }
        }

                stage('SonarQube Code Analysis'){
		steps{
            withSonarQubeEnv('sonarserver') {
                sh '''
                     /usr/lib/sonarscanner/bin/sonar-scanner \
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
                    sh 'docker run -d --name $LOCAL_IMAGE_NAMEV$BUILD_NUMBER -p 8081:8000 $LOCAL_IMAGE_NAME:V$BUILD_NUMBER '
                }
            }
    }

}
