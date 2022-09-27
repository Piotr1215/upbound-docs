---
title: "Crossplane Packages"
weight: 250
---

Crossplane _Packages_ are a portable and reusable method to distribute Crossplane settings. Packages are Open Container Initiative (`OCI`) compatible containers. Packages support versioning and dependency mapping.

{{< hint type="note" >}}
This section discusses installing Crossplane packages. For information about building and publishing packages read the <a href="{{<ref "upbound-marketplace/packages">}}">Creating and Publishing Packages</a> section.
{{< /hint >}}

## Package types
Crossplane supports two package types, `Configurations` and `Providers`.

* **`Configuration`** packages combine Crossplane _Composite Resource Definitions_, _Compositions_ and metadata. 
* **`Provider`** packages combine a [Kubernetes controller](https://kubernetes.io/docs/concepts/architecture/controller/) container, associated _Custom Resource Definitions_ (`CRDs`) and metadata. The Crossplane open source [AWS provider package](https://github.com/crossplane-contrib/provider-aws/tree/master/package) is an example a provider's metadata and `CRDs`.

## Install a package
Install packages using Kubernetes manifest files for the `pkg.crossplane.io` API group.

{{< hint type="tip" >}}
Packages hosted in the Upbound Marketplace are available from the `xpkg.upbound.io` domain.  
For any Upbound Marketplace package, replace `marketplace.upbound.io` with `xpkg.upbound.io` for the `package` address.
{{< /hint >}}

{{< tabs "installing" >}}

{{< tab "Install a Configuration Package" >}}
Install a configuration package using a `Configuration` Kubernetes manifest. For example, this manifest installs the Upbound "[AWS reference platform](https://marketplace.upbound.io/configurations/upbound/platform-ref-aws/v0.2.3)."

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: platform-ref-aws
spec:
  package: xpkg.upbound.io/upbound/platform-ref-aws:v0.2.3
```

Verify the configuration installation with `kubectl get pkgrev`

```shell
kubectl get pkgrev
NAME                                                                       HEALTHY   REVISION   IMAGE                                                                   STATE    DEP-FOUND   DEP-INSTALLED   AGE
providerrevision.pkg.crossplane.io/crossplane-provider-aws-066cc5f36957    True      1          registry.upbound.io/crossplane/provider-aws:v0.32.0-rc.0.46.g88bf9b6c   Active                               73s
providerrevision.pkg.crossplane.io/crossplane-provider-helm-b9e90b3c7ff8   True      1          registry.upbound.io/crossplane/provider-helm:v0.10.0                    Active                               68s

NAME                                                                    HEALTHY   REVISION   IMAGE                                             STATE    DEP-FOUND   DEP-INSTALLED   AGE
configurationrevision.pkg.crossplane.io/platform-ref-aws-b15ca268431b   True      1          xpkg.upbound.io/upbound/platform-ref-aws:v0.2.3   Active   2           2               75s
```

{{< /tab >}}

{{< tab "Install a Provider Package" >}}
Install a provider package using a `Provider` Kubernetes manifest. For example, this manifest installs the open source Crossplane provider for AWS.

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws
spec:
  package: xpkg.upbound.io/crossplane/provider-aws:v0.24.1
```

{{< hint type="note" >}}
Upbound Official Providers require a `PackagePullSecret` to authenticate to the Upbound Marketplace.  
The <a href="{{<ref "upbound-marketplace/providers" >}}">Official Providers</a> section contains more information about installing and using Official Providers.
{{< /hint >}}

Apply the manifest with `kubectl apply -f`.

```shell
kubectl apply -f provider.yml
provider.pkg.crossplane.io/provider-aws created
```

Use `kubectl get providers` to view the installed provider.

```shell
kubectl get providers
NAME           INSTALLED   HEALTHY   PACKAGE                                           AGE
provider-aws   True        True      xpkg.upbound.io/crossplane/provider-aws:v0.24.1   8m58s
```
{{< /tab >}}


{{< /tabs >}}

## Authentication with packages
Private Upbound Marketplace repositories and Official Providers require authentication to install.

You can install packages that require authentication in one of two methods:
* Using a `packagePullSecret` in a Kubernetes manifest.  
This method applies a `packagePullSecret` as part of a single Kubernetes manifest to the package.
* Updating the `crossplane` service account to use a `packagePullSecret`.
This method updates the `crossplane` service account to use a `packagePullSecret` across all Crossplane related authentication requests. 

The correct authentication method depends on the specific package and its dependencies.

Use the following table to determine which authentication method to use.

| | Public Dependencies | Private Dependencies |
| ---- | ---- | ---- | 
| **Public Package Repository** | No authentication required. | [Update the `crossplane` service account.](#update-the-crossplane-service-account) | 
| **Private Package Repository** | [Use a `packagePullSecret`.](#use-a-packagepullsecret) | [Update the `crossplane` service account.](#update-the-crossplane-service-account) | 

### Use a `packagePullSecret`

{{< hint type="tip" >}}
More information on creating and using secrets with the Upbound Marketplace is available in the [Authentication]({{<ref "upbound-marketplace/authentication" >}}) section.
{{< /hint >}}

To provide authentication information add a `spec.packagePullSecret` to the package install manifest. For example, to add a `packagePullSecret` to the AWS reference platform manifest:

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: platform-ref-aws
spec:
  package: xpkg.upbound.io/upbound/platform-ref-aws:v0.2.3
  packagePullSecrets:
    - name: package-pull-secret
```

### Update the `crossplane` service account
Some packages include dependencies of other packages to install. For example, a configuration package may include a provider package as a dependency. 

{{< hint type="warning" >}}
`packagePullSecrets` applied to a `Configuration` don't apply to the dependencies.
{{< /hint >}}

To use the `packagePullSecret` for dependent resources you must patch the `crossplane` service account. Crossplane uses the service account to download and install the dependent resources. Patching the `crossplane` service account allows Crossplane to use the `packagePullSecret` across those dependent resources.

To patch the service account use the following `kubectl patch` command.

{{< hint type="note" >}}
If you didn't install Upbound Universal Crossplane in the default `upbound-system` namespace, change the `-n upbound-system` command to match the UXP namespace.
{{< /hint >}}

```shell
kubectl patch serviceaccount crossplane \
  -p "{\"imagePullSecrets\": [{\"name\": \"package-pull-secret\"}]}" \
  -n upbound-system
```

Use `kubectl describe serviceaccount crossplane -n upbound-system` to verify the service account's `Image Pull secret` updated.

<!-- {{/* < highlight shell "hl_lines=14" > */}} -->
```shell
kubectl describe serviceaccount crossplane -n upbound-system
Name:                crossplane
Namespace:           upbound-system
Labels:              app=crossplane
                     app.kubernetes.io/component=cloud-infrastructure-controller
                     app.kubernetes.io/instance=universal-crossplane
                     app.kubernetes.io/managed-by=Helm
                     app.kubernetes.io/name=crossplane
                     app.kubernetes.io/part-of=crossplane
                     app.kubernetes.io/version=1.9.1-up.1
                     helm.sh/chart=universal-crossplane-1.9.1-up.1
Annotations:         meta.helm.sh/release-name: universal-crossplane
                     meta.helm.sh/release-namespace: upbound-system
Image pull secrets:  package-pull-secret
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>
```
<!-- {{/* < /highlight > */}} -->
<!-- 
## Determine package dependencies
Marketplace packages list their dependencies in their Marketplace listing. 

For example, the AWS Platform Reference depends on  `provider-aws` and `provider-helm`. 

![The requirements for a Configuration Package](/uxp/images/configuration-dependencies.png "Package dependencies")
 -->

