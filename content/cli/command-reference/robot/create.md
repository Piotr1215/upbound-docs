---
title: "up robot create"
---

Create new robot accounts with `up robot create`.

{{<hint type="important" >}}
Robot accounts are only supported for [organizations]({{<ref "../organization" >}}).  
User accounts can't create robots.
{{< /hint >}}

<!-- vale gitlab.SubstitutionWarning = NO-->
<!-- don't flag an error on shortcode information argument -->
{{< hint type="info" >}}
<!-- vale gitlab.SubstitutionWarning = YES-->
The Upbound Cloud Platform requires authentication to an organization with [`up login -a`]({{<ref "login" >}}) before using `up robot token create`.
{{< /hint >}}

### `up robot create`

#### Arguments
* `<robot name>` _(required)_ - name of the robot token.
  

#### Examples
```shell
$ up robot create my-robot
my-org/my-robot created
```