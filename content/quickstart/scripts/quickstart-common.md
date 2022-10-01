### Install the Up command-line
The Up command-line helps manage Upbound Universal Crossplane, Upbound's enterprise Crossplane distribution and manage Upbound user accounts. 

Download and install the Upbound `up` command-line.

```shell
curl -sL "https://cli.upbound.io" | sh
sudo mv up /usr/local/bin/
```

### Install Upbound Universal Crossplane
Upbound Universal Crossplane (_UXP_) consists of upstream Crossplane and Upbound-specific enhancements and patches. It's [open source](https://github.com/upbound/universal-crossplane) and maintained by Upbound. 

Install UXP with the Up command-line `up uxp install` command.

```shell
up uxp install
UXP 1.9.0-up.3 installed
```

Verify all UXP pods are `Running` with `kubectl get pods -n upbound-system`. This may take up to five minutes depending on your Kubernetes cluster.

```shell
kubectl get pods -n upbound-system
NAME                                        READY   STATUS    RESTARTS      AGE
crossplane-7fdfbd897c-pmrml                 1/1     Running   0             68m
crossplane-rbac-manager-7d6867bc4d-v7wpb    1/1     Running   0             68m
upbound-bootstrapper-5f47977d54-t8kvk       1/1     Running   0             68m
xgql-7c4b74c458-5bf2q                       1/1     Running   3 (67m ago)   68m
```

{{< hint type="note" >}}
`RESTARTS` for the `xgql` pod are normal during initial installation. 
{{< /hint >}}

For more details about UXP pods, read the [UXP]({{<ref "uxp#universal-crossplane-pods" >}}) section.


Installing UXP and Crossplane creates new Kubernetes API end-points. Take a look at the new API end-points with `kubectl api-resources  | grep crossplane`. In a later step you use the {{< hover-highlight label="grep" line="10">}}Provider{{< /hover-highlight >}} resource install the Official Provider.

```shell  {label="grep"}
kubectl api-resources  | grep crossplane
compositeresourcedefinitions      xrd,xrds     apiextensions.crossplane.io/v1         false        CompositeResourceDefinition
compositionrevisions                           apiextensions.crossplane.io/v1alpha1   false        CompositionRevision
compositions                                   apiextensions.crossplane.io/v1         false        Composition
configurationrevisions                         pkg.crossplane.io/v1                   false        ConfigurationRevision
configurations                                 pkg.crossplane.io/v1                   false        Configuration
controllerconfigs                              pkg.crossplane.io/v1alpha1             false        ControllerConfig
locks                                          pkg.crossplane.io/v1beta1              false        Lock
providerrevisions                              pkg.crossplane.io/v1                   false        ProviderRevision
providers                                      pkg.crossplane.io/v1                   false        Provider
storeconfigs                                   secrets.crossplane.io/v1alpha1         false        StoreConfig
```

### Log in with the Up command-line
Use `up login` to authenticate to the Upbound Marketplace. This gives you access to create _robot account tokens_ and install Official Providers into your Kubernetes cluster.

```shell
up login
username: my-user
password: 
my-user logged in
```

### Create an Upbound organization
Upbound allows trial users to create a single _organization_ to try out Upbound's enterprise features.

{{< hint type="important" >}}
Organizations for trail users last for 14 days before they're automatically deleted.
{{< /hint >}}

Organizations allow multiple users to share resources like _robot accounts_ and _repositories_ as well as provide fine-grained user access controls.

Read more about the difference between users and organizations in the [organizations]({{<ref "users/organizations" >}}) section.

Check if your account belongs to any organizations with `up organization list`

If you didn't create an organization when you created your Upbound user account, there are no organizations listed.
```shell
up organization list
No organizations found.
```

{{< hint type="tip" >}}
If you created an organization or already belong to an organization, you don't need to create a new one.
{{< /hint >}}

Create an organization with `up organization create <organization name>`

```shell
up organization create my-org
my-org created
```

Verify you belong to an organization with `up organization list`
```shell
up organization list
NAME           ROLE
my-org         owner
```

### Create an Upbound robot account
Robot accounts are non-user accounts with unique credentials and permissions. Robot accounts access repositories without using credentials tied to an individual user.

{{< hint type="important" >}}
Only robot accounts can install Official Providers.
{{< /hint >}}

Create a new robot account with the command
```shell
up robot create \
<robot account name> \
-a <organization name>
```
{{< hint type="tip" >}}
Only users that are members of organizations can create robot accounts. The `-a <organization name>` authenticates you to the organization.
{{< /hint >}}

```shell
up robot create my-robot -a my-org
my-org/my-robot created
```

### Create an Upbound robot account token
The token associates with a specific robot account and acts as a username and password for authentication. This token isn't related to your personal username or password, making it easier to revoke or rotate robot security credentials.

Generate a token using the command
```shell
up robot token create \
<robot account> \
<token name> \
--output=<file> \
-a <organization name>
```
When you generate a token it's saved to a JSON file specified in the `-o <filename>` argument.

For example
```shell
up robot token create my-robot my-token --output=token.json -a my-org
my-org/my-robot/my-token created
```

{{< hint type="caution" >}}
You can't recover a lost robot token. You must delete and create a new token.
{{< /hint >}}

The `output` JSON file contains the robot token's `accessId` and `token`.  
The `accessId` acts as the username and the `token` as the password for the robot.

### Create a Kubernetes pull secret
Downloading and installing official providers requires Kubernetes to authenticate to the Upbound Marketplace using a Kubernetes `secret` object.

Use the Up command-line to generate a Kubernetes secret using your robot account and token. 
```shell
up controlplane \
pull-secret create \
package-pull-secret \
-f <robot token file>
```

Provide the robot token JSON file.

For example,
```shell
up controlplane pull-secret create package-pull-secret -f token.json
my-org/package-pull-secret created
```

`up` creates a secret named {{< hover-highlight label="pps" line="3">}}package-pull-secret{{< /hover-highlight >}} in the `upbound-system` namespace. 

```shell {label="pps"}
kubectl get secret -n upbound-system
NAME                                         TYPE                             DATA   AGE
package-pull-secret                          kubernetes.io/dockerconfigjson   1      8m46s
sh.helm.release.v1.universal-crossplane.v1   helm.sh/release.v1               1      21m
upbound-agent-tls                            Opaque                           3      21m
uxp-ca                                       Opaque                           3      21m
xgql-tls                                     Opaque                           3      21m
```
<!-- vale gitlab.Substitutions = NO -->
<!-- ignore lowercase kubernetes in the link -->
More details about how Upbound uses image pull secrets are in the [authentication]({{<ref "upbound-marketplace/authentication#kubernetes-image-pull-secrets">}}) section.
<!-- vale gitlab.Substitutions = YES -->
