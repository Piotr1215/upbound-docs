---
title: "Community Providers Quickstart"
weight: 5
---

This quickstart guide walks you through installing Upbound Universal Crossplane (UXP), installing a provider and deploying a `managed resource` to verify connectivity to the provider.

{{<hint type="tip" >}}
This guide uses Crossplane open source [Community Providers](https://github.com/crossplane-contrib).

Upbound recommends using [official providers]({{<ref "/upbound-marketplace/providers" >}}) for registered Upbound customers.
{{< /hint >}}

<!-- omit in toc -->
## Prerequisites
Upbound requires an existing Kubernetes cluster to install UXP into. Any Kubernetes distribution supports UXP, including bare metal, [Amazon EKS](https://aws.amazon.com/eks/), [Google GKE](https://cloud.google.com/kubernetes-engine), [Microsoft Azure AKS](https://azure.microsoft.com/en-us/services/kubernetes-service/). For testing, [kind](https://kind.sigs.k8s.io/) supports UXP installation as well.

- [Install the Up command-line](#install-the-up-command-line)
- [Install Upbound Universal Crossplane](#install-upbound-universal-crossplane)
- [Install a Crossplane provider](#install-a-crossplane-provider)
- [Supply cloud provider credentials](#supply-cloud-provider-credentials)
- [Create a ProviderConfig](#create-a-providerconfig)
- [Create a managed resource](#create-a-managed-resource)

## Install the Up command-line
Install the [`up` command-line]({{<ref "cli">}}) to connect to Upbound managed control planes. 

{{<hint type="important" >}}
The `up` command-line relies on the `kubeconfig` file to connect to the Kubernetes cluster and deploy resources. Install `up` on a machine with access to the Kubernetes cluster and a `kubeconfig` file.
{{< /hint >}}

```shell
curl -sL "https://cli.upbound.io" | sh
sudo mv up /usr/local/bin/
```

## Install Upbound Universal Crossplane
Universal Crossplane (UXP) is a distribution of the open source Crossplane project. Upbound builds and maintains UXP as an open source project.

{{<hint type="tip">}}
`Crossplane` is the software installed into the Kubernetes cluster. `UXP` is a specific version of Crossplane created by Upbound.  

This guide refers to `UXP` for the collection of deployed Kubernetes objects and `crossplane` as one of the objects deployed and configured.
{{</hint >}}

Install Upbound Universal Crossplane with the Up command-line.

```shell
up uxp install
```

{{<hint type="note">}}
UXP creates and installs these pods into the `upbound-system` namespace. 
{{< /hint >}}

Verify the UXP pods are running with `kubectl get pods -n upbound-system`

```shell
$ kubectl get pods -n upbound-system
NAME                                        READY   STATUS    RESTARTS      AGE
crossplane-7fdfbd897c-pmrml                 1/1     Running   0             68m
crossplane-rbac-manager-7d6867bc4d-v7wpb    1/1     Running   0             68m
upbound-bootstrapper-5f47977d54-t8kvk       1/1     Running   0             68m
xgql-7c4b74c458-5bf2q                       1/1     Running   3 (67m ago)   68m
```

## Install a Crossplane provider
Providers are Crossplane objects that provide instructions for how Crossplane communicates to non-Kubernetes API endpoints. For example, the `AWS provider` allows Crossplane to communicate to AWS cloud APIs.

The [Upbound Marketplace](https://marketplace.upbound.io) provides a collection of providers and configurations to select from. Other "community" providers are available in the [Crossplane Contrib](https://github.com/crossplane-contrib) repository.

Select the tab of the provider to provision and deploy resources in.

{{< tabs "provider" >}}

{{< tab "AWS" >}}

<!-- omit in toc -->
### AWS provider
Find information about the [AWS provider](https://marketplace.upbound.io/providers/crossplane/provider-aws/) on the Upbound Marketplace.

Deploy the provider with this Kubernetes configuration file:

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
$ kubectl get provider
NAME           INSTALLED   HEALTHY   PACKAGE                                           AGE
provider-aws   True        True      xpkg.upbound.io/crossplane/provider-aws:v0.24.1   7s
```

{{<hint type="note">}}
It may take up to 5 minutes `HEALTHY` to report `True`.
{{< /hint >}}

{{< /tab >}}

{{< tab "Azure" >}}
<!-- omit in toc -->
### Azure provider
Find information about the [Azure provider](https://marketplace.upbound.io/providers/crossplane/provider-azure/) on the Upbound Marketplace.

Deploy the provider with this Kubernetes configuration file:

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-azure
spec:
  package: xpkg.upbound.io/crossplane/provider-azure:v0.18.1
```

Apply this configuration with `kubectl apply -f`.

After installing the provider, verify the install with `kubectl get providers`.
```shell
$ kubectl get provider
NAME             INSTALLED   HEALTHY   PACKAGE                                             AGE
provider-azure   True        True      xpkg.upbound.io/crossplane/provider-azure:v0.18.1   9s
```

{{<hint type="note">}}
It may take up to 5 minutes `HEALTHY` to report `True`.
{{< /hint >}}


{{< /tab >}}

{{< tab "GCP" >}}
<!-- omit in toc -->
### GCP provider
Find information about the [GCP provider](https://marketplace.upbound.io/providers/crossplane/provider-gcp/) on the Upbound Marketplace.

Deploy the provider with this Kubernetes configuration file:

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-gcp
spec:
  package: xpkg.upbound.io/crossplane/provider-gcp:v0.20.0
```

Apply this configuration with `kubectl apply -f`.

After installing the provider, verify the install with `kubectl get providers`.
```shell
$ kubectl get provider
NAME           INSTALLED   HEALTHY   PACKAGE                                           AGE
provider-gcp   True        True      xpkg.upbound.io/crossplane/provider-gcp:v0.20.0   8s
```

{{<hint type="note">}}
It may take up to 5 minutes `HEALTHY` to report `True`.
{{< /hint >}}


{{< /tab >}}

{{< /tabs >}}


## Supply cloud provider credentials
<!-- vale Microsoft.Terms = NO -->
<!-- disable Microsoft terms to allow "the cloud provider" -->
Crossplane provisions cloud resources by calling cloud APIs. This requires Crossplane to use cloud credentials to authenticate to the cloud provider.

This requires creating a Kubernetes `secret` object with the cloud credentials. A `ProviderConfig`  instructs the provider to use this secret to authenticate to the cloud resource.
<!-- vale Microsoft.Terms = YES -->

{{< tabs "creds" >}}

{{< tab "AWS" >}}
<!-- omit in toc -->
### Generate an AWS key-pair file
Create a text file containing the AWS account `aws_access_key_id` and `aws_secret_access_key`. The [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds) provides information on how to generate these keys.

```ini
[default]
aws_access_key_id = <aws_access_key>
aws_secret_access_key = <aws_secret_key>
```

Save this text file as `aws-credentials.txt`.

<!-- omit in toc -->
### Create a Kubernetes secret with AWS credentials
Use `kubectl create secret -n upbound-system` to generate the Kubernetes secret object inside the managed control plane.

{{<hint type="warning" >}}
Secrets stored in Kubernetes aren't encrypted.
{{< /hint >}}

```command
kubectl create secret generic aws-secret \
-n upbound-system \
--from-file=creds=./aws-credentials.txt
```

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
creds:  127 bytes
```
  
<br />


{{< /tab >}}

{{< tab "Azure" >}}

<!-- omit in toc -->
### Install the Azure command-line
Generating an [authentication file](https://docs.microsoft.com/en-us/azure/developer/go/azure-sdk-authorization#use-file-based-authentication) requires the Azure command-line. [Download and install the Azure command-line](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) from Microsoft.

<!-- omit in toc -->
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

<!-- omit in toc -->
### Create a Kubernetes secret with Azure credentials JSON file
Use `kubectl create secret -n upbound-system` to generate the Kubernetes secret object inside the managed control plane.

```shell
kubectl create secret generic azure-secret \
-n upbound-system \
--from-file=creds=./azure-credentials.json
```

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
<br />


{{< /tab >}}

{{< tab "GCP" >}}
<!-- omit in toc -->
### Generate a GCP JSON key file
Create a JSON key file containing the GCP account credentials. GCP provides documentation on [how to create a key file](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

Here is an example key file:  
```json
{
  "type": "service_account",
  "project_id": "caramel-goat-354919",
  "private_key_id": "e97e40a4a27661f12345678f4bd92139324dbf46",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCwA+6MWRhmcPB3\nF/irb5MDPYAT6BWr7Vu/16U8FbCHk7xtsAWYjKXKHu5mGzum4F781sM0aMCeitlv\n+jr2y7Ny23S9uP5W2kfnD/lfj0EjCdfoaN3m7W0j4DrriJviV6ESeSdb0Ehg+iEW\ngNrkb/ljigYgsSLMuemby5lvJVINUazXJtGUEZew+iAOnI4/j/IrDXPCYVNo5z+b\neiMsDYWfccenWGOQf1hkbVWyKqzsInxu8NQef3tNhoUXNOn+/kgarOA5VTYvFUPr\n2l1P9TxzrcYuL8XK++HjVj5mcNaWXNN+jnFpxjMIJOiDJOZoAo0X7tuCJFXtAZbH\n9P61GjhbAgMBAAECggEARXo31kRw4jbgZFIdASa4hAXpoXHx4/x8Q9yOR4pUNR/2\nt+FMRCv4YTEWb01+nV9hfzISuYRDzBEIxS+jyLkda0/+48i69HOTAD0I9VRppLgE\ne97e40a4a27661f12345678f4bd92139324dbf46+2H7ulQDtbEgfcWpNMQcL2JiFq+WS\neh3H0gHSFFIWGnAM/xofrlhGsN64palZmbt2YiKXcHPT+WgLbD45mT5j9oMYxBJf\nPkUUX5QibSSBQyvNqCgRKHSnsY9yAkoNTbPnEV0clQ4FmSccogyS9uPEocQDefuY\nY7gpwSzjXpaw7tP5scK3NtWmmssi+dwDadfLrKF7oQKBgQDjIZ+jwAggCp7AYB/S\n6dznl5/G28Mw6CIM6kPgFnJ8P/C/Yi2y/OPKFKhMs2ecQI8lJfcvvpU/z+kZizcG\nr/7iRMR/SX8n1eqS8XfWKeBzIdwQmiKyRg2AKelGKljuVtI8sXKv9t6cm8RkWKuZ\n9uVroTCPWGpIrh2EMxLeOrlm0QKBgQDGYxoBvl5GfrOzjhYOa5GBgGYYPdE7kNny\nhpHE9CrPZFIcb5nGMlBCOfV+bqA9ALCXKFCr0eHhTjk9HjHfloxuxDmz34vC0xXG\ncegqfV9GNKZPDctysAlCWW/dMYw4+tzAgoG9Qm13Iyfi2Ikll7vfeMX7fH1cnJs0\nnYpN9LYPawKBgQCwMi09QoMLGDH+2pLVc0ZDAoSYJ3NMRUfk7Paqp784VAHW9bqt\n1zB+W3gTyDjgJdTl5IXVK+tsDUWu4yhUr8LylJY6iDF0HaZTR67HHMVZizLETk4M\nLfvbKKgmHkPO4NtG6gEmMESRCOVZUtAMKFPhIrIhAV2x9CBBpb1FWBjrgQKBgQCj\nkP3WRjDQipJ7DkEdLo9PaJ/EiOND60/m6BCzhGTvjVUt4M22XbFSiRrhXTB8W189\noZ2xrGBCNQ54V7bjE+tBQEQbC8rdnNAtR6kVrzyoU6xzLXp6Wq2nqLnUc4+bQypT\nBscVVfmO6stt+v5Iomvh+l+x05hAjVZh8Sog0AxzdQKBgQCMgMTXt0ZBs0ScrG9v\np5CGa18KC+S3oUOjK/qyACmCqhtd+hKHIxHx3/FQPBWb4rDJRsZHH7C6URR1pHzJ\nmhCWgKGsvYrXkNxtiyPXwnU7PNP9JNuCWa45dr/vE/uxcbccK4JnWJ8+Kk/9LEX0\nmjtDm7wtLVlTswYhP6AP69RoMQ==\n-----END PRIVATE KEY-----\n",
  "client_email": "my-sa-313@caramel-goat-354919.iam.gserviceaccount.com",
  "client_id": "103735491955093092925",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/my-sa-313%40caramel-goat-354919.iam.gserviceaccount.com"
}
```

Save this JSON file as `gcp-credentials.json`.

<!-- omit in toc -->
### Create a Kubernetes secret with GCP credentials
Use `kubectl create secret -n upbound-system` to generate the Kubernetes secret object inside the managed control plane.

```command
kubectl create secret generic gcp-secret \
-n upbound-system \
--from-file=creds=./gcp-credentials.json
```

{{< /tab >}}

{{< /tabs >}}

## Create a ProviderConfig

{{<tabs "ProviderConfig" >}}

{{< tab "AWS" >}}
<!-- omit in toc -->
### Create an AWS ProviderConfig
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

{{<hint type="note" >}}
The provider looks for a Kubernetes secret with the same name as the  `ProviderConfig` configuration in `spec.secretRef.name`.  

The `name` is the name of the Kubernetes `secret` and the `key` is the `key` from the `Data` field of the Kubernetes secret.
{{< /hint >}}

Verify the `ProviderConfig` with `kubectl describe providerconfigs`. 

```yaml
$ kubectl describe providerconfigs
Name:         default
Namespace:
Labels:       <none>
Annotations:  <none>
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
{{< /tab >}}

{{< tab "Azure" >}}
<!-- omit in toc -->
### Create an Azure ProviderConfig
Create a `ProviderConfig` Kubernetes configuration file to attach the Azure credentials to the installed official provider.

```yaml
apiVersion: azure.crossplane.io/v1beta1
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

{{<hint type="note" >}}
The provider looks for a Kubernetes secret with the same name as the  `ProviderConfig` configuration in `spec.secretRef.name`.  

The `name` is the name of the Kubernetes `secret` and the `key` is the `key` from the `Data` field of the Kubernetes secret.
{{< /hint >}}

Verify the `ProviderConfig` with `kubectl describe providerconfigs`. 

```yaml
$ kubectl describe providerconfigs
Name:         default
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  azure.crossplane.io/v1beta1
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

{{< /tab >}}

{{< tab "GCP" >}}
<!-- omit in toc -->
### Create a GCP ProviderConfig
Create a `ProviderConfig` Kubernetes configuration file to attach the GCP credentials to the installed official provider.

**Note:** the `ProviderConfg` must contain the correct GCP project ID. The project ID must match the `project_id` from the JSON key file.

```yaml
apiVersion: gcp.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: "upbound-product-team"
  credentials:
    source: Secret
    secretRef:
      namespace: upbound-system
      name: gcp-secret
      key: creds
```

Apply this configuration with `kubectl apply -f`.

{{<hint type="note" >}}
The provider looks for a Kubernetes secret with the same name as the  `ProviderConfig` configuration in `spec.secretRef.name`.  

The `name` is the name of the Kubernetes `secret` and the `key` is the `key` from the `Data` field of the Kubernetes secret.
{{< /hint >}}

Verify the `ProviderConfig` with `kubectl describe providerconfigs`. 

```yaml
$ kubectl describe providerconfigs
Name:         default
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  gcp.crossplane.io/v1beta1
Kind:         ProviderConfig
# Output truncated
Spec:
  Credentials:
    Secret Ref:
      Key:        creds
      Name:       gcp-secret
      Namespace:  upbound-system
    Source:       Secret
  Project ID:     caramel-goat-354919
```
{{< /tab >}}
{{< /tabs >}}

## Create a managed resource
Crossplane `managed resources` are objects that exist outside of Kubernetes but Crossplane manages. Any cloud resource created by Crossplane is a `managed resource`.

<!-- vale Microsoft.Terms = NO -->
<!-- disable Microsoft terms to allow "the cloud provider" -->
Creating a managed resource verifies that Crossplane can communicate and authenticate to the cloud provider.  

{{<hint type="note" >}}
The speed of the cloud provider's API determines the time required for a managed resource to be ready.
{{</hint>}}
<!-- vale Microsoft.Terms = YES -->

{{< tabs "managed-resource" >}}

{{< tab "AWS" >}}
<!-- omit in toc -->
This example creates a `Bucket` managed resource. A `Bucket` managed resource represents an AWS S3 storage bucket, which requires a globally unique name. 

Generate a unique bucket name from the command line.

`echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 14)`

For example
```
$ echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10)
upbound-bucket-fb8360b455dd9
```

Use this bucket name for `metadata.name` value.

Create a `Bucket` configuration file. Replace `<BUCKET NAME>` with the `upbound-bucket-` generated name.

```yaml
apiVersion: s3.aws.crossplane.io/v1beta1
kind: Bucket
metadata:
  name: example
  annotations:
    crossplane.io/external-name: <BUCKET NAME>
spec:
  forProvider:
    locationConstraint: us-east-1
    acl: "private"
  providerConfigRef:
    name: default
```

{{<hint type="tip" >}}
Get more information and see all the `Bucket` options in the <a href="https://marketplace.upbound.io/providers/crossplane/provider-aws/v0.24.1/resources/s3.aws.crossplane.io/Bucket/">CRD documentation</a> on the Upbound Marketplace.
{{< /hint >}}

Apply this configuration with `kubectl apply -f`.

Use `kubectl get bucket` to verify bucket creation.

```shell
$ kubectl get bucket
NAME      READY   SYNCED   AGE
example   True    True     3s
```

Crossplane created the bucket when the values `READY` and `SYNCED` are `True`.

Details about the bucket are available in `kubectl describe bucket`

```yaml
$ kubectl describe bucket
Name:         example
Namespace:
Labels:       <none>
Annotations:  crossplane.io/external-create-pending: 2022-08-25T00:09:40Z
              crossplane.io/external-create-succeeded: 2022-08-25T00:09:41Z
              crossplane.io/external-name: upbound-bucket-fb8360b455dd9
API Version:  s3.aws.crossplane.io/v1beta1
Kind:         Bucket
# Output truncated
Spec:
  Deletion Policy:  Delete
  For Provider:
    Acl:                  private
    Location Constraint:  us-east-1
    Payment Configuration:
      Payer:  BucketOwner
  Provider Config Ref:
    Name:  default
Status:
  At Provider:
    Arn:  arn:aws:s3:::upbound-bucket-fb8360b455dd9
  Conditions:
    Last Transition Time:  2022-08-25T00:09:42Z
    Reason:                Available
    Status:                True
    Type:                  Ready
    Last Transition Time:  2022-08-25T00:09:41Z
    Reason:                ReconcileSuccess
    Status:                True
    Type:                  Synced
Events:
  Type    Reason                   Age   From                                 Message
  ----    ------                   ----  ----                                 -------
  Normal  CreatedExternalResource  47s   managed/bucket.s3.aws.crossplane.io  Successfully requested creation of external resource
```

{{<hint type="note" >}}
If the `Bucket` doesn't report `SYNCED` as `true` use `kubectl describe bucket` to try and understand why. 
{{< expand "Bad Request error">}}
An event log indicating `Bad Request` may be due to bad AWS credentials.

```shell
$ kubectl get bucket -w
NAME                           READY   SYNCED   AGE
upbound-bucket-fb8360b455dd9           False    4s
```

```yaml
$ kubectl describe bucket
Name:         example
Namespace:
Labels:       <none>
Annotations:  crossplane.io/external-name: upbound-bucket-fb8360b455dd9
API Version:  s3.aws.crossplane.io/v1beta1
Kind:         Bucket
# Output truncated
Status:
  At Provider:
    Arn:
  Conditions:
    Last Transition Time:  2022-08-24T23:56:23Z
    Message:               observe failed: failed to query Bucket: api error BadRequest: Bad Request
    Reason:                ReconcileError
    Status:                False
    Type:                  Synced
Events:
  Type     Reason                         Age              From                                 Message
  ----     ------                         ----             ----                                 -------
  Warning  CannotObserveExternalResource  3s (x4 over 9s)  managed/bucket.s3.aws.crossplane.io  failed to query Bucket: api error BadRequest: Bad Request
```
{{< /expand >}}

{{< /hint >}}

<!-- omit in toc -->
### Delete the AWS managed resource
Remove the managed resource by using `kubectl delete -f` with the same `Bucket` object file. Verify removal of the bucket with `kubectl get bucket`

```shell
$ kubectl get bucket
No resources found
```

{{< /tab >}}

{{< tab "Azure" >}}
<!-- omit in toc -->
This example creates a `ResourceGroup` managed resource. A `ResourceGroup` managed resource represents an Azure resource group. 

```yaml
apiVersion: azure.crossplane.io/v1alpha3
kind: ResourceGroup
metadata:
  name: example-rg
spec:
  location: "East US"
```

{{<hint type="tip" >}}
Get more information and see all the `ResourceGroup` options in the <a href="https://marketplace.upbound.io/providers/crossplane/provider-azure/v0.18.1/resources/azure.crossplane.io/ResourceGroup/v1alpha3">CRD documentation</a> on the Upbound Marketplace.
{{< /hint >}}

Apply this configuration with `kubectl apply -f`.

Use `kubectl get resourcegroups` to verify resource group creation.

```shell
$ kubectl get resourcegroups
NAME         READY   SYNCED
example-rg   True    True
```

Crossplane created the resource group when the values `READY` and `SYNCED` are `True`.

<!-- omit in toc -->
### Delete the Azure managed resource
Remove the managed resource by using `kubectl delete -f` with the same `ResourceGroup` object file. Verify removal of the resource group with `kubectl get resourcegroups`

```shell
$ kubectl describe resourcegroups
No resources found in default namespace.
```
{{< /tab >}}

{{< tab "GCP" >}}
<!-- omit in toc -->
This example creates a `Bucket` managed resource. A `Bucket` managed resource represents a GCP storage bucket, which requires a globally unique name. 

Generate a unique bucket name from the command line.

`echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 14)`

For example
```
$ echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10)
upbound-bucket-fb8360b455dd9
```

Use this bucket name for `metadata.name` value.

Create a `Bucket` configuration file. Replace `<BUCKET NAME>` with the `upbound-bucket-` generated name.

```yaml
apiVersion: storage.gcp.crossplane.io/v1alpha3
kind: Bucket
metadata:
  name: example
  labels:
  annotations:
    crossplane.io/external-name: <BUCKET NAME>
spec:
  location: US
  storageClass: MULTI_REGIONAL
  providerConfigRef:
    name: default
  deletionPolicy: Delete
```

{{<hint type="tip" >}}
Get more information and see all the `Bucket` options in the <a href="https://marketplace.upbound.io/providers/crossplane/provider-gcp/v0.20.0/resources/storage.gcp.crossplane.io/Bucket/v1alpha3">CRD documentation</a> on the Upbound Marketplace.
{{< /hint >}}

Apply this configuration with `kubectl apply -f`.

Use `kubectl get bucket` to verify bucket creation.

```shell
$ kubectl get bucket
NAME      READY   SYNCED   STORAGE_CLASS    LOCATION   AGE
example   True    True     MULTI_REGIONAL   US         3s
```

Crossplane created the bucket when the values `READY` and `SYNCED` are `True`.

Details about the bucket are available in `kubectl describe bucket`

<!-- omit in toc -->
### Delete the GCP managed resource
Remove the managed resource by using `kubectl delete -f` with the same `Bucket` object file. Verify removal of the bucket with `kubectl get bucket`

```shell
$ kubectl get bucket
No resources found
```
{{< /tab >}}

{{< /tabs >}}

<!-- vale Microsoft.Terms = NO -->
<!-- disable Microsoft terms to allow "the cloud provider" -->
A deployed managed resource indicates that UXP installed in the Kubernetes cluster, a Crossplane is using the `Provider` and authenticating with the `ProviderConfig` to the cloud provider.
<!-- vale Microsoft.Terms = YES -->