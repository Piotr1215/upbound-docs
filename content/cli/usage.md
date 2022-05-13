---
title: "Usage"
metaTitle: "Upbound CLI - Usage"
metaDescription: "Usage information for the Upbound CLI"
rank: 21
---

Commands implemented by `up` are categorized into groups with increasing levels
of specificity. This `up <noun-0>...<noun-N> <verb> [args...]` style caters to
simple discovery and a clearer mapping to REST API endpoints with which the CLI
interacts.

Groups:

- [Top-Level](#top-level)
- [Control Plane](#control-plane)
- [Enterprise](#enterprise)
- [UXP](#uxp)
- [XPKG](#xpkg)

## Top-Level

Top-level commands do not belong in any subgroup, and are generally used to
configure `up` itself.

Format: `up <cmd> ...`

- `license`
    - Behavior: Prints license information for the `up` binary, which is under
      the [Upbound Software License].
- `login`
    - Flags:
        - `-p,--password = STRING` (Env: `UP_PASS`): Password for specified
          user. If `-` is given the value will be read from stdin.
        - `-t,--token = STRING` (Env: `UP_TOKEN`): Upbound API token used to
          perform the login. If `-` is given the value will be read from stdin.
        - `-u,--username = STRING` (Env: `UP_USER`): User with which to perform
          the login. Email can also be used as username.
        - `-a,--account = STRING` (Env: `UP_ACCOUNT`): Account with which to
          perform the specified command. Can be either an organization or a
          personal account.
        - `--endpoint = URL` (Env: `UP_ENDPOINT`) (Default:
          `https://api.upbound.io`): Endpoint to use when communicating with the
          Upbound API.
        - `--profile = STRING` (Env: `UP_PROFILE`); Profile with which to
          perform the specified command.
    - Behavior: Acquires a session token based on the provided information. If
      only username is provided, the user will be prompted for a password. If
      neither username or password is provided, the user will be prompted for
      both. If token is provided, the user will not be prompted for input. The
      acquired session token will be stored in `~/.up/config.json`. Interactive
      input is disabled if stdin is not an interactive terminal.
- `logout`
    - Flags:
       - `-a,--account = STRING` (Env: `UP_ACCOUNT`): Account with which to
          perform the specified command. Can be either an organization or a
          personal account.
        - `--endpoint = URL` (Env: `UP_ENDPOINT`) (Default:
          `https://api.upbound.io`): Endpoint to use when communicating with the
          Upbound API.
        - `--profile = STRING` (Env: `UP_PROFILE`); Profile with which to
          perform the specified command.
    - Behavior: Invalidates the session token for the default profile or one
      specified with `--profile`.

#### Flags

Top-level flags can be passed for any top-level or group-specific command.

- `-h,--help`: Print help and exit.
- `-v,--version`: Print current `up` version and exit.

## Control Plane

Format: `up controlplane <cmd> ...` Alias: `up ctp <cmd> ...`

- `attach <name>`
    - Flags:
      - `-d,--description = STRING`: Control plane description.
      - `--view-only`: creates the self-hosted control plane as view only.
    - Behavior: Creates a self-hosted control plane in Upbound and returns token
      to connect a UXP instance to it. The name of the token is randomly
      generated.
- `create <name>`
    - Flags:
        - `--description = STRING`: Control plane description.
    - Behavior: Creates a hosted control plane in Upbound.
- `delete <id>`
    - Behavior: Deletes a control plane in Upbound. If control plane is hosted,
      the UXP cluster will be deleted. If the control plane is self-hosted, the
      UXP cluster will begin failing to connect to Upbound.
- `list`
    - Behavior: Lists all control planes for the configured account.

#### Group Flags

Group flags can be passed for any command in the **Control Plane** group. Some
commands may choose not to utilize the group flags when not relevant.

- `-a,--account = STRING` (Env: `UP_ACCOUNT`): Account with which to perform the
  specified command. Can be either an organization or a personal account.
- `--endpoint = URL` (Env: `UP_ENDPOINT`) (Default: `https://api.upbound.io`):
  Endpoint to use when communicating with the Upbound API.
- `--profile = STRING` (Env: `UP_PROFILE`); Profile with which to perform the
  specified command.

#### Subgroup: Kubeconfig

Format: `up controlplane kubeconfig <cmd> ...` Alias: `up ctp kubeconfig <cmd>...`

- `get <control-plane-ID>`
    - Flags:
        - `--token = STRING` (*Required*): API token for authenticating to
          control plane. If `-` is given the value will be read from stdin.
        - `-f,--file = FILE`: File to merge `kubeconfig`.
        - `--proxy = URL` (Env: `UP_PROXY`) (Default:
          `https://proxy.upbound.io/env`): Endpoint for Upbound control plane
          proxy.
    - Behavior: Merges control plane cluster and authentication data into
      currently configured `kubeconfig`, or one specified by `--file`. The
      `--token` flag must be provided and must be a valid Upbound API token. A
      new context will be created for the cluster and authentication data and it
      will be set as current.

#### Subgroup: Token

Format: `up controlplane token <cmd> ...` Alias: `up ctp token <cmd>...`

- `create <control-plane-ID>`
    - Flags:
        - `--name = STRING`: Name of control plane token. Name is randomly
          generated if not specified.
    - Behavior: Creates a token for the specified self-hosted control plane ID
      and prints it to stdout.
- `delete <token-ID>`
    - Behavior: Deletes the control plane token with the specified ID.
- `list <control-plane-ID>`
    - Behavior: Lists all tokens for the specified control plane.

## Enterprise

Format: `up enterprise <cmd> ...`

Commands in the **Enterprise** group are used to install and manage Upbound
Enterprise - a self-hosted, single-tenant Upbound instance. Installing and
upgrading Upbound Enterprise requires an Upbound customer license. Users will be
prompted for their License ID and Token on installation.

- `install <version>`
    - Flags:
        - `--license-secret-name = STRING` (Default:
          `upbound-enterprise-license`): Allows setting the name of the license
          `Secret` that is created on installation. The default value is
          expected, so passing an alternate value for this flag usually requires
          modifying the installation configuration using one of the following
          flags.
        - `--set = KEY=VALUE`: Set install parameters for Upbound Enterprise.
          Flag can be passed multiple times and multiple key-value pairs can be
          provided in a comma-separated list.
        - `-f,--file = FILE`: YAML file with parameters for Upbound Enterprise
          install. Follows format of Helm-style values file.
    - Behavior: Installs Upbound Enterprise into cluster specified by currently
      configured `kubeconfig`. When using Helm as install engine, the command
      mirrors the behavior of `helm install`. If `[version]` is not provided,
      the latest chart version will be used from the either the stable or
      unstable repository.
- `upgrade <version>` 
    - Flags:
        - `--rollback = BOOL`: Indicates that the upgrade should be rolled back
          in case of failure.
        - `--set = KEY=VALUE`: Set install parameters for Upbound Enterprise.
          Flag can be passed multiple times and multiple key-value pairs can be
          provided in a comma-separated list.
        - `-f,--file = FILE`: YAML file with parameters for Upbound Enterprise
          install. Follows format of Helm-style values file.
    - Behavior: Upgrades Upbound Enterprise in cluster specified by currently
      configured `kubeconfig` in the specified namespace.
- `uninstall` 
    - Behavior: Uninstalls Upbound Enterprise from the cluster specified by
      currently configured `kubeconfig`.

#### Group Flags

Group flags can be passed for any command in the **Enterprise** group. Some
commands may choose not to utilize the group flags when not relevant.

- `--kubeconfig = STRING`: sets `kubeconfig` path. Same defaults as `kubectl`
  are used if not provided.
- `-n,--namespace = STRING` (Env: `ENTERPRISE_NAMESPACE`) (Default:
  `upbound-enterprise`): Kubernetes namespace used for installing and managing
  Upbound Enterprise.

## UXP

Format: `up uxp <cmd> ...`

Commands in the **UXP** group are used to install and manage Upbound Universal
Crossplane, as well as connect it to Upbound.

- `install [version]`
    - Flags:
        - `--unstable = BOOL`: Allows installing unstable UXP versions. If using
          Helm as install engine, setting to `true` will use
          https://charts.upbound.io/main as repository instead of
          https://charts.upbound.io/stable.
        - `--set = KEY=VALUE`: Set install parameters for UXP. Flag can be
          passed multiple times and multiple key-value pairs can be provided in
          a comma-separated list.
        - `-f,--file = FILE`: YAML file with parameters for UXP install. Follows
          format of Helm-style values file.
    - Behavior: Installs UXP into cluster specified by currently configured
      `kubeconfig`. When using Helm as install engine, the command mirrors the
      behavior of `helm install`. If `[version]` is not provided, the latest
      chart version will be used from the either the stable or unstable
      repository.
- `connect <control-plane-token>`
    - Flags:
      - `--token-secret-name` (Default: `upbound-control-plane-token`): Sets the
        name of the secret that will be used to store the control plane token in
        the configured Kubernetes cluster.
    - Behavior: Connects the UXP instance in cluster specified by currently
      configured `kubeconfig` to the existing self-hosted control plane
      specified by `<control-plane-token>`. If `-` is given for
      `<control-plane-token>` the value will be read from stdin.
- `upgrade [version]` 
    - Flags:
        - `--rollback = BOOL`: Indicates that the upgrade should be rolled back
          in case of failure.
        - `--unstable = BOOL`: Allows installing unstable UXP versions. If using
          Helm as install engine, setting to `true` will use
          https://charts.upbound.io/main as repository instead of
          https://charts.upbound.io/stable.
        - `--set = KEY=VALUE`: Set install parameters for UXP. Flag can be
          passed multiple times and multiple key-value pairs can be provided in
          a comma-separated list.
        - `-f,--file = FILE`: YAML file with parameters for UXP install. Follows
          format of Helm-style values file.
        - `--force = BOOL`: Forces upgrade even if versions are incompatible.
          This is only relevant when upgrading from Crossplane to UXP. 
    - Behavior: Upgrades UXP in cluster specified by currently configured
      `kubeconfig` in the specified namespace. If `[version]` is not provided,
      the latest chart version will be used from the either the stable or
      unstable repository. This command can also be used to upgrade a currently
      installed Crossplane version to a _compatible UXP version_ (i.e. one that
      has the same major, minor, and patch version). The following scenarios are
      supported when upgrading from Crossplane `vX.Y.Z` installed in the
      `crossplane-system` namespace:
        - `up uxp upgrade vX.Y.Z-up.N -n crossplane-system`: upgrades Crossplane
          to compatible UXP version in the same namespace.
        - `up uxp upgrade vA.B.C-up.N -n crossplane-system --force`: upgrades
          Crossplane to an incompatible UXP version in the same namespace.
        - `up uxp upgrade -n crossplane-system --force`: upgrades Crossplane to
          an incompatible latest stable version of UXP in the same namespace.
        - `up uxp upgrade vX.Y.Z-up.N.rc.xyz -n crossplane-system --unstable`:
          upgrades Crossplane to a compatible unstable version of UXP in the
          same namespace.
        - `up uxp upgrade vA.B.C-up.N.rc.xyz -n crossplane-system --unstable
          --force`: upgrades Crossplane to a incompatible unstable version of
          UXP in the same namespace.
        - `up uxp upgrade -n crossplane-system --unstable --force`: upgrades
          Crossplane to an incompatible latest unstable version of UXP in the
          same namespace.
- `uninstall` 
    - Behavior: Uninstalls UXP from the cluster specified by currently
      configured `kubeconfig`.

#### Group Flags

Group flags can be passed for any command in the **UXP** group. Some commands
may choose not to utilize the group flags when not relevant.

- `--kubeconfig = STRING`: sets `kubeconfig` path. Same defaults as `kubectl`
  are used if not provided.
- `-n,--namespace = STRING` (Env: `UXP_NAMESPACE`) (Default: `upbound-system`):
  Kubernetes namespace used for installing and managing UXP.

## XPKG

Format: `up xpkg <cmd> ...`

Commands in the **XPKG** group are used to build, push, and interact with
on-disk UXP packages.

- `build`
    - Flags:
        - `--name = STRING`: Name of the package to be built. Uses name in
          crossplane.yaml if not specified. Does not correspond to package tag.
        - `-f, --package-root = STRING`: Path to package directory.
        - `--ignore = STRING,...`: Paths, specified relative to --package-root,
          to exclude from the package.
    - Behavior: Builds a UXP package (`.xpkg`) that is compatible with upstream
      Crossplane packages and is a valid OCI image. Build will fail if package
      is malformed or contains resources that are not compatible with its type
      (e.g. a `Provider` package containing a `Composition`).
- `push <tag>`
    - Flags:.
        - `-f, --package = STRING`: Path to package. If not specified and only
          one package exists in current directory it will be used.
    - Behavior: Pushes a UXP package (`.xpkg`) to an OCI compliant registry. The
      [Upbound Marketplace] (`xpkg.upbound.io`) will be used by default if tag
      does not specify.

<!-- Named Links -->
[Upbound Software License]: https://licenses.upbound.io/upbound-software-license.html
[Upbound Marketplace]: ../../upbound-marketplace
