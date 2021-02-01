// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. // SPDX-License-Identifier: CC-BY-SA-4.0

# Introduction

## Load balancer set-up

To set up load balancer, run the following commands. For complete instructions, see [here](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html).

```bash
git clone ${GIT_URL}/eks-saga-cluster
cd scripts
./elb.sh ${ACCOUNT_ID}
```
