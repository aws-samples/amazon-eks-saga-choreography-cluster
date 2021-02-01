// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. // SPDX-License-Identifier: CC-BY-SA-4.0

# Introduction

This project has instructions for the `eks-saga` cluster on Amazon EKS.

## Usage

To install the cluster for **Choreography** demo, see [here.](doc/install.md)

To remove the cluster and related objects, run the following commands.

```bash
# Get the VPC id of Amazon EKS
EKS_VPC=vpc-
# Get the VPC id of AWS RDS
RDS_VPC=vpc-

git clone ${GIT_URL}/eks-saga-cluster
cd eks-saga-cluster/scripts
./cleanup.sh ${ACCOUNT_ID} eks-saga-db ${EKS_VPC} ${RDS_VPC}
```
