---
title: "Azure Provider Configuration"
weight: 200
---

## Install the provider
Install the Upbound official AWS provider with the following configuration file

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
    name: provider-aws
spec:
    package: "crossplane/provider-aws:master"
```

Apply the configuration with `kubectl apply -f`

View the [Provider CRD definition](https://doc.crds.dev/github.com/crossplane/crossplane/pkg.crossplane.io/Provider/v1@v1.8.1) to view all available `Provider` options.

## Configure the provider
The AWS provider requires credentials for authentication to AWS. The AWS provider consumes the credentials from a Kubernetes secret object.

### Generate a Kubernetes secret
To create the Kubernetes secret, create a text file containing the AWS account `aws_access_key_id` and `aws_secret_access_key`. The [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds)

```ini
[default]
aws_access_key_id = <aws_access_key>
aws_secret_access_key = <aws_secret_key>
```

Create the secret with the command  

`kubectl create secret generic <secret name> --from-file=<aws_credentials_file.txt>`

**Note:** for hosted control planes, use the `-n upbound-system` flag to provision the secret inside the managed control plane.

### Create a ProviderConfig object
Apply the secret in a `ProviderConfig` Kubernetes configuration file.

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

**Note:** the `spec.credentials.secretRef.name` must match the `name` in the `kubectl create secret generic <name>` command.

View the [ProviderConfig CRD definition](https://doc.crds.dev/github.com/crossplane/provider-aws/aws.crossplane.io/ProviderConfig/v1beta1@v0.28.1) to view all available `ProviderConfig` options.
