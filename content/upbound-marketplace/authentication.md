---
title: "Authentication"
weight: 10
---

Pulling private packages or pushing packages to an Upbound Marketplace private repository requires authentication to Upbound.

Installing private Kubernetes resources requires an [image pull secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials). 

{{< hint type="important" >}}
Authenticating to the Upbound Marketplace for private packages requires an [Upbound account]({{<ref "users/register" >}}).
{{< /hint >}}

## Prerequisites
Install the [Up command-line]({{<ref "cli">}}) to generate Kubernetes secrets and to use Upbound Marketplace private resources. 

{{< hint type="note" >}}
Upbound Marketplace requires Up command-line version `v0.13.0` or later.
{{< /hint >}}

## Log in with the Up command-line

Use `up login` to authenticate a user to the Upbound Marketplace.

```shell
up login
username: my-user
password: 
my-user logged in
```

<!-- ### Authenticate to an Organization
[Organization-only resources]({{<ref "users/organizations">}}) requires specifying the organization. You can provide an organization globally or per-command.

{{< tabs "org-auth" >}}

{{< tab "Authenticate globally" >}}
You may run all `up` commands against a specific organization with `up login -a` when you login. This sets the specified organization for all commands.

For example, to log in to the `my-org` organization use the command

```shell
up login -a my-org
Username: my-user
Password:
my-user logged in
```
Use `up profile list` to verify you authenticated to the organization.

```shell
up profile list
CURRENT   NAME      TYPE   ACCOUNT
*         default   user   my-org
```
{{< /tab >}}

{{< tab "Authenticate per-command" >}}
You can specify the organization on a per-command basis using `-a` with the associated `up` command.

{{< hint type="tip" >}}
Providing an organization per-command is useful when you belong to multiple organizations.
{{< /hint >}}

For example, to create a robot account in `my-org` use the command

```shell {copy-lines="1-3"}
up robot create \
my-robot \
-a my-org
my-org/my-robot created
```
{{< /tab >}}

{{< /tabs >}} -->

## Kubernetes image pull secrets

Packages in private repositories require a Kubernetes image pull secret.  
The image pull secret authenticates Kubernetes to the Upbound Marketplace, allowing Kubernetes to download and install packages.

Generating an image pull secret requires either a user account _token_. 

{{< hint type="important" >}}
A user account token uses your current `up login` profile.  
Logging out with `up logout` deactivates the token.
{{< /hint >}}

Use the command `up controlplane pull-secret create` to generate a token and Kubernetes _Secret_ in the _upbound-system_ namespace.

```shell
up ctp pull-secret create
WARNING: Using temporary user credentials that will expire within 30 days.
upbound-system/package-pull-secret created
```
Verify the secret with `kubectl describe secret -n upbound-system package-pull-secret`

```shell
kubectl describe secret -n upbound-system package-pull-secret
Name:         package-pull-secret
Namespace:    upbound-system
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/dockerconfigjson

Data
====
.dockerconfigjson:  1201 bytes
```

## Use an image pull secret

Use an image pull secret by providing a {{< hover label="pps" line="8" >}}spec.packagePullSecrets{{< /hover >}} in a {{< hover label="pps" line="2" >}}Configuration{{</hover>}} or `Provider` manifest.  

This example installs a private {{< hover label="pps" line="2" >}}Configuration{{< /hover >}} named {{< hover label="pps" line="6" >}}secret-configuration{{< /hover >}} from the Upbound image repository using image pull secret named {{< hover label="pps" line="8" >}}package-pull-secret{{< /hover >}}.
```yaml {label="pps",copy-line="all"}
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: platform-ref-aws
spec:
  package: xpkg.upbound.io/secret-org/secret-configuration:v1.2.3
  packagePullSecrets:
    - name: package-pull-secret
```


<!-- The following is the old robot token and org auth info -->

<!-- 
{{< hint type="caution" >}}
User accounts also have _API Tokens_ to use with `up login`.   
Image pull secrets can't use API tokens.  
<!-- vale Microsoft.FirstPerson = NO -->
<!-- ignore "My" in "My Account" -->
<!-- The <a href="https://accounts.upbound.io">My Account</a> management panel creates API tokens.  -->
<!-- vale Microsoft.FirstPerson = YES -->
<!-- Kubernetes can only use the _pull-secret_ token for authentication.  -->
{{< /hint >}} -->


<!-- 
{{< tabs "tokens" >}}

{{< tab "Create a robot account token" >}}
{{< hint type="caution" >}}
Robot accounts are only available to organizations. 
{{< /hint >}}

Creating a robot account token involves:
* Creating a robot account
* Creating a token from the robot account
* Creating an image pull secret from the robot account token

### Create a robot account

Create a new robot account with the command `up robot create <robot name>`.

{{< hint type="tip" >}}
Use `up robot create -a <organization>` if you aren't using global organization authentication.
{{< /hint >}}

```shell {copy-lines="1-2"}
up robot create \
my-robot
my-org/my-robot created
```  
<br />

### Create a robot token
Create a robot token for a robot account with `up robot token create <robot name> <token name> --output <file>`

```shell {copy-lines="1-4",label="robot-token"}
up robot token create \
my-robot \
my-token \
--output=token.json
my-org/my-robot/my-token created
```

{{< hint type="caution" >}}
You can't recover a lost robot token. You must delete and create a new token.
{{< /hint >}}

The output file is a JSON file containing the robot token's `accessId` and `token`. The `accessId` is the username and `token` is the password for the token.

### Create an image pull secret
Using the robot account token generate a Kubernetes image pull secret with `up controlplane pull-secret create package-pull-secret -f <token file>`.

```shell {copy-lines="1=3"}
up controlplane pull-secret \ 
create package-pull-secret \
-f token.json
my-org/package-pull-secret created
```

The `up` command-line generates the Kubernetes _Secret_ named {{<hover label="describe-secret" line="2" >}}package-pull-secret{{< /hover >}} inside the {{<hover label="describe-secret" line="3" >}}upbound-system{{< /hover >}} namespace.

```shell {label="describe-secret"}
kubectl describe secret package-pull-secret -n upbound-system
Name:         package-pull-secret
Namespace:    upbound-system
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/dockerconfigjson

Data
====
.dockerconfigjson:  1201 bytes
```

You can manually generate a Kubernetes secret without the `up controlplane pull-secret create` command. Expand this section for details. 

{{< expand "Manually install an image pull secret" >}}

{{< hint type="note" >}}
This step isn't required if you generate an image pull secret with `up`
{{< /hint >}}


Create a _Secret_ with `kubectl create secret docker-registry` command with the following options:
* {{<hover label="manual-secret" line="2" >}}--namespace{{</ hover >}} the same namespace as Upbound. By default this is `upbound-system`.
* {{<hover label="manual-secret" line="3" >}}--docker-server{{</ hover >}}  as `xpkg.upbound.io`
* {{<hover label="manual-secret" line="4" >}}--docker-username{{</ hover >}}  the _Access ID_ value of the robot token
* {{<hover label="manual-secret" line="5" >}}--docker-password{{</ hover >}}  the _Token_ value of the robot token

For example, create an imagePullSecret with the name `package-pull-secret`
```shell {copy-lines="all",label="manual-secret"}
kubectl create secret docker-registry package-pull-secret \
--namespace=upbound-system \
--docker-server=xpkg.upbound.io \
--docker-username=42bde5f3-81c1-4243-ab53-e301c71acc90 \
--docker-password=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI0MmJkZTVmMy04MWMxLTQyNDMtYWI1My1lMzAxYzcxYWNjOTAiLCJzdWIiOiJyb2JvdHxhYWQ0MTk4NC0wOWFmLTQxYWEtYjcxYi0zZGZlNjI0MDI2YTUifQ.bqcW3UZGIFL2yU0rkKbLRhU_TfK4HCi4ckgjtHVT4rLGip5I0lFXTcr7VLdCnNO2c2q_nU7Bf7r05G_ZPBT3yZB85UQhzp7COFHjH5YIQbQFqT3354YS4DMHV_tLp0dtLj-3ojbUbVDtHV2RScqUPaD2s--S6m9Jz7xLuCRnqqYKFeSyyo_4aNrH4AVp--ER8VVzF3tc0WkAgkZ9aGEsbhnDHjECNp0krPMop1Nl6RvJ5KUSGPKZe_yptZMD82JtxcULjPo1sWd8i4G4jd8m567rGW1MzutUtfETNFpjd8BWAwLakZwEyIkfb6B8u6OvgOd0RK-cMCfCPoKvVRxHFQ
```

Verify the secret with `kubectl get secrets`
```shell
kubectl get secret -n upbound-system
NAME                                         TYPE                             DATA   AGE
package-pull-secret                          kubernetes.io/dockerconfigjson   1      8m46s
sh.helm.release.v1.universal-crossplane.v1   helm.sh/release.v1               1      21m
upbound-agent-tls                            Opaque                           3      21m
uxp-ca                                       Opaque                           3      21m
xgql-tls                                     Opaque                           3      21m
```
{{< /expand >}}

{{< /tab >}}

{{< tab "Create a user account token" >}}

{{< /tab >}}

{{< /tabs >}}



 -->
