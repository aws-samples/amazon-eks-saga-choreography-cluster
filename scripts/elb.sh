#!/bin/bash

set -e

e_setup() {
  ACCOUNT_ID=$1

  helm repo add eks https://aws.github.io/eks-charts
  helm install aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=eks-saga-orchestration --set nodeSelector.role=web --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller -n kube-system
}

if [[ $# -ne 1 ]] ; then
  echo 'USAGE: ./elb.sh accountId'
  exit 1
fi

ACCOUNT_ID=$1

e_setup ${ACCOUNT_ID}
