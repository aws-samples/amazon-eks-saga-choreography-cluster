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
  helm uninstall aws-load-balancer-controller -n kube-system
  kubectl delete -k github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master
  eksctl delete iamserviceaccount --cluster eks-saga-choreography --name aws-load-balancer-controller --namespace kube-system --wait
  aws iam delete-policy --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/eks-saga-elb-policy
}

remove_cluster() {
  echo 'Removing cluster eks-saga-choreography'
  eksctl delete cluster --name eks-saga-choreography
}

remove_sg() {
  RDS_DB_ID=$1
  EKS_VPC=$2
  RDS_VPC=$3

  echo 'Removing inbound rules of RDS security group'
  RDS_SG=`aws rds describe-db-instances --db-instance-identifier ${RDS_DB_ID} --query 'DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId' --output text`

  NODES=(`kubectl get no --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`)
  for n in "${NODES[@]}"
  do
    NODE_IP=`aws ec2 describe-instances --filter Name=private-dns-name,Values=${n} Name=vpc-id,Values=${EKS_VPC} --query 'Reservations[0].Instances[0].PublicIpAddress' --output text`
    aws ec2 revoke-security-group-ingress --group-id ${RDS_SG} --protocol tcp --port 3306 --cidr ${NODE_IP}/32
  done
  #
  echo "${RDS_SG} in RDS VPC ${RDS_VPC} updated to deny MySQL traffic from EKS VPC ${EKS_VPC}"  
}

if [[ $# -ne 4 ]] ; then
  echo 'USAGE: ./cleanup.sh accountId rdsDb eksVpc rdsVpc'
  exit 1
fi

ACCOUNT_ID=$1
RDS_DB_ID=$2
EKS_VPC=$3
RDS_VPC=$4

remove_objects
remove_lb ${ACCOUNT_ID}
remove_sg ${RDS_DB_ID} ${EKS_VPC} ${RDS_VPC}
remove_cluster
