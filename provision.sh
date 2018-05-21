#!/bin/bash

echo 'Enter your server address'
read server_name

javaSetup(){
    sudo add-apt-repository ppa:webupd8team/java -y
    sudo apt-get update && sudo apt-get install oracle-java8-installer -y
    sudo apt install jq -y
}

dockerSetup(){
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    apt-cache policy docker-ce
    sudo apt-get install -y docker-ce
}

setupKubernetes(){
sudo curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
sudo chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
}

configureNginx(){
if [[ -e /etc/nginx/sites-enabled/jenkins ]]; then
        echo Nginx already configured
else
echo --------------- configuring nginx server -----------------
sudo apt-get install nginx -y
sudo cp -f /etc/nginx/sites-enabled/default nginx-default-server
sudo rm -r /etc/nginx/sites-available/default
sudo bash -c 'cat > /etc/nginx/sites-available/jenkins <<EOF
upstream app_server {
    server 127.0.0.1:8080 fail_timeout=0;
}

server {
    listen 80;
    listen [::]:80 default ipv6only=on;
    server_name '$server_name';

    location / {
        proxy_set_header X-Forwarded-For '$proxy_add_x_forwarded_for';
        proxy_set_header Host '$http_host';
        proxy_redirect off;

        if (!-f '$request_filename') {
            proxy_pass http://app_server;
            break;
        }
    }
}
EOF'
sudo ln -fs /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/jenkins
fi
sudo service nginx restart
}

awscliSetup(){
    #install Python version 2.7 if it was not already installed during the JDK #prerequisite installation
    curl -O https://bootstrap.pypa.io/get-pip.py
    sudo python3 get-pip.py
    sudo pip3 install awscli --upgrade
    sudo pip install awscli
}

configureJenkins(){
    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
    #create a sources list for jenkins
    sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

    #update your local package list
    sudo apt-get update
    #install jenkins
    sudo apt-get install jenkins -y
    #add Jenkins user to docker user group
    sudo usermod -aG docker jenkins
    echo "change Jenkins password"
    sudo passwd jenkins
    sudo usermod -a -G sudo jenkins
    su jenkins
}

main(){
    javaSetup
    dockerSetup
    configureNginx
    setupKubernetes
    awscliSetup
    configureJenkins
}
main "$@"
