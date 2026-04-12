#! /bin/bash
set -e

# Setting the value for parameters which will be set by jenkins
IMAGE_NAME_REPO=$1
HOST_PORT=$2
LOCAL_IMAGE_NAME=$3
BUILD_NUMBER=$4
DOCKER_PORT=$5


hostname
whoami
pwd
echo "Pulling image: ${IMAGE_NAME_REPO}"
sudo docker pull ${IMAGE_NAME_REPO}
CONTAINER_ID=$(sudo docker ps -q --filter "publish=${HOST_PORT}")
echo $CONTAINER_ID
if [[ -n "$CONTAINER_ID" ]] ;then 
     echo "Already container with ID : ${CONTAINER_ID} running on port ${HOST_PORT}"
     echo "Stopping container running on port ${HOST_PORT}: ${CONTAINER_ID}"
     sudo docker stop ${CONTAINER_ID}
else
    echo "No existing container found on port ${HOST_PORT}"
fi

echo "Starting new container..."
sudo docker run -d \
--name ${LOCAL_IMAGE_NAME}-V${BUILD_NUMBER} \
-p ${HOST_PORT}:${DOCKER_PORT} \
-v jenkins-python-app-vol:/app/logs \
${IMAGE_NAME_REPO}
echo "Deployment completed successfully."
