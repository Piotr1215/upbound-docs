---
title: "up uxp"
---

```
up uxp -h
Usage: up uxp <command>

Interact with UXP.

Flags:
  -h, --help                          Show context-sensitive help.
  -v, --version                       Print version and exit.
  -q, --quiet                         Suppress all output.
      --pretty                        Pretty print output.

      --kubeconfig=STRING             Override default kubeconfig path.
  -n, --namespace="upbound-system"    Kubernetes namespace for UXP ($UXP_NAMESPACE).

Commands:
  uxp install [<version>]
    Install UXP.

  uxp uninstall
    Uninstall UXP.

  uxp upgrade [<version>]
    Upgrade UXP.
```