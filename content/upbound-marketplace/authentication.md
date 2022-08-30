---
title: "Authentication"
weight: 6
---

Some Marketplace resources require authentication to Upbound. Authentication from your Kubernetes cluster to Upbound is with a Kubernetes [image pull secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials).

## Requirements
Creating a Kubernetes image pull secret and authentication to the Upbound Marketplace requires an [Upbound account]({{<ref "users/register" >}}). 

{{<hint type="note" >}}
Only Upbound customers that are part of an organization can authenticate to the Upbound Marketplace.
{{< /hint >}}

Create a secret either with the `Up` command-line tool or manually in Kubernetes through `kubectl`.

{{< tabs "secrets" >}}
{{< tab "Creating a secret with the Up command-line" >}}
## Up command-line
[Install Up command-line]({{<ref "cli/" >}}) version v0.13.0 or later.  

Confirm the version of Up command-line with `up --version`

```command
$ up --version
v0.13.0
```

## Log in with the Up command-line
Use `up login` to authenticate to the Upbound Marketplace.

It's important to use `-a <your organization>` when logging in. Only accounts belonging to organizations can access Upbound Marketplace resources.

```shell
$ up login -a my-org
username: my-user
password: 
my-user logged in
```
<br />

## Create an Upbound robot account
Upbound robots are identities used for authentication that are independent from a single user and aren't tied to specific usernames or passwords.

Creating a robot account allows Kubernetes to install Upbound Marketplace resources.

Use `up robot create <robot account name>` to create a new robot account.

{{<hint type="tip" >}}
Only users logged into an organization can create robot accounts.
{{< /hint >}}

```shell
$ up robot create my-robot
my-org/my-robot created
```
<br />

## Create an Upbound robot account token
The robot token acts as a username and password for a robot account.

Generate a token using `up robot token create <robot account> <token name> --output=<file>`.

```shell
$ up robot token create my-robot my-token --output=token.json
my-org/my-robot/my-token created
```

The `output` file is a JSON file containing the robot token's `accessId` and `token`. The `accessId` is the username and `token` is the password for the token.

{{< hint type="caution" >}}
You can't recover a lost robot token. You must delete and recreate the token.
{{< /hint >}}

## Create a Kubernetes pull secret
Kubernetes uses a `secret` object when authenticating to the Upbound Marketplace.

Using the `up controlplane pull-secret create <secret name> -f <robot token file>` command create a Kubernetes secret object from your robot token file.

Provide a name for your Kubernetes secret and the path to the robot token JSON file.

```shell
$ up controlplane pull-secret create my-upbound-secret -f token.json
my-org/my-upbound-secret created
```

`Up` creates the secret in the `upbound-system` namespace. 

```shell
$ kubectl get secret -n upbound-system
NAME                                         TYPE                             DATA   AGE
my-upbound-secret                            kubernetes.io/dockerconfigjson   1      8m46s
sh.helm.release.v1.universal-crossplane.v1   helm.sh/release.v1               1      21m
upbound-agent-tls                            Opaque                           3      21m
uxp-ca                                       Opaque                           3      21m
xgql-tls                                     Opaque                           3      21m
```
{{< /tab >}}
{{< tab "Creating a secret with kubectl" >}}
### Create a Kubernetes imagePullSecret
If you already have a robot account and robot token you can use `kubectl` to generate the `secret` object.

Create an `imagePull` Secret with `kubectl create secret docker-registry` command with the following options:
* `--namespace` the same namespace as Upbound. By default this is `upbound-system`.
* `--docker-server` as `xpkg.upbound.io`
* `--docker-username` the _Access ID_ value of the robot token
* `--docker-password` the _Token_ value of the robot token

For example, create an imagePullSecret with the name `my-upbound-secret`
```shell
kubectl create secret docker-registry my-upbound-secret \
--namespace=upbound-system \
--docker-server=xpkg.upbound.io \
--docker-username=42bde5f3-81c1-4243-ab53-e301c71acc90 \
--docker-password=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI0MmJkZTVmMy04MWMxLTQyNDMtYWI1My1lMzAxYzcxYWNjOTAiLCJzdWIiOiJyb2JvdHxhYWQ0MTk4NC0wOWFmLTQxYWEtYjcxYi0zZGZlNjI0MDI2YTUifQ.bqcW3UZGIFL2yU0rkKbLRhU_TfK4HCi4ckgjtHVT4rLGip5I0lFXTcr7VLdCnNO2c2q_nU7Bf7r05G_ZPBT3yZB85UQhzp7COFHjH5YIQbQFqT3354YS4DMHV_tLp0dtLj-3ojbUbVDtHV2RScqUPaD2s--S6m9Jz7xLuCRnqqYKFeSyyo_4aNrH4AVp--ER8VVzF3tc0WkAgkZ9aGEsbhnDHjECNp0krPMop1Nl6RvJ5KUSGPKZe_yptZMD82JtxcULjPo1sWd8i4G4jd8m567rGW1MzutUtfETNFpjd8BWAwLakZwEyIkfb6B8u6OvgOd0RK-cMCfCPoKvVRxHFQ
```

Verify the secret with `kubectl get secrets`
```shell
$ kubectl get secret -n upbound-system
NAME                                         TYPE                             DATA   AGE
my-upbound-secret                            kubernetes.io/dockerconfigjson   1      8m46s
sh.helm.release.v1.universal-crossplane.v1   helm.sh/release.v1               1      21m
upbound-agent-tls                            Opaque                           3      21m
uxp-ca                                       Opaque                           3      21m
xgql-tls                                     Opaque                           3      21m
```
{{< /tab >}}
{{< /tabs >}}