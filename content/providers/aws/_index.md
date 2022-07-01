---
title: "Official AWS Provider"
weight: 10
---

The Upbound AWS Provider is the officially supported provider for Amazon Web Services (AWS).

View the [AWS Provider Documentation](provider) for details and configuration options. 

## Quickstart

To use this official provider, install it into your Upbound control plane, apply a `ProviderConfiguration` and `Configuration` package to create `XRDs` and `Claims`.

This guide walks through the process to create an Upbound managed control plane and install the AWS official provider.
* Create an Upbound.io user account.
* Create an Upbound user token.
* Install the `up` command-line.
* Connect to the managed control plane.
* Install the official AWS provider.
* Generate a Kubernetes secret with your AWS credentials.
* Create and install a `ProviderConfiguration` for the official AWS provider.
* Create and install a `Configuration` to create `XRD` and `Claim` resources.

## Create an Upbound.io user account
Create an account on [Upbound.io](https://cloud.upbound.io/register). 

Find detailed instructions in the [Upbound documentation](https://cloud.upbound.io/docs/getting-started/create-account).

## Create an Upbound user token
Authentication to a managed control plane requires a unique authentication token.

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
my-aws-controlplane   b2bb8761-e540-40e3-b21b-c47b140926aa   false         ready
```

## Connect to the managed control plane
Connecting to a managed control plane requires a `kubeconfig` file to connect to the remote cluster.  

Using the **user token** generated earlier and the control plane ID, generate a kubeconfig context configuration.  

`up controlplane kubeconfig get --token <token> <control plane ID>`

Verify that a new context is available in `kubectl` and `CURRENT`.

```shell
$ kubectl config get-contexts
CURRENT   NAME                                           CLUSTER                                        AUTHINFO                                       NAMESPACE
          kubernetes-admin@kubernetes                    kubernetes                                     kubernetes-admin
*         upbound-b2bb8761-e540-40e3-b21b-c47b140926aa   upbound-b2bb8761-e540-40e3-b21b-c47b140926aa   upbound-b2bb8761-e540-40e3-b21b-c47b140926aa
```

Confirm your token's access with any `kubectl` command.

```shell
$ kubectl get pods -A
NAMESPACE        NAME                                       READY   STATUS    RESTARTS   AGE
upbound-system   crossplane-745cc78565-tr6r9                1/1     Running   0          65m
upbound-system   crossplane-rbac-manager-766657bc6d-58cph   1/1     Running   0          65m
upbound-system   upbound-agent-66d7c4f88f-c7q7g             1/1     Running   0          65m
upbound-system   upbound-bootstrapper-c5dccc8fd-9tsmw       1/1     Running   0          65m
upbound-system   xgql-6f56c847c7-wzr64                      1/1     Running   2          65m
```

**Note:** if the token is incorrect the `kubectl` command returns an error.
```
$ kubectl get pods -A
Error from server (BadRequest): the server rejected our request for an unknown reason
```

## Install the official provider into the managed control plane
<!-- Use the marketplace button -->

Install the official provider into the managed control plane with a Kubernetes configuration file. 

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
    name: provider-aws
spec:
    package: "crossplane/provider-aws:master"
```

Apply this configuration with `kubectl apply -f`.

After installing the provider, verify the install with `kubectl get providers`.   

It may take up to 5 minutes to report `HEALTHY`.

```shell
$ kubectl get provider
NAME           INSTALLED   HEALTHY   PACKAGE                          AGE
provider-aws   True        True      crossplane/provider-aws:master   54s
```

## Create a Kubernetes secret with AWS credentials
The provider requires credentials to create and manage AWS resources.

Create a text file containing the AWS account `aws_access_key_id` and `aws_secret_access_key`. The [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds) provides information on how to generate these keys.

```ini
[default]
aws_access_key_id = <aws_access_key>
aws_secret_access_key = <aws_secret_key>
```

Use `kubectl create secret -n upbound-system` to generate the Kubernetes secret object inside the managed control plane.

`kubectl create secret generic aws-secret -n upbound-system --from-file=<aws_credentials_file.txt>`


## Create a provider configuration with the AWS secret

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
            key: aws-secret
```

Apply this configuration with `kubectl apply -f`.

**Note:** the `spec.credentials.secretRef.name` must match the `name` in the `kubectl create secret generic <name>` command.

Verify the `ProviderConfig` with `kubectl describe providerconfigs.aws.crossplane.io`. 

```yaml
$ kubectl describe providerconfigs.aws.crossplane.io
Name:         default
Namespace:
API Version:  aws.crossplane.io/v1beta1
Kind:         ProviderConfig
# Output truncated
Spec:
  Credentials:
    Secret Ref:
      Key:        aws-secret
      Name:       aws-secret
      Namespace:  upbound-system
    Source:       Secret
```

## Install a configuration package
A `Configuration` defines the collection of composite resource definitions, composites and claims. 

`Configurations` can be manually created or installed from the [Upbound Marketplace](https://marketplace.upbound.io/configurations).
The [Upbound documentation](https://cloud.upbound.io/docs/uxp/build-configuration) has more information on creating `Configurations`.

To install an [example configuration from the Marketplace](https://marketplace.upbound.io/configurations/upbound/platform-ref-aws/v0.2.3), create a `Configuration` Kubernetes configuration file and apply it to the managed control plane.

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: platform-ref-aws
spec:
  package: xpkg.upbound.io/upbound/platform-ref-aws:v0.2.3
```

**Note:** `Configurations` are [OCI](https://github.com/opencontainers/image-spec) images and can be downloaded and extracted with standard container tools. A third-party website, [explore.ggcr.dev](https://explore.ggcr.dev/) can also inspect `Configurations`. Use the explore.ggcr.dev tool to view [this Configuration](https://explore.ggcr.dev/fs/xpkg.upbound.io/upbound/platform-ref-aws@sha256:b6509ba3b625ac77aeab8c0377bb03234b2ddd618912af8b66034d71d462f6e7/package.yaml)


Inspect the `XRDs` the `Configuration` created with  

`kubectl get compositeresourcedefinitions`

```shell
$ kubectl get compositeresourcedefinitions
NAME                                                 ESTABLISHED   OFFERED   AGE
xclusters.aws.platformref.crossplane.io              True          True      5m13s
xeks.aws.platformref.crossplane.io                   True                    5m12s
xnetworks.aws.platformref.crossplane.io              True                    5m12s
xpostgresqlinstances.aws.platformref.crossplane.io   True          True      5m10s
xservices.aws.platformref.crossplane.io              True                    5m11s
```

Use XRDs with `OFFERED` set to `TRUE` to build `Claims`. View the parameters of an individual `XRD` by `describing` the specific it.

`kubectl describe compositeresourcedefinitions xclusters`

```yaml
$ kubectl describe compositeresourcedefinitions xclusters
Name:         xclusters.aws.platformref.crossplane.io
Namespace:
Labels:       <none>
Annotations:  upbound.io/ui-schema:
                ---
                configSections:
                - title: Cluster Info
                  description: Information about this cluster
                  items:
                  - name: id
                    controlType: singleInput
                    type: string
                    path: ".spec.id"
                    title: Cluster ID
                    description: Cluster ID that other objects will use to refer to this cluster
                    default: platform-ref-aws
                    validation:
                    - required: true
                      customError: Cluster ID is required.
                  - name: writeSecretRef
                    controlType: singleInput
                    type: string
                    path: ".spec.writeConnectionSecretToRef.name"
                    title: Connection Secret Ref
                    description: name of the secret to write to this namespace
                    default: platform-ref-aws-kubeconfig
                    validation:
                    - required: true
# Output truncated
```
