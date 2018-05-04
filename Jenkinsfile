pipeline {
  agent any

  parameters {
    string(name: 'env', defaultValue: 'Deploy', description: 'Development Environment')
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
          sshagent ( credentials: []) {
            sh '''
            echo "Tag=${BUILD_NUMBER}" > sshenv
            echo "target=${env}" >> sshenv
            scp sshenv admin@52.14.3.95:~/.ssh/environment
            ssh -T -o StrictHostKeyChecking=no -l admin 52.14.3.95 <<'EOF'
            DEPLOYMENT_NAME="characters"
            CONTAINER_NAME="characters"
            NEW_DOCKER_IMAGE="726336258647.dkr.ecr.us-east-2.amazonaws.com/characters:${Tag}"
            if [ "${target}" = "NoDeploy" ]
            then
            echo "No deployment to K8s"
            else
            kubectl set image deployment/$DEPLOYMENT_NAME $CONTAINER_NAME=$NEW_DOCKER_IMAGE
            kubectl rollout status deployment $DEPLOYMENT_NAME
            fi
            EOF'''
          }
        }
      }
  }
}
