---
title: Authenticate using IAM Roles for Service Accounts
draft: True
---

Universal Crossplane clusters running inside Amazon Elastic Kubernetes Service
(_EKS_) can use [IAM Roles for Service Accounts
(_IRSA_)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
to authenticate the AWS provider.

{{< hint type="important" >}}
This guide provides a minimal IAM policy with `eksctl` for demonstration purposes. It isn't intended to be a reference for IAM policy recommended practices. 
{{< /hint >}}

{{< hint type="tip" >}}
The [`eksctl` documentation](https://eksctl.io/usage/iamserviceaccounts/) has more information about configuring IRSA for EKS.
{{< /hint >}}

## Prerequisites
* [Amazon AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [`eksctl` CLI](https://eksctl.io/introduction/#installation) 
* An existing EKS cluster with Crossplane installed
* Permissions to create an IAM policy or an existing IAM policy to use with a Kubernetes Service Account
* Permissions to create an IAM role or an existing IAM role to use with a Kubernetes Service Account
* Permissions to create a _ServiceAccount_ inside the EKS cluster

<!-- Disable heading acronym rule to ignore "OIDC" -->
<!-- vale Microsoft.HeadingAcronyms = NO -->
## Enable an IAM OIDC provider
<!-- vale Microsoft.HeadingAcronyms = YES -->

The EKS cluster must have an IAM OpenID Connect (_OIDC_) provider enabled to
configure IRSA. The AWS documentation contains full details on [enabling IAM OIDC providers](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html).

Use [`eksctl`](https://eksctl.io/) to create an IAM OIDC provider.

Provider the name of your EKS cluster in {{< hover label="oidc" line="3" >}}--cluster {{< /hover >}}

```shell {copy-lines="all",label="oidc"}
eksctl utils associate-iam-oidc-provider \
--approve \
--cluster irsa-docs
```

Verify the OIDC Provider with `aws iam list-open-id-connect-providers`. 

```shell
aws iam list-open-id-connect-providers
{
    "OpenIDConnectProviderList": [
        {
            "Arn": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/1234567898B80C40A8D5D431E35A4690"
        }
    ]
}
```
<!-- vale gitlab.SubstitutionWarning = NO -->
<!-- literal click -->
Click the "Create an IAM Policy" button below for directions on creating an example IAM Policy. This policies attaches to the Kubernetes _ServiceAccount_.  
Skip this section if you have existing policy or plan to use an AWS Managed Policy.
<!-- vale gitlab.SubstitutionWarning = YES -->

{{< expand "Create an IAM Policy" >}}

{{< hint type="tip" >}}
This section is only required if you don't already have an existing IAM policy.
{{< /hint >}}

## Create an IAM policy

The IAM Policy defines the level of access the _ServiceAccount_ has. 

{{< hint type="caution" >}}
This policy is an example policy granting _AdministorAccess_ permissions and may not be appropriate for production. 
{{< /hint >}}

Create a JSON file defining the policy. 
```shell
cat > policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
```

Apply the policy with the `aws iam create-policy` command.

```shell {copy-lines="all",label="create-policy"}
aws iam create-policy \
--policy-name eks-test-policy \
--policy-document file://policy.json \
--output text
```

Provide a policy name with {{< hover label="create-policy" line="2" >}}--policy-name{{< /hover >}} and the policy file name with {{< hover label="create-policy" line="3" >}}--policy-document{{< /hover >}}.

The {{< hover label="create-policy" line="4" >}}--output text{{< /hover >}} prints the new policy ARN.
{{</expand >}}

<!-- Install Crossplane:
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane crossplane-stable/crossplane --namespace crossplane-system --create-namespace
-->

## Create a ServiceAccount and attach the IAM policy
Use `eksctl create iamserviceaccount` to create a new Kubernetes _ServiceAccount_ inside the EKS cluster. 

{{< hint type="tip" >}}
The `eksctl` documentation contains more information on [creating the _ServiceAccount_](https://eksctl.io/usage/iamserviceaccounts/). 
{{< /hint >}}

```shell {copy-lines="all",label="iamserviceaccount"}
eksctl create iamserviceaccount \
--name eks-sa \
--role-name eks-role \
--approve \
--namespace crossplane-system \
--cluster irsa-docs \
--attach-policy-arn arn:aws:iam::123456789012:policy/eks-test-policy
```

Provide a name for the new _ServiceAccount_ with {{< hover label="iamserviceaccount" line="2" >}}--name{{< /hover >}}. 

Use {{< hover label="iamserviceaccount" line="3" >}}--role-name{{< /hover >}} to provide the name for the new IAM policy `eksctl` creates. 

Crossplane requires the {{< hover label="iamserviceaccount" line="5" >}}crossplane-system{{< /hover >}} namespace for the Provider to access the ServiceAccount.

Provide the IAM policy ARN with {{< hover label="iamserviceaccount" line="6" >}}--attach-policy-arn{{< /hover >}}.

{{< expand "Need to find the policy ARN?" >}}
Find the policy ARN with `aws iam list-policies`. 

If you know the policy name provide it in the query. This example uses the name `AmazonS3FullAccess`.  

```shell
aws iam list-policies --query 'Policies[?PolicyName==`AmazonS3FullAccess`].Arn'
[
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
]
```

To see the ARN of all policies use  
```shell
aws iam list-policies --query 'Policies[*].[PolicyName, Arn]'
[
    [
        "AWSDirectConnectReadOnlyAccess",
        "arn:aws:iam::aws:policy/AWSDirectConnectReadOnlyAccess"
    ],
    [
        "AmazonGlacierReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonGlacierReadOnlyAccess"
    ],
 <!-- output removed for brevity -->
```
{{< /expand >}}


`eksctl` creates a new IAM role and Kubernetes _ServiceAccount_. 

View the newly created IAM role with `aws iam get-role`.

```shell {label="get-role"}
aws iam get-role --role-name eks-role
{
    "Role": {
        "Path": "/",
        "RoleName": "eks-role",
        "RoleId": "AROAZBZV2IPHOOELEM5FP",
        "Arn": "arn:aws:iam::123456789012:role/eks-role",
        <!-- output removed for brevity -->
    }
}
```

The IAM policy attaches to the IAM role.
View the policy and role with the `aws` CLI.

{{< hint type="note" >}}
For AWS Managed policies use `aws iam list-attached-role-policies`.  
For AWS Inline policies use `aws iam list-role-policies`.
{{< /hint >}}

```shell
aws iam list-attached-role-policies --role-name eks-role
{
    "AttachedPolicies": [
        {
            "PolicyName": "AmazonS3FullAccess",
            "PolicyArn": "arn:aws:iam::aws:policy/AmazonS3FullAccess"
        }
    ]
}
```

The _ServiceAccount_ attaches to the IAM role with a Kubernetes {{< hover label="describe-sa" line="5" >}}Annotation{{< /hover >}}. The annotation contains the {{< hover label="get-role" line="7" >}}Role ARN{{</hover >}}

```shell {label="describe-sa"}
kubectl describe serviceaccount eks-sa -n crossplane-system
Name:                eks-sa
Namespace:           crossplane-system
Labels:              app.kubernetes.io/managed-by=eksctl
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/eks-role
Image pull secrets:  <none>
Mountable secrets:   eks-sa-token-6nl6s
Tokens:              eks-sa-token-6nl6s
Events:              <none>
```

## Update the IAM role trust relationship

You must change the trust relationship in the IAM role created by `eksctl` to support the AWS Provider. 

{{< hint type="note" >}}
The [AWS documentation](https://docs.aws.amazon.com/directoryservice/latest/admin-guide/edit_trust.html) has instructions on modifying trust relationships in the AWS web console.
{{< /hint >}}

The updated policy requires the OIDC provider ARN and the Crossplane namespace.

Find the OIDC provider ARN with `aws iam list-open-id-connect-providers`.

```shell
aws iam list-open-id-connect-providers
{
    "OpenIDConnectProviderList": [
        {
            "Arn": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/1234567898B80C40A8D5D431E35A4690"
        }
    ]
}
```

Use the following JSON file as a template.

```json {label="trust-json",copy-lines="all"}
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "$OIDC_ARN"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "$OIDC_RESOURCE_TYPE/RESOURCE_ID:sub": "system:serviceaccount:upbound-system:provider-aws-*"
                }
            }
        }
    ]
}
```

Replace {{< hover label="trust-json" line="7" >}}$OIDC_ARN{{< /hover >}} with the OIDC ARN value.

Replace {{< hover label="trust-json" line="12" >}}$OIDC_RESOURCE_TYPE/RESOURCE_ID{{< /hover >}} with the OIDC resource type and resource ID.

Using the previous OIDC ARN example, the resulting JSON file is:
```json {copy-lines="all"}
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/1234567898B80C40A8D5D431E35A4690"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "oidc.eks.us-east-2.amazonaws.com/id/1234567898B80C40A8D5D431E35A4690:sub": "system:serviceaccount:crossplane-system:provider-aws-*"
                }
            }
        }
    ]
}
```

Save the JSON trust file as `trust.json`

Apply the new trust policy with `aws iam update-assume-role-policy`

```shell {copy-lines="all"}
aws iam update-assume-role-policy \
--role-name eks-role \
--policy-document file://trust.json
```

Verify the updated trust relationship with `aws iam get-role`.

```shell
aws iam get-role --role-name eks-role --query Role.AssumeRolePolicyDocument
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/1234567898B80C40A8D5D431E35A4690"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "oidc.eks.us-east-2.amazonaws.com/id/1234567898B80C40A8D5D431E35A4690:sub": "system:serviceaccount:crossplane-system:provider-aws-*"
                }
            }
        }
    ]
}
```

{{< hint type="tip" >}}
The value `provider-aws-*` defines the AWS provider and version that needs to
authenticate. Using `*` allows any AWS provider version to authenticate.
{{< /hint >}}

## Create a ControllerConfig
A `ControllerConfig` modifies the Kubernetes _ReplicaSet_ of the Provider. For IRSA the Provider pod needs an annotation indicating the EKS role.  

Find the role ARN with `aws iam get-role`.

```shell {label="role-arn",copy-lines="1-3"}
aws iam get-role \
--query Role.Arn \
--role-name eks-role 
"arn:aws:iam::123456789012:role/eks-role"
```

Use the role {{< hover label="role-arn" line="4" >}}ARN{{< /hover >}} as an {{< hover label="controllerconfig" line="7" >}}annotation{{< /hover >}}.

```yaml {label="controllerconfig",copy-lines="all"}
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1alpha1
kind: ControllerConfig
metadata:
  name: irsa-controllerconfig
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/eks-role
spec: 
EOF
```

## Create a Provider
The `Provider` object references the `ControllerConfig` to use apply the role ARN annotations to the Provider's _ReplicaSet_.


```yaml {label="provider",copy-lines="all"}
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.18.0
  controllerConfigRef:
    name: irsa-controllerconfig
EOF
```

The {{< hover label="provider" line="9" >}}Provider.spec.controllerConfigRef.name{{< /hover >}} must match the {{< hover label="controllerconfig" line="5" >}}ControllerConfig.metadata.name{{< /hover >}} value. 

Verify the provider installed with `kubectl get providers`. 

{{< hint type="note" >}}
It may take up to five minutes for the provider to list `HEALTHY` as `True`. 
{{< /hint >}}

View the Provider _ReplicaSet_ to see the EKS Role ARN as an {{< hover label="replicaset" line="11" >}}annotation{{< /hover >}}. 

```shell {label="replicaset"}
kubectl describe replicaset provider-aws-80ff1ee1c639-85cc5c4cf5 -n crossplane-system
Name:           provider-aws-80ff1ee1c639-85cc5c4cf5
Namespace:      crossplane-system
Selector:       pkg.crossplane.io/provider=provider-aws,pkg.crossplane.io/revision=provider-aws-80ff1ee1c639,pod-template-hash=85cc5c4cf5
Labels:         pkg.crossplane.io/provider=provider-aws
                pkg.crossplane.io/revision=provider-aws-80ff1ee1c639
                pod-template-hash=85cc5c4cf5
Annotations:    deployment.kubernetes.io/desired-replicas: 1
                deployment.kubernetes.io/max-replicas: 2
                deployment.kubernetes.io/revision: 1
                eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/eks-role
Controlled By:  Deployment/provider-aws-80ff1ee1c639
 <!-- output removed for brevity -->
```

## Create a ProviderConfig
The `ProviderConfig` configures the installed Provider to use IRSA authentication. 

```yaml {copy-lines="all"}
cat <<EOF | kubectl apply -f -
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: irsa-aws-providerconfig
spec:
  credentials:
    source: IRSA
EOF
```

Apply the `ProviderConfig` when creating a resource in the {{< hover label="bucket" line="9" >}}providerConfigRef.name{{< /hover >}}.

```yaml {label=bucket,copy-lines="all"}
apiVersion: s3.aws.upbound.io/v1beta1
kind: Bucket
metadata:
  name: irsa-bucket
spec:
  forProvider:
    region: us-east-2
  providerConfigRef:
    name: irsa-aws-providerconfig
```