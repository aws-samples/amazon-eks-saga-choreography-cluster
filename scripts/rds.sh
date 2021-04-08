#!/bin/bash

set -e

r_setup() {
  echo 'Updating RDS security group'
  STACK_NAME=$1
  EKS_VPC=$2
  RDS_VPC=$3
  RDS_DB_ID=$4
  GROUP_NAME=$5

  RDS_SG=`aws ec2 create-security-group --description "EKS Saga DB SG" --group-name ${GROUP_NAME} --vpc-id ${RDS_VPC} --query 'GroupId' --output text`
  
  NAT_IPS=`aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select((.ResourceType=="AWS::EC2::EIP") and (.LogicalResourceId == "NATIP")) | .PhysicalResourceId'`
  for n in "${NAT_IPS[@]}"
  do
    aws ec2 authorize-security-group-ingress --group-id ${RDS_SG} --protocol tcp --port 3306 --cidr ${n}/32
  done

  aws rds modify-db-instance --db-instance-identifier ${RDS_DB_ID} --vpc-security-group-ids ${RDS_SG}

  echo "${RDS_SG} in RDS VPC ${RDS_VPC} updated to allow MySQL traffic from EKS VPC ${EKS_VPC} NAT gateway"
}

if [[ $# -ne 4 ]] ; then
  echo 'USAGE: ./rds.sh stackName eksVpc rdsVpc rdsDbId'
  exit 1
fi

STACK_NAME=$1
EKS_VPC=$2
RDS_VPC=$3
RDS_DB_ID=$4
GROUP_NAME="eks-saga-choreography-sg"

r_setup ${STACK_NAME} ${EKS_VPC} ${RDS_VPC} ${RDS_DB_ID} ${GROUP_NAME}