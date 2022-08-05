---
title: "Official Providers"
weight: 610
cascade:
  kind: page
---
Upbound creates, maintains, and fully supports a set of Crossplane providers called *official providers*. Both cloud hosted Upbound managed control planes and self-hosted Universal Crossplane (`UXP`) support official providers.  

Official providers aren't supported with open source Crossplane.

## Required software versions

### Up command-line
Official providers require Up command-line version v0.12.0 or later.  

Confirm the version of Up command-line with `up --version`

```command
$ up --version
v0.12.0
```

### Universal Crossplane
UXP supports official providers on the following [releases](https://github.com/upbound/up/releases) or later:
* v1.8.1-up.2
* v1.7.2-up.2
* v1.6.7-up.2

Inspect the `crossplane` deployment to confirm the version of Universal Crossplane.

```
$ kubectl get deployment crossplane -n upbound-system -o 'jsonpath={@.spec.template.spec.containers.*.image}{"\n"}'
upbound/crossplane:v1.8.1-up.2
```

## Install an official provider
The [Upbound Marketplace](https://marketplace.upbound.io/) hosts official providers. Official providers are only available to registered Upbound users. Official providers require a _robot token_ to authenticate to the Upbound Marketplace and install.

{{< hint type="tip" >}}
If you already installed an official provider using an `imagePullSecret` a new secret isn't required.
{{< /hint >}}
### Create a Kubernetes imagePullSecret
Official providers require a Kubernetes `imagePullSecret` to download and install. 

The credentials for the `imagePullSecret` are from an authorized Upbound robot token. Find details on creating robot tokens in the [robot accounts documentation]({{<ref "upbound-cloud/robot-accounts.md" >}}).

#### Universal Crossplane
Create an imagePull Secret with `kubectl create secret docker-registry` command with the following options:
* `--namespace` the same namespace as Upbound. By default this is `upbound-system`.
* `--docker-server` as `xpkg.upbound.io`
* `--docker-username` the _Access ID_ value of the robot token
* `--docker-password` the _Token_ value of the robot token

For example, create an imagePullSecret with the name `upbound-robot-token`
```shell
kubectl create secret docker-registry upbound-robot-token --namespace=upbound-system --docker-server=xpkg.upbound.io --docker-username=42bde5f3-81c1-4243-ab53-e301c71acc90 --docker-password=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI0MmJkZTVmMy04MWMxLTQyNDMtYWI1My1lMzAxYzcxYWNjOTAiLCJzdWIiOiJyb2JvdHxhYWQ0MTk4NC0wOWFmLTQxYWEtYjcxYi0zZGZlNjI0MDI2YTUifQ.bqcW3UZGIFL2yU0rkKbLRhU_TfK4HCi4ckgjtHVT4rLGip5I0lFXTcr7VLdCnNO2c2q_nU7Bf7r05G_ZPBT3yZB85UQhzp7COFHjH5YIQbQFqT3354YS4DMHV_tLp0dtLj-3ojbUbVDtHV2RScqUPaD2s--S6m9Jz7xLuCRnqqYKFeSyyo_4aNrH4AVp--ER8VVzF3tc0WkAgkZ9aGEsbhnDHjECNp0krPMop1Nl6RvJ5KUSGPKZe_yptZMD82JtxcULjPo1sWd8i4G4jd8m567rGW1MzutUtfETNFpjd8BWAwLakZwEyIkfb6B8u6OvgOd0RK-cMCfCPoKvVRxHFQ
```

Verify the secret with `kubectl get secrets`
```shell
$ kubectl get secrets -n upbound-system upbound-robot-token
NAME                  TYPE                             DATA   AGE
upbound-robot-token   kubernetes.io/dockerconfigjson   1      23s
```

#### Upbound Cloud hosted control planes
Create an imagePull Secret with `kubectl create secret docker-registry` command with the following options:
* `<name>` must be `package-pull-secret`
* `--namespace` as `crossplane-system`.
* `--docker-server` as `xpkg.upbound.io`
* `--docker-username` the _Access ID_ value of the robot token
* `--docker-password` the _Token_ value of the robot token

For example, create an imagePullSecret with the name `package-pull-secret`
```shell
kubectl create secret docker-registry package-pull-secret --namespace=crossplane-system --docker-server=xpkg.upbound.io --docker-username=42bde5f3-81c1-4243-ab53-e301c71acc90 --docker-password=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI0MmJkZTVmMy04MWMxLTQyNDMtYWI1My1lMzAxYzcxYWNjOTAiLCJzdWIiOiJyb2JvdHxhYWQ0MTk4NC0wOWFmLTQxYWEtYjcxYi0zZGZlNjI0MDI2YTUifQ.bqcW3UZGIFL2yU0rkKbLRhU_TfK4HCi4ckgjtHVT4rLGip5I0lFXTcr7VLdCnNO2c2q_nU7Bf7r05G_ZPBT3yZB85UQhzp7COFHjH5YIQbQFqT3354YS4DMHV_tLp0dtLj-3ojbUbVDtHV2RScqUPaD2s--S6m9Jz7xLuCRnqqYKFeSyyo_4aNrH4AVp--ER8VVzF3tc0WkAgkZ9aGEsbhnDHjECNp0krPMop1Nl6RvJ5KUSGPKZe_yptZMD82JtxcULjPo1sWd8i4G4jd8m567rGW1MzutUtfETNFpjd8BWAwLakZwEyIkfb6B8u6OvgOd0RK-cMCfCPoKvVRxHFQ
```

Verify the secret with `kubectl get secrets`
```shell
$ kubectl get secrets -n upbound-system package-pull-secret
NAME                  TYPE                             DATA   AGE
package-pull-secret   kubernetes.io/dockerconfigjson   1      3d3h
```

{{< hint type="note" >}}
For cloud-hosted control planes the `name` is `package-pull-secret` and the `namespace` is `crossplane-system`.
Providers can't use secrets created in other namespaces and print an error in the Event log.
```yaml
$ kubectl describe provider
Name:         provider-aws
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  pkg.crossplane.io/v1
Kind:         Provider
# Output truncated
Events:
  Type     Reason         Age                From                                 Message
  ----     ------         ----               ----                                 -------
  Warning  UnpackPackage  2s (x8 over 2m5s)  packages/provider.pkg.crossplane.io  cannot unpack package: failed to fetch package digest from remote: secrets "package-pull-secret" not found
```
{{< /hint >}}

### Install the provider resource
Install a provider by creating a `Provider` Kubernetes resource. Provide the `spec.package` location of the official provider. Provide `spec.packagePullSecrets.name` of the imagePullSecret to use.

For example, install the AWS provider with the following Kubernetes configuration file.

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
    name: provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.5.0
  packagePullSecrets:
    - name: upbound-robot-secret
```

Find provider specific instructions and configurations in their individual documentation pages.

## Versions and releases
Official providers have two relevant release numbers:
* Provider release, for example, `provider-aws:v0.5.0`
* Custom Resource Definition (*CRD*) API version, for example `v1beta1`

### Provider releases
Upbound releases new providers to provide bug fixes and enhancements. Provider versions follow standard semantic versioning (*semver*) standards of `<major>`.`<minor>`.`<patch>` numbering.

**Major version** changes have significant changes to provider behavior or breaking changes to general availability CRD APIs.  

**Minor version** changes expand provider capabilities or create breaking changes to `alpha` or `beta` CRD APIs. Minor versions never change general availability CRD APIs.

**Patch version** changes are bug fixes. Provider capabilities and CRD APIs aren't changed between patch versions. 


### Custom resource definition API versions
The CRDs contained within an official provider follow the standard Kubernetes API versioning and deprecation policy. 

* `v1alpha` - CRDs under `v1alpha` haven't passed through full Upbound quality assurance. `v1alpha1` providers are for testing and experimentation and aren't intended for production deployment.

* `v1beta1` - This identifies a qualified and tested CRD. 
Upbound attempts to ensure a stable CRD API but may require breaking changes in future versions. `v1beta1` may be missing endpoints or settings related to the provider resource.

* `v1beta2` - Like `v1beta1` CRDs all `v1beta2` providers are fully qualified and tested. `v1beta2` contain more features or breaking API changes from `v1beta1`. 

* `v1` - CRDs that reach a `v1` API version have fully defined APIs. Upbound doesn't make breaking API changes until the next provider API version. 

## Support
Official providers are available to all paid Upbound customers. Support for official providers follows the same support model for other Upbound components. 

More information is available on the [support page]({{<ref "getting-started/support.md" >}}).

<!-- TODO
## Coverage

-->