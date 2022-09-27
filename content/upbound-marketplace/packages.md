---
title: "Creating and Publishing Packages"
weight: 30
draft: True
---

{{< hint type="note" >}}
This section covers creating and publishing packages for the Upbound Marketplace. For information about installing packages read the <a href="{{<ref "uxp/crossplane-concepts/packages">}}">Crossplane Packages</a> section.
{{< /hint >}}

## Package types
Crossplane supports two package types, `Configurations` and `Providers`.

* **`Configuration`** packages combine Crossplane _Composite Resource Definitions_, _Compositions_ and metadata. 
* **`Provider`** packages combine a [Kubernetes controller](https://kubernetes.io/docs/concepts/architecture/controller/) container, associated _Custom Resource Definitions_ (`CRDs`) and metadata. The Crossplane open source [AWS provider package](https://github.com/crossplane-contrib/provider-aws/tree/master/package) is an example a provider's metadata and `CRDs`.

## Prerequisites

* Building and publishing packages require the [`up` command-line]({{<ref "/cli" >}}).
* Publishing packages requires an [Upbound account]({{<ref "users/register">}}).

## Build a package
Build a package using `up xpkg build`. 

The `up xpkg build` command expects a `crossplane.yaml` file to provide the metadata for the package file. 

<!-- 
{{< tabs "build-config" >}}

{{< tab "Build a Configuration Package" >}}


{{< /tab >}}

{{< tab "Build a Provider Package" >}}
{{< /tab >}}

{{< /tabs >}} -->

## Publish a package
Before publishing a package you must [login]({{<ref "cli/command-reference/login">}}) to the Upbound Marketplace.

{{< hint type="important" >}}
Only accounts linked to an [organization]({{<ref "cli/command-reference/organization" >}}) can publish packages.
{{< /hint >}}

### Create a repository
Upbound publishes packages to a repository inside an organization. Create a repository with the [`up repository create`]({{<ref "cli/command-reference/repository#up-repository-create" >}}) command.

For example, to create a repository called `my-repo`
```shell
up repository create my-repo
upbound-docs/my-repo created
```

### Push a package to the repository
Push a package to the Upbound Marketplace using the `up xpkg push` command.

The `up xpkg push` command requires:
* The organization who owns the repository.
* The repository to push a package to.
* A package version tag. A <a href="https://semver.org/">semantic versioning</a> number controls package upgrades and dependency requirements.

To push a package with the following parameters:
* Organization name `upbound-docs`
* Repository `my-repo`
* Version `v0.2`
* Package file named `my-package.xpkg`

Use the following `up xpkg push` command:

```shell
up xpkg push upbound-docs/my-repo:v0.2 -f my-package.xpkg
xpkg pushed to upbound-docs/my-repo:v0.2
```
{{< hint type="important" >}}
All published packages are private. Users can't view or download packages unless they're members of the organization.
{{< /hint >}}

The package is now available from the Upbound Marketplace. View the Marketplace listing at:
`https://marketplace.upbound.io/<package_type>/<organization>/<repository>/`

For example, the Upbound AWS Official Provider is a `provider` package in the `upbound` organization's `provider-aws` repository. The package address is <a href="https://marketplace.upbound.io/providers/upbound/provider-aws/">`https://marketplace.upbound.io/providers/upbound/provider-aws/`</a>
