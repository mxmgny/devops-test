#!/bin/bash
terraform init
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
sudo chmod +x ./aws-iam-authenticator
mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
aws-iam-authenticator version

#terraform apply 
sudo mkdir ~/.kube/
terraform output kubeconfig > kubeconfig
sudo mv kubeconfig ~/.kube/config
export KUBECONFIG=$HOME/.kube/config
terraform output config_map_aws_auth > configmap.yaml 
terraform output fluendt_deployment > fluendt_deployment.yaml
kubectl apply -f configmap.yaml
kubectl apply -k ./


