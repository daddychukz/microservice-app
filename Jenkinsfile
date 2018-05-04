
node {
  stage('git checkout') {
    git branch: 'master', url: 'https://github.com/daddychukz/microservice-app'
  }

  stage('build image') {
    sh '''
        cd ${WORKSPACE}/code/services/characters
        REPO="characters"
        #Build container images using Dockerfile
        docker build --no-cache -t ${REPO}:${BUILD_NUMBER} .
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
  }
