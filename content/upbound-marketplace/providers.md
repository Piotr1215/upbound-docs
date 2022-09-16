---
title: "Official Providers"
weight: 120
cascade:
  kind: page
---
Upbound creates, maintains and supports a set of Crossplane providers called *official providers*.  
Only [Universal Crossplane (`UXP`)]({{<ref "uxp/" >}}) supports official providers.   

{{<hint type="caution">}}
Official providers aren't supported with open source Crossplane.
{{< /hint >}}

## Find official providers
Identify official providers in the marketplace with the `by Upbound` gold seal.
{{< figure src="/images/marketplace/provider-by-upbound.png" alt="example official provider with a by Upbound seal" >}}

Also find official providers by filtering a [search in the marketplace](https://marketplace.upbound.io/providers?tier=official) to just `Official`.

{{< figure src="/images/marketplace/official-provider-search-filter.png" alt="a marketplace search filter with Providers and Official filters set" >}}
## Required Universal Crossplane versions
UXP supports official providers on the following [releases](https://github.com/upbound/up/releases) or later:
* v1.8.1-up.2
* v1.7.2-up.2
* v1.6.7-up.2

Inspect the `crossplane` deployment to confirm the version of Universal Crossplane.

```shell
kubectl get deployment crossplane -n upbound-system -o 'jsonpath={@.spec.template.spec.containers.*.image}{"\n"}'
upbound/crossplane:v1.8.1-up.2
```

## Install an official provider
The [Upbound Marketplace](https://marketplace.upbound.io/) hosts official providers. Official providers are only available to registered Upbound users. Official providers require a _robot token_ to authenticate to the Upbound Marketplace and install.

{{< hint type="tip" >}}
If you already installed an official provider using an `imagePullSecret` a new secret isn't required.
{{< /hint >}}

### Authenticate to the Upbound Marketplace
Installing providers requires your Kubernetes cluster to authenticate to the Upbound Marketplace with an `image pull secret`. 

Instructions for creating an `image pull secret` are in the [authentication]({{<ref "authentication" >}}) section. 

### Install the provider resource
Install a provider by creating a `Provider` Kubernetes resource. 

{{<hint type="important" >}}
Create a Kubernetes `secret` for the Upbound Marketplace before installing an official provider.

How to install the Kubernetes secret is in the [authentication]({{<ref "authentication" >}}) section.
{{< /hint >}}

Provide the `spec.package` location of the official provider from the Upbound Marketplace listing. 

Provide `spec.packagePullSecrets.name` of the Kubernetes `secret` object to use in authenticating to the Upbound Marketplace.

For example, install the AWS provider with the following Kubernetes configuration file.

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
    name: provider-aws
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.5.0
  packagePullSecrets:
    - name: package-pull-secret
```

Find provider specific instructions and configurations in their individual documentation pages within the Upbound Marketplace.

## Versions and releases
Official providers have two relevant release numbers:
* Provider release, for example, `provider-aws:v0.5.0`
* Custom Resource Definition (*CRD*) API version, for example `v1beta1`

### Provider releases
Upbound releases new providers to provide bug fixes and enhancements. Provider versions follow standard semantic versioning (*semver*) standards of `<major>`.`<minor>`.`<patch>` numbering.

**Major version** changes have significant changes to provider behavior or breaking changes to general availability CRD APIs.  

**Minor version** changes expand provider capabilities or create breaking changes to `alpha` or `beta` CRD APIs. Minor versions never change general availability CRD APIs.

**Patch version** changes are bug fixes. Provider capabilities and CRD APIs aren't changed between patch versions. 

<!--
### Custom resource definition API versions
The CRDs contained within an official provider follow the standard Kubernetes API versioning and deprecation policy. 

* `v1alpha` - CRDs under `v1alpha` haven't passed through full Upbound quality assurance. `v1alpha1` providers are for testing and experimentation and aren't intended for production deployment.

* `v1beta1` - This identifies a qualified and tested CRD. 
Upbound attempts to ensure a stable CRD API but may require breaking changes in future versions. `v1beta1` may be missing endpoints or settings related to the provider resource.

* `v1beta2` - Like `v1beta1` CRDs all `v1beta2` providers are fully qualified and tested. `v1beta2` contain more features or breaking API changes from `v1beta1`. 

* `v1` - CRDs that reach a `v1` API version have fully defined APIs. Upbound doesn't make breaking API changes until the next provider API version. 
-->

## Support
Official providers are available to all paid Upbound customers. Support for official providers follows the same support model for other Upbound components. 

More information is available on the [support page]({{<ref "../support.md" >}}).

<!-- TODO
## Coverage

-->