#!/bin/bash

set -e

r_setup() {
  echo 'Updating RDs security group for traffic from EKS VPC'
  EKS_VPC=$1
  RDS_VPC=$2
  RDS_DB_ID=$3
  #
  RDS_SG=`aws rds describe-db-instances --db-instance-identifier ${RDS_DB_ID} --query 'DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId' --output text`
  
  NODES=(`kubectl get no --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`)
  for n in "${NODES[@]}"
  do
    NODE_IP=`aws ec2 describe-instances --filter Name=private-dns-name,Values=${n} Name=vpc-id,Values=${EKS_VPC} --query 'Reservations[0].Instances[0].PublicIpAddress' --output text`
    aws ec2 authorize-security-group-ingress --group-id ${RDS_SG} --protocol tcp --port 3306 --cidr ${NODE_IP}/32
  done
  #
  echo "${RDS_SG} in RDS VPC ${RDS_VPC} updated to allow MySQL traffic from EKS VPC ${EKS_VPC}"
}

if [[ $# -ne 3 ]] ; then
  echo 'USAGE: ./rds.sh eksVpc rdsVpc rdsDbId'
  exit 1
fi

EKS_VPC=$1
RDS_VPC=$2
RDS_DB_ID=$3

r_setup ${EKS_VPC} ${RDS_VPC} ${RDS_DB_ID}