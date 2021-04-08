#!/bin/bash

set -e

remove_objects() {
  echo 'Removing trail microservice'
  kubectl -n eks-saga delete ing/eks-saga-trail svc/eks-saga-trail deployment/eks-saga-trail configmap/eks-saga-trail
  echo 'Removing audit microservice'
  kubectl -n eks-saga delete deployment/eks-saga-audit configmap/eks-saga-audit
  echo 'Removing inventory microservice'
  kubectl -n eks-saga delete deployment/eks-saga-inventory configmap/eks-saga-inventory
  echo 'Removing order microservice'
  kubectl -n eks-saga delete ing/eks-saga-orders svc/eks-saga-orders deployment/eks-saga-orders configmap/eks-saga-orders
  echo 'Removing eks-saga namespace'
  kubectl delete namespace eks-saga
}

remove_lb() {
  ACCOUNT_ID=$1

  echo 'Removing AWS Load Balancer controller'
  helm delete aws-load-balancer-controller -n kube-system
  eksctl delete iamserviceaccount --cluster eks-saga-orchestration --name aws-load-balancer-controller --namespace kube-system --wait
  aws iam delete-policy --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/eks-saga-elb-policy
}

remove_cluster() {
  EKS_CLUSTER=$1

  echo 'Detaching policy from node IAM role'
  STACK_NAME=eksctl-${EKS_CLUSTER}-cluster
  ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
  aws iam detach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
  echo 'Removing cluster eks-saga-orchestration'
  eksctl delete cluster --name ${EKS_CLUSTER}
}

remove_sg() {
  STACK_NAME=$1
  RDS_DB_ID=$2
  EKS_VPC=$3
  RDS_VPC=$4

  echo 'Removing inbound rules of RDS security group'
  RDS_SG=`aws rds describe-db-instances --db-instance-identifier ${RDS_DB_ID} --query 'DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId' --output text`
  SUBNETS=(`aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select((.ResourceType=="AWS::EC2::Subnet") and (.LogicalResourceId | startswith("SubnetPrivate"))) | .PhysicalResourceId'`)

  for s in "${SUBNETS[@]}"
  do
    CIDR_BLOCK=`aws ec2 describe-subnets --subnet-ids ${s} --query 'Subnets[0].CidrBlock' --output text`
    aws ec2 revoke-security-group-ingress --group-id ${RDS_SG} --protocol tcp --port 3306 --cidr ${CIDR_BLOCK}
  done

  #
  echo "${RDS_SG} in RDS VPC ${RDS_VPC} updated to deny MySQL traffic from EKS VPC ${EKS_VPC}"  
}

if [[ $# -ne 6 ]] ; then
  echo 'USAGE: ./cleanup.sh stackName accountId rdsDb eksVpc rdsVpc clusterName'
  exit 1
fi

STACK_NAME=$1
ACCOUNT_ID=$2
RDS_DB_ID=$3
EKS_VPC=$4
RDS_VPC=$5
EKS_CLUSTER=$6

remove_objects
remove_lb ${ACCOUNT_ID}
remove_sg ${STACK_NAME} ${RDS_DB_ID} ${EKS_VPC} ${RDS_VPC}
remove_cluster ${EKS_CLUSTER}
