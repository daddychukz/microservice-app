#!/bin/bash

# Script to deploy the app
# This file is needed only when you want to deploy the app to a Linux VM

# install node

echo 'Enter your VPC ID'
read vpc_id

setEnvironmentVariables(){
echo ---------------- Setting environment variables ----------------------
export AWS_SECRET_ACCESS_KEY=$(cat ./kops-creds | jq -r '.AccessKey.SecretAccessKey')
export AWS_DEFAULT_REGION=us-east-2
export AWS_ACCESS_KEY_ID=$(cat ./kops-creds | jq -r '.AccessKey.AccessKeyId')
export ZONES=$(aws ec2 describe-availability-zones --region $AWS_DEFAULT_REGION | jq -r '.AvailabilityZones[].ZoneName' | tr '\n' ',' | tr -d ' ')
ZONES=${ZONES%?}
export NAME=chuks-cluster.k8s.local
export BUCKET_NAME=chuks-cluster-$(date +%s)
export KOPS_STATE_STORE=s3://$BUCKET_NAME
}

createBucket(){
echo ----------------- Creating Bucket -----------------------
aws s3api create-bucket --bucket $BUCKET_NAME --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
export KOPS_STATE_STORE=s3://$BUCKET_NAME
}

createCluster(){
echo ----------------- Creating Cluster ------------------------
# kops create cluster --name $NAME --master-count 1 --node-count 2 --node-size t2.micro --master-size t2.micro --zones $ZONES --networking kubenet --kubernetes-version v1.8.4 --yes --image "099720109477/ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180405"
kops create cluster --name $NAME --node-count 2 --node-size \
t2.micro --master-size t2.micro --zones us-east-2c --dns private \
--topology private --vpc $vpc_id --networking weave --bastion \
--kubernetes-version v1.8.4 --yes --image "099720109477/ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180405"
}

buildCluster(){
echo ----------------- Building Cluster -------------------------
kops update cluster ${NAME} --yes
}

createRepo(){
echo ------------- Creating Repository -----------------
XTER_REPO_URI=$(aws ecr create-repository --repository-name characters --region $AWS_DEFAULT_REGION | jq -r '.repository.repositoryUri')
LOCATIONS_REPO_URI=$(aws ecr create-repository --repository-name locations --region $AWS_DEFAULT_REGION | jq -r '.repository.repositoryUri')
NGINX_REPO_URI=$(aws ecr create-repository --repository-name nginx-router --region $AWS_DEFAULT_REGION | jq -r '.repository.repositoryUri')
}

authenticateToRepo(){
echo ------------ Authenticating --------------------
aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION | bash
}

buildImages(){
echo ----------------- Building Images --------------
docker build -t characters code/services/characters/.
docker build -t locations code/services/locations/.
docker build -t nginx-router code/services/nginx/.
docker tag characters:latest $XTER_REPO_URI:v1
docker tag locations:latest $LOCATIONS_REPO_URI:v1
docker tag nginx-router:latest $NGINX_REPO_URI:v1
}

pushImages(){
echo --------------- Pushing Images ---------------------
docker push $XTER_REPO_URI:v1
docker push $LOCATIONS_REPO_URI:v1
docker push $NGINX_REPO_URI:v1
}

main(){
setEnvironmentVariables
createBucket
createCluster
buildCluster
createRepo
authenticateToRepo
kops validate cluster
echo "Finished!"
}

main "$@"




