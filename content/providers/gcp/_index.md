---
title: "Official GCP Provider"
weight: 30
---

The Upbound GCP Provider is the officially supported provider for Google Compute Platform (GCP).

View the [GCP Provider Documentation](provider) for details and configuration options. 

## Quickstart

To use this official provider, install it into your Upbound control plane, apply a `ProviderConfiguration`, and create a *managed resource* in GCP via Kubernetes.

This guide walks through the process to create an Upbound managed control plane and install the GCP official provider.
* [Create an Upbound.io user account.](#create-an-upboundio-user-account)
* [Create an Upbound user token.](#create-an-upbound-user-token)
* [Install the `up` command-line.](#install-the-up-command-line)
* [Log in to Upbound.](#log-in-to-upbound)
* [Connect to the managed control plane.](#connect-to-the-managed-control-plane)
* [Install the official GCP provider.](#install-the-official-gcp-provider-in-to-the-managed-control-plane)
* [Generate a Kubernetes secret with your GCP credentials.](#create-a-kubernetes-secret)
* [Create and install a `ProviderConfiguration` for the official GCP provider.](#create-a-providerconfig)
* [Create a *managed resource* and verify GCP connectivity.](#create-a-managed-resource)

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
`up controlplane create my-gcp-controlplane`

Verify control plane creation with the command

`up controlplane list`

The `STATUS` starts as `provisioning` and moves to `ready`.

```shell
$ up controlplane list
NAME                  ID                                     SELF-HOSTED   STATUS
my-gcp-controlplane   322e3c8f-0073-4c01-a7fe-f5cf3202cc1d   false         ready
```

## Connect to the managed control plane
Connecting to a managed control plane requires a `kubeconfig` file to connect to the remote cluster.  

Using the **user token** generated earlier and the control plane ID from `up controlplane list`, generate a kubeconfig context configuration.  

`up controlplane kubeconfig get --token <token> <control plane ID>`

Verify that a new context is available in `kubectl` and is set as the `CURRENT` context.

```shell
$ kubectl config get-contexts
CURRENT   NAME                                           CLUSTER                                        AUTHINFO                                       NAMESPACE
          kubernetes-admin@kubernetes                    kubernetes                                     kubernetes-admin
*         upbound-322e3c8f-0073-4c01-a7fe-f5cf3202cc1d   upbound-322e3c8f-0073-4c01-a7fe-f5cf3202cc1d   upbound-322e3c8f-0073-4c01-a7fe-f5cf3202cc1d
```

**Note:** change the `CURRENT` context with `kubectl config use-context <context name>`.

Confirm your token's access with any `kubectl` command.

```shell
$ kubectl get pods -A
NAMESPACE        NAME                                       READY   STATUS    RESTARTS   AGE
upbound-system   crossplane-745cc78565-lsmb5                1/1     Running   0          80s
upbound-system   crossplane-rbac-manager-766657bc6d-qkqm7   1/1     Running   0          80s
upbound-system   upbound-agent-66d7c4f88f-gkqst             1/1     Running   0          77s
upbound-system   upbound-bootstrapper-c5dccc8fd-lk68n       1/1     Running   0          80s
upbound-system   xgql-6f56c847c7-7nchz                      1/1     Running   2          80s
```

**Note:** if the token is incorrect the `kubectl` command returns an error.
```
$ kubectl get pods -A
Error from server (BadRequest): the server rejected our request for an unknown reason
```

## Install the official GCP provider in to the managed control plane
<!-- Use the marketplace button -->

Install the official provider into the managed control plane with a Kubernetes configuration file. 

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
provider-gcp   True        True      xpkg.upbound.io/crossplane/provider-gcp:v0.20.0   10s
```

It may take up to 5 minutes to report `HEALTHY`.

## Create a Kubernetes secret
The provider requires credentials to create and manage GCP resources.

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

### Create a Kubernetes secret with GCP credentials
Use `kubectl create secret -n upbound-system` to generate the Kubernetes secret object inside the managed control plane.

`kubectl create secret generic gcp-secret -n upbound-system --from-file=creds=./gcp-credentials.json`

## Create a ProviderConfig
Create a `ProviderConfig` Kubernetes configuration file to attach the GCP credentials to the installed official provider.

**Note:** the `ProviderConfg` must contain the correct GCP project ID. The project ID must match the `project_id` from the JSON key file.

```yaml
apiVersion: gcp.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: <PROJECT_ID>
  credentials:
    source: Secret
    secretRef:
      namespace: upbound-system
      name: gcp-secret
      key: creds
```

Apply this configuration with `kubectl apply -f`.

**Note:** the `Providerconfig` value `spec.secretRef.key` must match the name of the secret.

Verify the `ProviderConfig` with `kubectl describe providerconfigs.gcp.crossplane.io`. 

```yaml
$ kubectl describe providerconfigs.gcp.crossplane.io
Name:         default
Namespace:
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

## Create a managed resource
Create a managed resource to verify the provider is functioning. 

This example creates a GCP storage bucket, which requires a globally unique name. 

Generate a unique bucket name from the command line.

`echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10)`

For example
```
$ echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10)
upbound-bucket-21e85e732
```

Use this bucket name for `metadata.annotations.crossplane.io/external-name` value.

Create a `Bucket` configuration file.

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

**Note:** the `spec.providerConfigRef.name` must match the `ProviderConfig` `metadata.name` value.

Apply this configuration with `kubectl apply -f`.

Use `kubectl get managed` to verify bucket creation.

```shell
$ kubectl get managed
NAME                                       READY   SYNCED   STORAGE_CLASS    LOCATION   AGE
bucket.storage.gcp.crossplane.io/example   True    True     MULTI_REGIONAL   US         5s
```

Upbound created the bucket when the values `READY` and `SYNCED` are `True`.

If the `READY` or `SYNCED` are blank or `False` use `kubectl describe` to understand why.

Here is an example of a failure because the `Bucket` `spec.providerConfigRef.name` value doesn't match the `ProviderConfig` `metadata.name`.

```shell
$ kubectl get managed
NAME                                       READY   SYNCED   STORAGE_CLASS    LOCATION   AGE
bucket.storage.gcp.crossplane.io/example           False    MULTI_REGIONAL   US         24s

$ kubectl describe bucket.storage.gcp.crossplane.io/example
Name:         example
Namespace:
Labels:       <none>
Annotations:  crossplane.io/external-name: crossplane-example-bucket-d1690f7f4cec26513794
API Version:  storage.gcp.crossplane.io/v1alpha3
Kind:         Bucket
Metadata:
  Creation Timestamp:  2022-07-01T13:06:15Z
  Generation:          1
  Managed Fields:
    API Version:  storage.gcp.crossplane.io/v1alpha3
    Fields Type:  FieldsV1
    fieldsV1:
      f:status:
        .:
        f:attributes:
        f:conditions:
    Manager:      crossplane-gcp-provider
    Operation:    Update
    Subresource:  status
    Time:         2022-07-01T13:06:15Z
    API Version:  storage.gcp.crossplane.io/v1alpha3
    Fields Type:  FieldsV1
    fieldsV1:
      f:metadata:
        f:annotations:
          .:
          f:crossplane.io/external-name:
          f:kubectl.kubernetes.io/last-applied-configuration:
      f:spec:
        .:
        f:deletionPolicy:
        f:location:
        f:providerConfigRef:
          .:
          f:name:
        f:storageClass:
    Manager:         kubectl-client-side-apply
    Operation:       Update
    Time:            2022-07-01T13:06:15Z
  Resource Version:  1932
  UID:               f5dece85-774d-48ae-acec-f91218eb6622
Spec:
  Deletion Policy:  Delete
  Location:         US
  Provider Config Ref:
    Name:         gcp-provider
  Storage Class:  MULTI_REGIONAL
Status:
  Attributes:
  Conditions:
    Last Transition Time:  2022-07-01T13:06:15Z
    Message:               connect failed: ProviderConfig.gcp.crossplane.io "gcp-provider" not found
    Reason:                ReconcileError
    Status:                False
    Type:                  Synced
Events:
  Type     Reason                   Age               From                                      Message
  ----     ------                   ----              ----                                      -------
  Warning  CannotConnectToProvider  3s (x6 over 32s)  managed/bucket.storage.gcp.crossplane.io  ProviderConfig.gcp.crossplane.io "gcp-provider" not found
```

## Delete the managed resource
Remove the managed resource by using `kubectl delete -f` with the same `Bucket` object file.