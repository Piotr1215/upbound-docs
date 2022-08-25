---
title: "up organization"
---

```
Usage: up organization (org) <command>

Interact with organizations.

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
  organization (org) create <name>
    Create an organization.

  organization (org) delete <name>
    Delete an organization.

  organization (org) list
    List organizations.
```