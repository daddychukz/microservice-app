pipeline {
  agent any
  stages {
    stage('Building_Character_Image') {
      agent { label 'master' }
      steps {
          sh '''
                cd ${WORKSPACE}/code/services/characters
                REPO="characters"
                #Build container images using Dockerfile
                docker build --no-cache -t ${REPO}:${BUILD_NUMBER} .
              '''
            }
      }
      stage('Building_Location_Image') {
      agent { label 'master' }
      steps {
          sh '''
                cd ${WORKSPACE}/code/services/locations
                REPO="locations"
                #Build container images using Dockerfile
                docker build --no-cache -t ${REPO}:${BUILD_NUMBER} .
              '''
            }
      }
      stage('Building_Nginx_Image') {
      agent { label 'master' }
      steps {
          sh '''
                cd ${WORKSPACE}/code/services/nginx
                REPO="nginx-router"
                #Build container images using Dockerfile
                docker build --no-cache -t ${REPO}:${BUILD_NUMBER} .
              '''
            }
      }
    stage('Pushing_Images_To_ECR') {
      agent { label 'master' }
      steps {
          sh '''
              aws ecr get-login --no-include-email --region us-east-2 | bash
              REG_ADDRESS="726336258647.dkr.ecr.us-east-2.amazonaws.com"
              REPO1="characters"
              REPO2="locations"
              REPO3="nginx-router"
              #Tag the build with BUILD_NUMBER version
              docker tag ${REPO1}:${BUILD_NUMBER} ${REG_ADDRESS}/${REPO1}:${BUILD_NUMBER}
              docker tag ${REPO2}:${BUILD_NUMBER} ${REG_ADDRESS}/${REPO2}:${BUILD_NUMBER}
              docker tag ${REPO3}:${BUILD_NUMBER} ${REG_ADDRESS}/${REPO3}:${BUILD_NUMBER}
              #Publish image
              docker push ${REG_ADDRESS}/${REPO1}:${BUILD_NUMBER}
              docker push ${REG_ADDRESS}/${REPO2}:${BUILD_NUMBER}
              docker push ${REG_ADDRESS}/${REPO3}:${BUILD_NUMBER}
            '''
              }
        }

    stage('Deploy_In_Kubernetes') {
      agent { label 'master' }
      steps {
          sh '''
            DEPLOYMENT_NAME1="characters-deployment"
            DEPLOYMENT_NAME2="locations-deployment"
            DEPLOYMENT_NAME3="nginx-router"
            CONTAINER_NAME1="characters"
            CONTAINER_NAME2="locations"
            CONTAINER_NAME3="nginx-router"
            NEW_DOCKER_IMAGE1="726336258647.dkr.ecr.us-east-2.amazonaws.com/characters:${BUILD_NUMBER}"
            NEW_DOCKER_IMAGE2="726336258647.dkr.ecr.us-east-2.amazonaws.com/locations:${BUILD_NUMBER}"
            NEW_DOCKER_IMAGE3="726336258647.dkr.ecr.us-east-2.amazonaws.com/nginx-router:${BUILD_NUMBER}"
            kubectl set image deployment/$DEPLOYMENT_NAME1 $CONTAINER_NAME=$NEW_DOCKER_IMAGE1
            kubectl set image deployment/$DEPLOYMENT_NAME $CONTAINER_NAME=$NEW_DOCKER_IMAGE2
            kubectl set image deployment/$DEPLOYMENT_NAME $CONTAINER_NAME=$NEW_DOCKER_IMAGE3
            kubectl rollout status deployment $DEPLOYMENT_NAME1
            kubectl rollout status deployment $DEPLOYMENT_NAME2
            kubectl rollout status deployment $DEPLOYMENT_NAME3
            '''
        }
      }
  }
}
