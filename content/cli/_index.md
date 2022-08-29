---
title: "Up Command-Line"
icon: "Settings"
metaTitle: "Upbound CLI"
metaDescription: "Up - The Official Upbound CLI"
weight: 100
---

The Upbound `up` command-line for interacting installing Universal Crossplane (UXP) and <!-- TODO -->.

## Install the Up command-line

Install the `up` command-line via Bash, Homebrew or Linux package.

{{< tabs "up-install" >}}
{{<tab "Bash" >}}
Install the latest version of the `up` command-line via Bash script by downloading the install script from [Upbound](https://cli.upbound.io).  

{{< hint type="tip" >}}
Bash install is the preferred method for installing the `up` command-line.
{{< /hint >}}

The Bash install script automatically determines the operating system and platform architecture an installs the correct binary. 

```console
curl -sL "https://cli.upbound.io" | sh
```

{{< hint type="info" >}}
Install a specific version of `up` by providing the version. 

For example, to install version `v0.12.1` use the following command:

```console
curl -sL "https://cli.upbound.io" | VERSION=v0.12.1 sh
```

Find the full list of versions in the <a href="https://cli.upbound.io/stable?prefix=stable/">Up command-line repository</a>.
{{< /hint >}}

{{< /tab >}}

{{< tab "Homebrew" >}}
[Homebrew](https://brew.sh/) is a package manager for Linux and Mac OS.  

Install the `up` command-line with a Homebrew `tap` using the command:

```console
brew install upbound/tap/up
```
{{< /tab >}}
{{< tab "LinuxPackages" >}}

Upbound provides both `.deb` and `.rpm` packages for Linux platforms.

Downloading packages requires both the [version](https://github.com/upbound/up/releases) and CPU architecture (`linux_amd64`, `linux_arm`, `linux_arm64`).

### Debian package install
```console
curl -sLo up.deb "https://cli.upbound.io/stable/${VERSION}/deb/linux_${ARCH}/up.deb"
```
<br />

### RPM package install

```console
curl -sLo up.rpm "https://cli.upbound.io/stable/${VERSION}/rpm/linux_${ARCH}/up.rpm"
```
{{< /tab >}}
{{< /tabs >}}
