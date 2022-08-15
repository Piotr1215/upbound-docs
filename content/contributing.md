---
title: "Contributing to the Upbound Documentation"
weight: 10
---

The Upbound documentation welcomes contributions from the anyone in the Upbound community. 

<!-- disable vale for CNCF text -->
<!-- vale off -->
## Code of Conduct
We follow the [CNCF Code of Conduct](https://github.com/cncf/foundation/blob/main/code-of-conduct.md).

Taken directly from the CNCF CoC:
>As contributors and maintainers in the CNCF community, and in the interest of fostering an open and welcoming community, we pledge to respect all people who contribute through reporting issues, posting feature requests, updating documentation, submitting pull requests or patches, and other activities.
>  
>We are committed to making participation in the CNCF community a harassment-free experience for everyone, regardless of level of experience, gender, gender identity and expression, sexual orientation, disability, personal appearance, body size, race, ethnicity, age, religion, or nationality.

### Reporting
To report violations contact docs@upbound.io or use the [Contact Us form](https://upbound.hubspotpagebuilder.com/contact).
<!-- vale on -->

## Licensing
Upbound documentation is under the [Creative Commons Attribution-ShareAlike](https://creativecommons.org/licenses/by-sa/4.0/) license. CC-BY-SA allows reuse, remixing and republishing of Upbound documentation under this same license and with full attribution to Upbound.

## Clone and run the documentation
Upbound documentation is open source and hosted on [GitHub](https://github.com/upbound/docs/). The documentation uses [Hugo](https://gohugo.io/) to build the site.  
The documentation site has no other external dependencies.

Clone the docs repository with

```shell
git clone https://github.com/upbound/docs.git --recurse-submodules
```

{{<hint "note" >}}
The docs repository relies on git submodules for the production build process, but they're not required for local development.
{{< /hint >}}

### Directory structure
The relevant directories of the docs repository are:
| Directory | Purpose |
| ----- | ---- |
| `content` | Markdown files for all individual pages. |
| `static/images` | Location for all image files.  |
| `themes` | HTML templates and Hugo tooling. |
| `utils` | Utility files for the documentation team and build process. |

All markdown content exists within the `/content` directory.   
All image files exist within `static/images`.

### Run Hugo
* Follow the [Hugo documentation](https://gohugo.io/getting-started/installing/) to install Hugo.
* Run `hugo server`
* Go to [http://localhost:1313](http://localhost:1313)

{{< hint type="note" >}}
Upbound documentation uses [Hugo v0.101.0](https://github.com/gohugoio/hugo/releases/tag/v0.101.0), but newer versions are compatible.
{{< /hint >}}

### Documentation issues and feature requests
Use [GitHub Issues](https://github.com/upbound/docs/issues/new/choose) to report a problem or request documentation content.

* **Bug Report** - The `Bug Report` template is useful for typos or mistakes. Provide the page address and error in your report. Bugs should use the label `bug`.
* **Infrastructure Issue** - The `Infrastructure Issue` template is for requests or issues with the website, tooling or design. An example of an infrastructure issue would be a problem building the docs, running Vale or issues with JavaScript. Infrastructure issues should use the label `infrastructure`.
* **Other** - For any other issues, content requests or you're not sure then a template isn't required. The documentation team manages classification and labeling.

## Contributing

### Branching and pull requests
Upbound docs use two branches: `main` and `staging`. The `main` branch is the current content of docs.upbound.io and is never directly modified.

Create all branches and PRs from the `staging` branch. 

## Authoring
The `/content` directory contains all documentation pages.  
A unique directory inside `/content` creates a new "section" in the documentation. The root of the section is the `_index.md` page inside that directory.

### Front matter
Each page contains metadata called [front matter](https://gohugo.io/content-management/front-matter/). Each page requires front matter to render.

```yaml
---
title: "Official Providers"
weight: 610
---
```

`title` defines the name of the page.  
`weight` determines the ordering of the page in the table of contents. Lower weight pages come before higher weights in the table of contents. The value of `weight` is otherwise arbitrary.

{{< hint type="note" >}}
The `weight` of a directory's `_index.md` page moves the entire section of content in the table of contents.
{{< /hint >}}

### Links
#### Linking between docs pages
Link between pages or sections within the documentation using standard [markdown link syntax](https://www.markdownguide.org/basic-syntax/#links). Use the [Hugo ref shortcode](https://gohugo.io/content-management/shortcodes/#ref-and-relref) with the path of the file relative to `/content` for the link location.

For example, to link to the "Official Providers" page create a markdown link like this:

```markdown
[a link to the Official Providers page]({{</* ref "providers/_index.md" */>}})
```


{{<hint type="note">}}
The `ref` value is of the markdown file, including `.md` extension. Don't link to a web address.
{{< /hint >}}

If the `ref` value points to a page that doesn't exist, Hugo fails to start. 

For example, providing `index.md` instead of `_index.md` would cause an error like the this:
```shell
Start building sites …
hugo v0.98.0-165d299cde259c8b801abadc6d3405a229e449f6 darwin/arm64 BuildDate=2022-04-28T10:23:30Z VendorInfo=gohugoio
ERROR 2022/08/15 13:53:46 [en] REF_NOT_FOUND: Ref "providers/index.md": "/Users/plumbis/git/docs/content/contributing.md:64:41": page not found
Error: Error building site: logged 1 error
```

Using `ref` ensures links render in the staging environment and prevents broken links.

#### Linking to external sites
Minimize linking to external sites. When linking to any page outside of `docs.upbound.io` use standard [markdown link syntax](https://www.markdownguide.org/basic-syntax/#links) without using the `ref` shortcode.

For example, 
```markdown
[Go to Upbound](http://upbound.io)
```

### Hints and alert boxes
Hint and alert boxes provide call-outs to important information to the reader. Upbound docs support five different hint box styles.

{{< tabs "hints" >}}
{{< tab "Note">}}
{{< hint type="Note" >}}
An example note box.
{{< /hint >}}
{{< /tab >}}

{{< tab "Tip">}}
{{< hint type="Tip" >}}
An example tip box.
{{< /hint >}}
{{< /tab >}}

{{< tab "Important">}}
{{< hint type="important" >}}
An example important box.
{{< /hint >}}
{{< /tab >}}

{{< tab "Caution">}}
{{< hint type="caution" >}}
An example caution box.
{{< /hint >}}
{{< /tab >}}

{{< tab "Warning">}}
{{< hint type="warning" >}}
An example warning box.
{{< /hint >}}
{{< /tab >}}

{{< /tabs >}}

Create a hint by using a shortcode in your markdown file:
```html
{{</* hint type="note" */>}}
Your box content. This hint box is a note.
{{</* /hint */>}}
```

Use `note`, `tip`, `important`, `caution` or `warning` as the `type=` value.

### Tabs
Use tabs to present information about a single topic with multiple exclusive options. For example, creating a resource via command-line or Upbound console. 

To create a tab set, first create a `tabs` shortcode and use multiple `tab` shortcodes inside for each tab.

Each `tabs` shortcode requires a name that's unique to the page it's on. Each `tab` name is the title of the tab on the webpage. 

For example
```
{{</* tabs "my-unique-name" */>}}

{{</* tab "Command-line" */>}}
An example tab. Place anything inside a tab.
{{</* /tab */>}}

{{</* tab "GUI" */>}}
A second example tab. 
{{</* /tab */>}}

{{</* /tabs */>}}
```

This code block renders the following tabs
{{< tabs "my-unique-name" >}}

{{< tab "Command-line" >}}
An example tab. Place anything inside a tab.
{{< /tab >}}

{{< tab "GUI" >}}
A second example tab. 
{{< /tab >}}

{{< /tabs >}}

{{< hint type="warning" >}}
Both `tab` and `tabs` require opening and closing tags. Unclosed tags causes Hugo to fail.
{{< /hint >}}

### Hide long outputs
For long outputs that are relevant but contain too much detail or are only relevant for some cases use the `expand` shortcode. 

Provide a label to display for expansion block and any content to hide inside the shortcode.
For example, 
````yaml
{{</* expand "A large XRD" */>}}
```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xpostgresqlinstances.database.example.org
spec:
  group: database.example.org
  names:
    kind: XPostgreSQLInstance
    plural: xpostgresqlinstances
  claimNames:
    kind: PostgreSQLInstance
    plural: postgresqlinstances
  versions:
  - name: v1alpha1
    served: true
    referenceable: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              parameters:
                type: object
                properties:
                  storageGB:
                    type: integer
                required:
                - storageGB
            required:
            - parameters
```
{{</* /expand */>}}
````

{{<expand "A large XRD" >}}
```yaml
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xpostgresqlinstances.database.example.org
spec:
  group: database.example.org
  names:
    kind: XPostgreSQLInstance
    plural: xpostgresqlinstances
  claimNames:
    kind: PostgreSQLInstance
    plural: postgresqlinstances
  versions:
  - name: v1alpha1
    served: true
    referenceable: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              parameters:
                type: object
                properties:
                  storageGB:
                    type: integer
                required:
                - storageGB
            required:
            - parameters
```
{{< /expand >}}


### Images
Place images in the `/static/images` directory. Reference images with [markdown](https://www.markdownguide.org/basic-syntax/#images-1) using `/images` as the root directory.

For example, to link to the image located at `/static/images/robots/create-first-robot-token.png` use

```markdown
![The alt text for an example image](/images/robots/create-first-robot-token.png)
```

## Style guide
The Upbound documentation style guide is still under construction, but the [Kubernetes style guide](https://kubernetes.io/docs/contribute/style/) is a safe reference. 

### Vale
Upbound documentation is implementing [Vale](https://vale.sh/docs/vale-cli/installation/) for spell checking, style guide enforcement and linting. 

Vale isn't enabled in the build process today. In the future all docs must pass Vale linting. 

{{<hint type="note" >}}
Today, there is no distinction between Vale errors and warnings.
{{< /hint >}}

#### Clone the Vale repository
Upbound docs use Vale as a git submodule. Clone and run Vale locally from the [upbound/vale](https://github.com/upbound/vale) repository.

{{<hint type="tip" >}}
A [Vale plug-in](https://marketplace.visualstudio.com/items?itemName=errata-ai.vale-server) exists for VSCode users.
{{< /hint >}}

It's recommended to manually run Vale against any contribution before opening a PR. 

#### Updating Vale rules
If the documentation contribution incorrectly violates a Vale rule issue a PR against the `main` branch of the [Vale repository](https://github.com/upbound/vale). If you are unclear on how to update Vale, [open an issue](https://github.com/upbound/vale/issues/new/choose) against the Vale repository with your suggested change.

#### Disabling Vale rules
If a Vale error is an actual exception individual Vale rules can be temporarily turned off.

To turn off Vale checking, use an HTML comment with `<!-- vale $rule = NO -->` before the text and `<!-- vale $rule = YES -->` . 

{{<hint type="tip" >}}
Vale requires the space surrounding the `=`. `YES` and `NO` must be in capital case.
{{< /hint >}}

Any Vale rule that's turned off must include an HTML comment justifying why the rule's turned off.

<!-- vale Google.We = NO --> 
For example, the phrase "we're Upbound users" violates the `Google.We` rule. To include the phrase without a Vale error use `<!-- vale Google.We = NO -->`.

```html
<!-- disabling Google.We for demonstration purposes -->
<!-- vale Google.We = NO --> 
We're Upbound users.
<!-- vale Google.We = YES -->
```

{{<hint type="warning" >}}
Failing to enable the rule again with `= YES` disables checking for the rest of the document.
{{< /hint >}}
