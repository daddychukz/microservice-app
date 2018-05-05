node {
  stage('git checkout') {
    git branch: 'master', url: 'https://github.com/daddychukz/microservice-app'
  }

  stage('archive') {
    archiveArtifacts artifacts: '*, code/services/characters'
  }

  stage('build image') {
    sh '''
      cd ${WORKSPACE}/code/services/characters
      REPO="characters"
      #Build container images using Dockerfile
      docker build --no-cache -t ${REPO}:${BUILD_NUMBER} .
    '''
  }

  stage('refresh auth token') {
    sh '''
      ECR_LOGIN=$(aws ecr get-login --no-include-email)
      ${ECR_LOGIN}
    '''
  }

  stage('push image to ECR') {
      sh '''
        REG_ADDRESS="726336258647.dkr.ecr.us-east-2.amazonaws.com"
        REPO="characters"
        #Tag the build with BUILD_NUMBER version
        docker tag ${REPO}:${BUILD_NUMBER} ${REG_ADDRESS}/${REPO}:${BUILD_NUMBER}
        #Publish image
        docker push ${REG_ADDRESS}/${REPO}:${BUILD_NUMBER}
      '''
    }

  stage('deploy to Kubernetes') {
      sh '''
        DEPLOYMENT_NAME="characters-deployment"
        CONTAINER_NAME="characters"
        NEW_DOCKER_IMAGE="726336258647.dkr.ecr.us-east-2.amazonaws.com/characters:${BUILD_NUMBER}"
        kubectl cluster-info
        kubectl apply -f ${WORKSPACE}/code/recipes/characters.yml
        kubectl get deployments
        kubectl set image deployment/$DEPLOYMENT_NAME $CONTAINER_NAME=$NEW_DOCKER_IMAGE
        kubectl rollout status deployment $DEPLOYMENT_NAME
      '''
  }
}
