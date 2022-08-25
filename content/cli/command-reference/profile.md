---
title: "up profile"
---

```
Interact with Upbound profiles.

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
  profile current
    Get current Upbound Profile.

  profile list
    List Upbound Profiles.

  profile use <name>
    Set the default Upbound Profile to the given Profile.

  profile view
    View the Upbound Profile settings across profiles.

  profile config <command>
    Interact with the current Upbound Profile's config.
```