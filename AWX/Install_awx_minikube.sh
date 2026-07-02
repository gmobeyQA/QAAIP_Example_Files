#!/usr/bin/bash

sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
 
# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
 
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
 
# exit out of su and back into the user qa
sudo usermod -aG docker $USER && newgrp docker
minikube start --vm-driver=docker --addons=ingress

sudo su
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl


git clone https://github.com/ansible/awx-operator.git
cd awx-operator/
git checkout 2.19.1 # Or whatever the latest version is
export NAMESPACE=ansible-awx
make deploy
kubectl create -f awx-demo.yml -n ansible-awx

kubectl get pods -n ansible-awx
kubectl get svc -n ansible-awx

echo "Your ipaddress, the port is 10445S"
minikube service awx-demo-service --url -n ansible-awx
kubectl port-forward service/awx-demo-service -n ansible-awx --address 0.0.0.0 10445:80 &

echo "Login as admin, Your Password:"	
kubectl get secret awx-demo-admin-password -o jsonpath="{.data.password}" -n ansible-awx | base64 --decode; echo







