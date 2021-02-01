// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. // SPDX-License-Identifier: CC-BY-SA-4.0

# Introduction

This page documents the steps for installing the `eks-saga` cluster with **Choerography** pattern on Amazon EKS.

- [Introduction](#introduction)
  - [Installation](#installation)
    - [Launch cluster](#launch-cluster)
    - [Setting up load balancer](#setting-up-load-balancer)

## Installation

Clone the repository and change to `yaml` directory.

```bash
git clone ${GIT_URL}/eks-saga-cluster
```

There are three steps of installation.

- Launch cluster
- Setting up load balancer

### Launch cluster

1. Run the following command to launch the cluster.

```bash
cd eks-saga-cluster/yaml
sed -e 's/regionId/'"${REGION_ID}"'/g' \
  -e 's/eks-saga-demoType/eks-saga-choreography/g' \
  -e 's/accountId/'"${ACCOUNT_ID}"'/g' \
  -e 's/sns-policy/eks-saga-sns-chore-policy/g' \
  -e 's/sqs-policy/eks-saga-sqs-chore-policy/g' \
  cluster.yaml | eksctl create cluster -f -
```

2. Set up VPC identifiers as environment variables.

```bash
export EKS_VPC=vpc-
export RDS_VPC=vpc-
```

3. Run the following commands to enable communication between Amazon EKS and AWS RDS.

```bash
cd ../scripts
./rds.sh ${EKS_VPC} ${RDS_VPC} eks-saga-db
```

Verify that the cluster is up and running from the Amazon EKS console.

**Note** the `yaml/cluster.yaml` will enable cluster logging win AWS CloudWatch with a log group named `/aws/eks/eks-saga/cluster`. It is recommended that, the expiry of this log group is adjusted accordingly in the CloudWatch console.

### Setting up load balancer

To set-up load balancer, follow instructions from [here.](elb.md)
