---
title: "Quickstart"
weight: 201
---
This guide walks through installing the [`up` command-line]({{<ref "cli">}}) and Upbound Universal Crossplane (UXP).

- [Install the `up` command-line](#install-the-up-command-line)
- [Install `UXP`](#install-uxp)
- [Verify `UXP`](#verify-uxp)


## Install the `up` command-line

```shell
$ curl -sL "https://cli.upbound.io" | sh
$ sudo mv up /usr/local/bin/
```

## Install `UXP`
```shell
$ up uxp install
```

## Verify `UXP`
```shell
$ kubectl get pods -n upbound-system
NAME                                      READY   STATUS    RESTARTS      AGE
crossplane-7c5c7d98b-qvl64                1/1     Running   0             50s
crossplane-rbac-manager-6596d6678-8bmkl   1/1     Running   0             50s
upbound-bootstrapper-744957b859-stw7t     1/1     Running   0             50s
xgql-8549b948c5-xprzb                     1/1     Running   2 (48s ago)   50s
```