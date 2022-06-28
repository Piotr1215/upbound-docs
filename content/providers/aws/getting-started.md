---
title: "Getting Started"
weight: 1
---

To use this official provider, install it into your Upbound control plane, apply a `ProviderConfiguration` and `Configuration` package to create `XRDs` and `Claims`.

## Install the AWS provider
Installing the provider requires the `up` command-line and a managed control plane to install the official provider into. 

### Install the Up command-line
Install the [Up command-line](https://cloud.upbound.io/docs/cli/install) to connect to Upbound managed control planes.

```shell
curl -sL "https://cli.upbound.io" | sh
sudo mv up /usr/local/bin/
```

### Create a managed control plane
*** ---------TODO--------- ***

### Connect to the managed control plane
Generate a kubeconfig file to connect to your managed control plane. First, [generate a user token](https://cloud.upbound.io/docs/upbound-cloud/connecting-to-control-planes/#generate-a-user-token) in Upbound and [find the managed control plane ID](https://cloud.upbound.io/docs/upbound-cloud/connecting-to-control-planes/#use-the-up-command-line).

`up controlplane kubeconfig get --token <token> <control plane ID>`

### Install the official provider into the managed control plane
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

### Verify the provider installation
After installing the provider, verify the install with `kubectl get providers`.   

It may take up to 5 minutes to report `HEALTHY`.

```shell
$ kubectl get provider
NAME           INSTALLED   HEALTHY   PACKAGE                          AGE
provider-aws   True        True      crossplane/provider-aws:master   54s
```
## Configure the provider
The AWS official provider requires credentials to provision AWS resources. 

### Create a Kubernetes secret with AWS credentials
The provider expects an AWS credentials text file containing the `aws_access_key_id` and `aws_secret_access_key`. The [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds) provides information on how to generate these keys.

```ini
[default]
aws_access_key_id = <aws_access_key>
aws_secret_access_key = <aws_secret_key>
```

Use `kubectl create secret` to generate the Kubernetes secret object inside the managed control plane.

`kubectl create secret generic aws-secret -n upbound-system --from-file=<aws_credentials_file.txt>`

### Create a provider configuration with the AWS secret

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

### Install a configuration package
A `Configuration` defines the collection of composite resource definitions, composites and claims. 

Configurations can be manually created or installed from the [Upbound Marketplace](https://marketplace.upbound.io/configurations).

To install an example configuration from the Marketplace, create a `Configuration` Kubernetes configuration file and apply it to the managed control plane.

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: platform-ref-aws
spec:
  package: xpkg.upbound.io/upbound/platform-ref-aws:v0.2.3
```

### Verify configuration details
Inspect the XRDs created with `kubectl get compositeresourcedefinitions`.

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

