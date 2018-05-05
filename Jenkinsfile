pipeline {
  agent any

  parameters {
    string(name: 'env', defaultValue: 'Deploy', description: 'Development Environmennt')
  }

  stages {
    stage('Building_Image') {
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
    stage('Pushing_Image_To_ECR') {
      agent { label 'master' }
      steps {
          sh '''
                aws ecr get-login --no-include-email --region us-east-2 | bash
                REG_ADDRESS="726336258647.dkr.ecr.us-east-2.amazonaws.com"
                REPO="characters"
                #Tag the build with BUILD_NUMBER version
                docker tag ${REPO}:${BUILD_NUMBER} ${REG_ADDRESS}/${REPO}:${BUILD_NUMBER}
                #Publish image
                docker push ${REG_ADDRESS}/${REPO}:${BUILD_NUMBER}
            '''
              }
        }

    stage('Deploy_In_Kubernetes') {
      agent { label 'master' }
      steps {
            sh '''
            DEPLOYMENT_NAME="characters"
            CONTAINER_NAME="characters"
            NEW_DOCKER_IMAGE="726336258647.dkr.ecr.us-east-2.amazonaws.com/characters:${BUILD_NUMBER}"
            kubectl set image deployment/$DEPLOYMENT_NAME $CONTAINER_NAME=$NEW_DOCKER_IMAGE
            kubectl rollout status deployment $DEPLOYMENT_NAME
            '''
        }
      }
  }
}
