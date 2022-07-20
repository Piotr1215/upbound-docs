---
title: "Official Providers"
weight: 610
---
Upbound creates, maintains, and fully supports a set of Crossplane providers called *official providers*. Both cloud hosted Upbound managed control planes and self-hosted Universal Crossplane (`UXP`) support official providers.  

Official providers aren't supported with open source Crossplane.

## Install an official provider
The [Upbound Marketplace](https://marketplace.upbound.io/) hosts official providers. Install a provider by creating a `Provider` Kubernetes resource and providing the `spec.package` location of the official provider.

For example, install the AWS provider with the following Kubernetes configuration file.

```yaml
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
    name: provider-aws
spec:
    package: "crossplane/provider-aws:master"
```

Find provider specific instructions and configurations in their individual documentation pages.

## Versions and releases
Official providers have two relevant release numbers:
* Provider release, for example, `provider-aws:v0.24.1`
* Custom Resource Definition (*CRD*) API version, for example `v1beta1`

### Provider releases
Upbound releases new providers to provide bug fixes and enhancements. Provider versions follow standard semantic versioning (*semver*) standards of `<major>`.`<minor>`.`<patch>` numbering.

**Major version** changes have significant changes to provider behavior or breaking changes to general availability CRD APIs.  

**Minor version** changes expand provider capabilities or create breaking changes to `alpha` or `beta` CRD APIs. Minor versions never change general availability CRD APIs.

**Patch version** changes are bug fixes. Provider capabilities and CRD APIs aren't changed between patch versions. 


### Custom resource definition API versions
The CRDs contained within an official provider follow the standard Kubernetes API versioning and deprecation policy. 

* `v1alpha` - CRDs under `v1alpha` haven't passed through full Upbound quality assurance. Provider CRDs are never publicly released as `v1alpha`.

* `v1beta1` - This identifies a qualified and tested CRD. 
Upbound attempts to ensure a stable CRD API but may require breaking changes in future versions. `v1beta1` may be missing endpoints or settings related to the provider resource.

* `v1beta2` - Like `v1beta1` CRDs all `v1beta2` providers are fully qualified and tested. `v1beta2` contain more features or breaking API changes from `v1beta1`. 

* `v1` - CRDs that reach a `v1` API version have fully defined APIs. Upbound doesn't make breaking API changes until the next provider API version. 

## Support
Official providers are available to all paid Upbound customers. Support for official providers follows the same support model for other Upbound components. 

### Issue priorities

| Priority | 	Name	| Description |
| ---- | ---- | ---- |
| P1 |	Urgent	| Any error reported by the customer that affects the majority of users for a particular part of software, the error has high visibility, there is no workaround, and it affects the customer's ability to perform its business. |
| P2 |	High	| Any error reported by the customer that affects the majority of users for a particular part of the software, the error has high visibility, a workaround is available with degraded performance, or limited function. The issue affects revenue. |
| P3 |	Normal |	Any error reported by the customer that affects the majority of users for a particular part of the software, the error has high visibility, a workaround is available with degraded performance, or limited function. The issue **doesn't** affect revenue. |
| P4 |	Low |	Any error reported by the customer where a single user is severely affected or completely inoperable or a small percentage of users are moderately affected or partially inoperable and the error has limited business impact. |

### Response times
|Priority |	First Response |	Update Frequency |
| ---- | ----- | ----- | 
| P1 - Urgent |	60 minutes	| 4 hours |
| P2 - High | 4 business hours |	8 business hours |
| P3 - Normal |	8 business hours |	3 business days |
| P4 - Low | 	24 business hours |	Reasonable best effort |

<!-- TODO
## Coverage

-->