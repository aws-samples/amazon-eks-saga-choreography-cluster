// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. // SPDX-License-Identifier: CC-BY-SA-4.0

# Introduction

This project has instructions for the `eks-saga-choreography` cluster on Amazon EKS.

## Usage

To install the cluster for **Choreography** demo, see [here.](doc/install.md)

To remove the cluster and related objects, run the following commands.

```bash
export RDS_DB_ID=eks-saga-db
export EKS_VPC=`aws eks describe-cluster --name eks-saga-choreography --query 'cluster.resourcesVpcConfig.vpcId' --output text`
export RDS_VPC=`aws rds describe-db-instances --db-instance-identifier ${RDS_DB_ID} --query 'DBInstances[0].DBSubnetGroup.VpcId' --output text`

git clone ${GIT_URL}/amazon-eks-saga-choreography-cluster
cd amazon-eks-saga-choreography-cluster/scripts
./cleanup.sh ${ACCOUNT_ID} eks-saga-db ${EKS_VPC} ${RDS_VPC}
```
