---
title: "Upbound CLI"
icon: "Settings"
metaTitle: "Upbound CLI"
metaDescription: "Up - The Official Upbound CLI"
rank: 20
---

`up` is the official CLI for interacting with [Upbound Cloud], [Upbound
Enterprise], and [Universal Crossplane (UXP)].

## Install

`up` can be downloaded by using the official installation script, or can be
installed via a variety of common package managers.

### Install Script:

```console
curl -sL https://cli.upbound.io | sh
```

### Homebrew

```console
brew install upbound/tap/up
```

### Deb/RPM Packages

Deb and RPM packages are available for Linux platforms, but currently require
manual download and install.

```console
curl -sLo up.deb https://cli.upbound.io/stable/${VERSION}/deb/linux_${ARCH}/up.deb
```

```console
curl -sLo up.rpm https://cli.upbound.io/stable/${VERSION}/rpm/linux_${ARCH}/up.rpm
```

## Setup

Users typically begin by either logging in to Upbound or installing [UXP].

### Upbound Login

`up` uses profiles to manage sets of credentials for interacting with [Upbound
Cloud] and [Upbound Enterprise]. You can read more about how to manage multiple
profiles in the [configuration documentation]. If no `--profile` flag is
provided when logging in the profile designated as default will be updated, and
if no profiles exist a new one will be created with name `default` and it will
be designated as the default profile.

```
up login
```

### Install Universal Crossplane

`up` can install [UXP] into any Kubernetes cluster, or upgrade an existing
[Crossplane] installation to UXP of compatible version. UXP versions with the
same major, minor, and patch number are considered compatible (e.g. `v1.2.1` of
Crossplane is compatible with UXP `v1.2.1-up.N`)

To install the latest stable UXP release:

```console
up uxp install
```

To upgrade a Crossplane installation to a compatible UXP version:

```console
up uxp upgrade vX.Y.Z-up.N -n <crossplane-namespace>
```

## Usage

See the documentation on [supported commands] for more information.


<!-- Named Links -->
[Upbound Cloud]: ../upbound-cloud
[Upbound Enterprise]: ../upbound-enterprise
[Universal Crossplane (UXP)]: ../uxp
[UXP]: https://github.com/upbound/universal-crossplane
[configuration documentation]: ./configuration
[Crossplane]: https://crossplane.io
[supported commands]: ./usage
