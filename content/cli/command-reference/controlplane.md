---
title: "up controlplane"
---
_Alias_: `up ctp`

Commands under `up controlplane` create and manage Kubernetes [pull secret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) to install [Upbound official providers]({{<ref "/upbound-marketplace/providers">}})

### `up controlplane pull-secret`

<!-- omit in toc -->
#### Arguments
* `<secret name>` _(required)_ - name of the Kubernetes secret object to create.
* `-f,--file = <file>` - path to a token credentials file created by [`up robot token create`]({{<ref "robot" >}}).
* `--kubeconfig = <path>` - path to a kubeconfig file. The default is the kubeconfig file used by `kubectl`.
* `-n,--namespace = <namespace>` - namespace to install the Kubernetes secret into.  
The default is the value of the environmental variable `UPBOUND_NAMESPACE`.  
If the variable isn't set the command uses the namespace `upbound-system`.

Installing Upbound official providers requires a Kubernetes pull secret to authenticate to Upbound Marketplace.

This command generates an Upbound `robot token` and installs the token as a Kubernetes secret.

View the generated token in the cluster with `kubectl describe secret <name> -n <namespace>`

{{< hint type="important" >}}
Generating the robot token requires authenticating to the Upbound Marketplace. Use [`up login`]({{<ref "login" >}}) before using `up controlplane pull-secret`.
{{< /hint >}}

<!-- omit in toc -->
#### Examples

##### Create a pull-secret
```shell
up controlplane pull-secret create my-token
WARNING: Using temporary user credentials that will expire within 30 days.
upbound-system/my-token created
```

##### View a created pull-secret
```shell
kubectl describe secret my-token -n upbound-system
Name:         my-token
Namespace:    upbound-system
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/dockerconfigjson

Data
====
.dockerconfigjson:  1201 bytes
```
