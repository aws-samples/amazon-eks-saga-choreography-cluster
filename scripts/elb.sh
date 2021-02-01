#!/bin/bash

set -e

e_setup() {
  ACCOUNT_ID=$1

  eksctl create iamserviceaccount \
  --cluster=eks-saga-choreography \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/eks-saga-elb-policy \
  --override-existing-serviceaccounts \
  --approve

  kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
  
  helm repo add eks https://aws.github.io/eks-charts

  helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=eks-saga-choreography \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system
}

if [[ $# -ne 1 ]] ; then
  echo 'USAGE: ./elb.sh accountId'
  exit 1
fi

ACCOUNT_ID=$1

e_setup ${ACCOUNT_ID}
