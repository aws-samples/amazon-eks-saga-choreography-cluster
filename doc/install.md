// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. // SPDX-License-Identifier: CC-BY-SA-4.0

# Introduction

This page documents the steps for installing the `eks-saga` cluster with **Choerography** pattern on Amazon EKS.

- [Introduction](#introduction)
  - [Installation](#installation)
    - [Launch cluster](#launch-cluster)
    - [Setting up load balancer](#setting-up-load-balancer)

## Installation

1. Clone the repository and change to `yaml` directory.

```bash
git clone ${GIT_URL}/amazon-eks-saga-choreography-cluster
```

There are two steps of installation.

- Launch cluster
- Setting up load balancer

### Launch cluster

1. Run the following command to launch the cluster.

```bash
cd amazon-eks-saga-choreography-cluster/yaml
sed -e 's/regionId/'"${REGION_ID}"'/g' \
  -e 's/eks-saga-demoType/eks-saga-choreography/g' \
  -e 's/accountId/'"${ACCOUNT_ID}"'/g' \
  -e 's/sns-policy/eks-saga-sns-orche-policy/g' \
  -e 's/sqs-policy/eks-saga-sqs-orche-policy/g' \
  cluster.yaml | eksctl create cluster -f -
```

2. Set-up [Container Insights.](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html)

```bash
EKS_CLUSTER=eks-saga-choreography
LogRegion=${REGION_ID}
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${LogRegion}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f - 
```

3. Set up VPC identifiers as environment variables.

```bash
export RDS_DB_ID=eks-saga-db
export EKS_VPC=`aws eks describe-cluster --name eks-saga-choreography --query 'cluster.resourcesVpcConfig.vpcId' --output text`
export RDS_VPC=`aws rds describe-db-instances --db-instance-identifier ${RDS_DB_ID} --query 'DBInstances[0].DBSubnetGroup.VpcId' --output text`
```

4. Run the following commands to enable communication between Amazon EKS and AWS RDS.

```bash
cd ../scripts
./rds.sh ${STACK_NAME} ${EKS_VPC} ${RDS_VPC} ${RDS_DB_ID}
```

Verify that the cluster is up and running from the Amazon EKS console.

**Note** the `yaml/cluster.yaml` will enable cluster logging win AWS CloudWatch with a log group named `/aws/eks/eks-saga/cluster`. It is recommended that, the expiry of this log group is adjusted accordingly in the CloudWatch console.

### Setting up load balancer

To set-up load balancer, follow instructions from [here.](elb.md)
