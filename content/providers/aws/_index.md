---
title: "Official AWS Provider"
weight: 10
---

The Upbound AWS Provider is the officially supported provider for Amazon Web Services (AWS).

View the [AWS Provider Documentation](provider) for details and configuration options. 

## Quickstart

To use this official provider, install it into your Upbound control plane, apply a `ProviderConfiguration`, and create a *managed resource* in AWS via Kubernetes.

This guide walks through the process to create an Upbound managed control plane and install the AWS official provider.
* [Create an Upbound.io user account.](#create-an-upboundio-user-account)
* [Create an Upbound user token.](#create-an-upbound-user-token)
* [Install the `up` command-line.](#install-the-up-command-line)
* [Log in to Upbound.](#log-in-to-upbound)
* [Connect to the managed control plane.](#connect-to-the-managed-control-plane)
* [Install the official AWS provider.](#install-the-official-aws-provider-in-to-the-managed-control-plane)
* [Generate a Kubernetes secret with your AWS credentials.](#create-a-kubernetes-secret)
* [Create and install a `ProviderConfiguration` for the official AWS provider.](#create-a-providerconfig)
* [Create a *managed resource* and verify AWS connectivity.](#create-a-managed-resource)

## Create an Upbound.io user account
Create an account on [Upbound.io](https://cloud.upbound.io/register). 

Find detailed instructions in the [Upbound documentation](https://cloud.upbound.io/docs/getting-started/create-account).

## Create an Upbound user token
Authentication to an Upbound managed control plane requires a unique authentication token.

Generate a user token through the [Upbound Universal Console](https://cloud.upbound.io/).

![Create an API Token](https://static.upbound.io/docs/static/9633d6fc697cab806a211982cb4af46a/create-api-token.gif)

To generate a user token in the Upbound Universal Console:
*<!-- vale Microsoft.FirstPerson = NO -->*
1. Log in to the [Upbound Universal Console](https://cloud.upbound.io) and select **My Account**.
2. Select **API Tokens**.
3. Select the **Create New Token** button.
4. Provide a token name.
5. Select **Create Token**.
*<!-- vale Microsoft.FirstPerson = Yes -->*

The Console generates a new token and displays it on screen. Save this token. The Console can't print the token again.

## Install the Up command-line
Install the [Up command-line](https://cloud.upbound.io/docs/cli/install) to connect to Upbound managed control planes.

```shell
curl -sL "https://cli.upbound.io" | sh
sudo mv up /usr/local/bin/
```

## Log in to Upbound
Log in to Upbound with the `up` command-line.

`up login`

## Create a managed control plane
Create a new managed control plane using the command `up controlplane create <control plane name>`.

For example  
`up controlplane create my-aws-controlplane`

Verify control plane creation with the command

`up controlplane list`

The `STATUS` starts as `provisioning` and moves to `ready`.

```shell
$ up controlplane list
NAME                  ID                                     SELF-HOSTED   STATUS
my-aws-controlplane   8856147c-03f3-4d68-aba4-4d02cc66d33a   false         ready
```
## Connect to the managed control plane
Connecting to a managed control plane requires a `kubeconfig` file to connect to the remote cluster.  

Using the **user token** generated earlier and the control plane ID from `up controlplane list`, generate a kubeconfig context configuration.  

`up controlplane kubeconfig get --token <token> <control plane ID>`

Verify that a new context is available in `kubectl` and is the `CURRENT` context.

```shell
$ kubectl config get-contexts
CURRENT   NAME                                           CLUSTER                                        AUTHINFO                                       NAMESPACE
          kubernetes-admin@kubernetes                    kubernetes                                     kubernetes-admin
*         upbound-8856147c-03f3-4d68-aba4-4d02cc66d33a   upbound-8856147c-03f3-4d68-aba4-4d02cc66d33a   upbound-8856147c-03f3-4d68-aba4-4d02cc66d33a
```

**Note:** change the `CURRENT` context with `kubectl config use-context <context name>`.

Confirm your token's access with any `kubectl` command.

```shell
$ kubectl get pods -A
NAMESPACE        NAME                                       READY   STATUS    RESTARTS   AGE
upbound-system   crossplane-745cc78565-b6xkx                1/1     Running   0          113s
upbound-system   crossplane-rbac-manager-766657bc6d-z5v5p   1/1     Running   0          113s
upbound-system   upbound-agent-66d7c4f88f-lqxkh             1/1     Running   1          102s
upbound-system   upbound-bootstrapper-c5dccc8fd-7rgqm       1/1     Running   0          113s
upbound-system   xgql-6f56c847c7-8vs6n                      1/1     Running   2          113s
```

**Note:** if the token is incorrect the `kubectl` command returns an error.
```
$ kubectl get pods -A
Error from server (BadRequest): the server rejected our request for an unknown reason
```

## Install the official AWS provider in to the managed control plane
<!-- Use the marketplace button -->

Install the official provider into the managed control plane with a Kubernetes configuration file. 

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/crossplane/provider-aws:v0.24.1
```

Apply this configuration with `kubectl apply -f`.

After installing the provider, verify the install with `kubectl get providers`.   

```shell
$ kubectl get providers
NAME           INSTALLED   HEALTHY   PACKAGE                                           AGE
provider-aws   True        True      xpkg.upbound.io/crossplane/provider-aws:v0.24.1   11m
```

It may take up to 5 minutes to report `HEALTHY`.

## Create a Kubernetes secret
The provider requires credentials to create and manage AWS resources.

### Generate an AWS key-pair file

Create a text file containing the AWS account `aws_access_key_id` and `aws_secret_access_key`. The [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds) provides information on how to generate these keys.

```ini
[default]
aws_access_key_id = <aws_access_key>
aws_secret_access_key = <aws_secret_key>
```

Save this text file as `aws-credentials.txt`.

### Create a Kubernetes secret with GCP credentials
Use `kubectl create secret -n upbound-system` to generate the Kubernetes secret object inside the managed control plane.

`kubectl create secret generic aws-secret -n upbound-system --from-file=creds=./aws-credentials.txt`

View the secret with `kubectl describe secret`
```shell
$ kubectl describe secret aws-secret -n upbound-system
Name:         aws-secret
Namespace:    upbound-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
creds:  114 bytes
```
## Create a ProviderConfig
Create a `ProviderConfig` Kubernetes configuration file to attach the AWS credentials to the installed official provider.

```yaml
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: upbound-system
      name: aws-secret
      key: creds
```

Apply this configuration with `kubectl apply -f`.

**Note:** the `Providerconfig` value `spec.secretRef.name` must match the `name` of the secret in `kubectl get secrets -n upbound-system` and `spec.SecretRef.key` must match the value in the `Data` section of the secret.

Verify the `ProviderConfig` with `kubectl describe providerconfigs`. 

```yaml
$ kubectl describe providerconfigs
Name:         default
Namespace:
API Version:  aws.crossplane.io/v1beta1
Kind:         ProviderConfig
# Output truncated
Spec:
  Credentials:
    Secret Ref:
      Key:        creds
      Name:       aws-secret
      Namespace:  upbound-system
    Source:       Secret
```

## Create a managed resource
Create a managed resource to verify the provider is functioning. 

This example creates an AWS S3 storage bucket, which requires a globally unique name. 

Generate a unique bucket name from the command line.

`echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 14)`

For example
```
$ echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10)
upbound-bucket-7112a98ffbdde
```

Use this bucket name for `metadata.annotations.crossplane.io/external-name` value.

Create a `Bucket` configuration file. Replace `<BUCKET NAME>` with the `upbound-bucket-` generated name.

```yaml
apiVersion: s3.aws.crossplane.io/v1beta1
kind: Bucket
metadata:
  name: example
  annotations:
    crossplane.io/external-name: upbound-bucket-7112a98ffbdde
spec:
  forProvider:
    locationConstraint: us-east-1
    acl: "private"
  providerConfigRef:
    name: default
```

A `Bucket` requires the `forProvider.acl` setting. The value determines the security ACL applied to the bucket. `acl` support any [AWS "Canned ACL"](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl) value.

**Note:** the `spec.providerConfigRef.name` must match the `ProviderConfig` `metadata.name` value.

Apply this configuration with `kubectl apply -f`.

Use `kubectl get managed` to verify bucket creation.

```shell
$ kubectl get managed
Warning: Please use v1beta1 version of SNS group.
NAME                                  READY   SYNCED   AGE
bucket.s3.aws.crossplane.io/example   True    True     21m
```

*Note:* ignore the `SNS group` warning. More information is available in [GitHub issue #1202](https://github.com/crossplane-contrib/provider-aws/issues/1202)

Upbound created the bucket when the values `READY` and `SYNCED` are `True`.

If the `READY` or `SYNCED` are blank or `False` use `kubectl describe` to understand why.

Here is an example of a failure because the `spec.providerConfigRef.name` value in the `Bucket` doesn't match the `ProviderConfig` `metadata.name`.

```shell
$ kubectl describe bucket.s3.aws.crossplane.io/example
Name:         example
Namespace:
Labels:       <none>
Annotations:  crossplane.io/external-name: upbound-bucket-7112a98ffbdde
API Version:  s3.aws.crossplane.io/v1beta1
Kind:         Bucket
# Output truncated
Spec:
  Deletion Policy:  Delete
  For Provider:
    Location Constraint:  us-east-1
  Provider Config Ref:
    Name:  default
Status:
  At Provider:
    Arn:
  Conditions:
    Last Transition Time:  2022-07-01T19:43:30Z
    Message:               connect failed: cannot get referenced Provider: ProviderConfig.aws.crossplane.io "default" not found
    Reason:                ReconcileError
    Status:                False
    Type:                  Synced
Events:
  Type     Reason                   Age              From                                 Message
  ----     ------                   ----             ----                                 -------
  Warning  CannotConnectToProvider  3s (x4 over 8s)  managed/bucket.s3.aws.crossplane.io  cannot get referenced Provider: ProviderConfig.aws.crossplane.io "default" not found
```
The output indicates the `Bucket` is using `ProviderConfig` named `default`. The applied `ProviderConfig` is `my-config`. 

```shell
$ kubectl get providerconfig
NAME        AGE
my-config   114s
```

## Delete the managed resource
Remove the managed resource by using `kubectl delete -f` with the same `Bucket` object file.