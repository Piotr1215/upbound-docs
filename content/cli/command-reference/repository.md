---
title: "up repository"
---

```
agrant@kubecontroller-01:~$ up repo -h
Usage: up repository (repo) <command>

Interact with repositories.

Flags:
  -h, --help                         Show context-sensitive help.
  -v, --version                      Print version and exit.
  -q, --quiet                        Suppress all output.
      --pretty                       Pretty print output.

      --domain=https://upbound.io    Root Upbound domain ($UP_DOMAIN).
      --profile=STRING               Profile used to execute command ($UP_PROFILE).
  -a, --account=STRING               Account used to execute command ($UP_ACCOUNT).
      --insecure-skip-tls-verify     [INSECURE] Skip verifying TLS certificates ($UP_INSECURE_SKIP_TLS_VERIFY).

Commands:
  repository (repo) create <name>
    Create a repository.

  repository (repo) delete <name>
    Delete a repository.

  repository (repo) list
    List repositories for the account
```