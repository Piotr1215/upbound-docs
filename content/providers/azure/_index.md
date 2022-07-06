---
title: "Official Azure Provider"
weight: 20
---

The Upbound Azure Provider is the officially supported provider for the Microsoft Azure Cloud.

View the [Azure Provider Documentation](provider) for details and configuration options. 

## Quickstart

To use this official provider, install it into your Upbound control plane, apply a `ProviderConfiguration`, and create a *managed resource* in Azure via Kubernetes.

This guide walks through the process to create an Upbound managed control plane and install the AWS official provider.
* [Create an Upbound.io user account.](#create-an-upboundio-user-account)
* [Create an Upbound user token.](#create-an-upbound-user-token)
* [Install the `up` command-line.](#install-the-up-command-line)
* [Log in to Upbound.](#log-in-to-upbound)
* [Connect to the managed control plane.](#connect-to-the-managed-control-plane)
* [Install the official Azure provider.](#install-the-official-azure-provider-in-to-the-managed-control-plane)
* [Generate a Kubernetes secret with your Azure credentials.](#create-a-kubernetes-secret)
* [Create and install a `ProviderConfiguration` for the official Azure provider.](#create-a-providerconfig)
* [Create a *managed resource* and verify Azure connectivity.](#create-a-managed-resource)

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
`up controlplane create my-azure-controlplane`

Verify control plane creation with the command

`up controlplane list`

The `STATUS` starts as `provisioning` and moves to `ready`.

```shell
$ up controlplane list
NAME                  ID                                     SELF-HOSTED   STATUS
my-azure-controlplane   bc8519ee-747d-46da-bd6e-98af310489de   false         ready
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
*         upbound-bc8519ee-747d-46da-bd6e-98af310489de   upbound-bc8519ee-747d-46da-bd6e-98af310489de   upbound-bc8519ee-747d-46da-bd6e-98af310489de
```

**Note:** change the `CURRENT` context with `kubectl config use-context <context name>`.

Confirm your token's access with any `kubectl` command.

```shell
$ kubectl get pods -A
NAMESPACE        NAME                                       READY   STATUS    RESTARTS   AGE
upbound-system   crossplane-745cc78565-cbfc2                1/1     Running   0          3m48s
upbound-system   crossplane-rbac-manager-766657bc6d-dtpbw   1/1     Running   0          3m48s
upbound-system   upbound-agent-66d7c4f88f-66h2v             1/1     Running   0          3m40s
upbound-system   upbound-bootstrapper-c5dccc8fd-t4mdv       1/1     Running   0          3m48s
upbound-system   xgql-6f56c847c7-2lmst                      1/1     Running   2          3m48s
```

**Note:** if the token is incorrect the `kubectl` command returns an error.
```
$ kubectl get pods -A
Error from server (BadRequest): the server rejected our request for an unknown reason
```

## Install the official Azure provider in to the managed control plane
<!-- Use the marketplace button -->

Install the official provider into the managed control plane with a Kubernetes configuration file. 

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: crossplane-provider-jet-azure
spec:
  package: crossplane/provider-jet-azure:v0.9.0
```

Apply this configuration with `kubectl apply -f`.

After installing the provider, verify the install with `kubectl get providers`.   

```shell
$ kubectl get providers
NAME                            INSTALLED   HEALTHY   PACKAGE                                AGE
crossplane-provider-jet-azure   True        True      crossplane/provider-jet-azure:v0.9.0   2m16s
```

It may take up to 5 minutes to report `HEALTHY`.

## Create a Kubernetes secret
The provider requires credentials to create and manage Azure resources.

### Install the Azure command-line
Generating an [authentication file](https://docs.microsoft.com/en-us/azure/developer/go/azure-sdk-authorization#use-file-based-authentication) requires the Azure command-line. [Download and install the Azure command-line](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) from Microsoft.

### Create an Azure service principal
Follow the Azure documentation to find your Subscription ID from the [Azure Portal](https://docs.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id).

Using the Subscription ID create a service principal and authentication file.

```
az ad sp create-for-rbac --sdk-auth --role Owner --scopes /subscriptions/<Subscription ID> 
```

The command generates a JSON file like this:
```json
{
  "clientId": "5d73973c-1933-4621-9f6a-9642db949768",
  "clientSecret": "24O8Q~db2DFJ123MBpB25hdESvV3Zy8bfeGYGcSd",
  "subscriptionId": "c02e2b27-21ef-48e3-96b9-a91305e9e010",
  "tenantId": "7060afec-1db7-4b6f-a44f-82c9c6d8762a",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

Save this output as `azure-credentials.json`.

### Create a Kubernetes secret with Azure credentials JSON file
Use `kubectl create secret -n upbound-system` to generate the Kubernetes secret object inside the managed control plane.

`kubectl create secret generic azure-secret -n upbound-system --from-file=creds=./azure-credentials.json`

View the secret with `kubectl describe secret`
```shell
$ kubectl describe secret azure-secret -n upbound-system
Name:         azure-secret
Namespace:    upbound-system
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
creds:  629 bytes
```
## Create a ProviderConfig
Create a `ProviderConfig` Kubernetes configuration file to attach the Azure credentials to the installed official provider.

```yaml
apiVersion: azure.jet.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: upbound-system
      name: azure-secret
      key: creds
```

Apply this configuration with `kubectl apply -f`.

**Note:** the `Providerconfig` value `spec.secretRef.name` must match the `name` of the secret in `kubectl get secrets -n upbound-system` and `spec.SecretRef.key` must match the value in the `Data` section of the secret.

Verify the `ProviderConfig` with `kubectl describe providerconfigs`. 

```yaml
$ kubectl describe providerconfigs
Name:         default
Namespace:
API Version:  azure.jet.crossplane.io/v1alpha1
Kind:         ProviderConfig
# Output truncated
Spec:
  Credentials:
    Secret Ref:
      Key:        creds
      Name:       azure-secret
      Namespace:  upbound-system
    Source:       Secret
```

## Create a managed resource
Create a managed resource to verify the provider is functioning. 

This example creates an Azure resource group.

```yaml
apiVersion: azure.jet.crossplane.io/v1alpha2
kind: ResourceGroup
metadata:
  name: example-rg
spec:
  forProvider:
    location: "East US"
  providerConfigRef:
    name: default
```

**Note:** the `spec.providerConfigRef.name` must match the `ProviderConfig` `metadata.name` value.

Apply this configuration with `kubectl apply -f`.

Use `kubectl get managed` to verify resource group creation.

```shell
$ kubectl get managed
NAME                                             READY   SYNCED   EXTERNAL-NAME   AGE
resourcegroup.azure.jet.crossplane.io/example     True    True     example        64s
```

Upbound created the resource group when the values `READY` and `SYNCED` are `True`.

If the `READY` or `SYNCED` are blank or `False` use `kubectl describe` to understand why.

Here is an example of a failure because the `spec.providerConfigRef.name` value in the `Bucket` doesn't match the `ProviderConfig` `metadata.name`.

```shell
$ kubectl describe bucket.s3.aws.crossplane.io/example
Name:         example
Namespace:
Labels:       <none>
Annotations:  crossplane.io/external-name: example2
API Version:  azure.jet.crossplane.io/v1alpha2
Kind:         ResourceGroup
# Output truncated
Spec:
  Deletion Policy:  Delete
  For Provider:
    Location:  East US
  Provider Config Ref:
    Name:  default
Status:
  At Provider:
  Conditions:
    Last Transition Time:  2022-07-06T15:19:18Z
    Message:               connect failed: cannot get terraform setup: cannot get referenced ProviderConfig: ProviderConfig.azure.jet.crossplane.io "default" not found
    Reason:                ReconcileError
    Status:                False
    Type:                  Synced
Events:
  Type     Reason                   Age                From                                                          Message
  ----     ------                   ----               ----                                                          -------
  Warning  CannotConnectToProvider  11s (x5 over 20s)  managed/azure.jet.crossplane.io/v1alpha2, kind=resourcegroup  cannot get terraform setup: cannot get referenced ProviderConfig: ProviderConfig.azure.jet.crossplane.io "default" not found
```

The output indicates the `ResourceGroup` is using `ProviderConfig` named `default`. The applied `ProviderConfig` is `my-config`. 

```shell
$ kubectl get providerconfig
NAME        AGE
my-config   114s
```

## Delete the managed resource
Remove the managed resource by using `kubectl delete -f` with the same `ResourceGroup` object file. It takes a up to 5 minutes for Kubernetes to delete the resource and complete the command.