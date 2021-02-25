
# Module `terraform-google-dns`

Core Version Constraints:
* `>= 0.14`

Provider Requirements:
* **google-beta (`hashicorp/google-beta`):** (any version)

## Input Variables
* `dns_policies` (default `{}`): DNS Policies for your VPC(s)
* `dns_policy_defaults` (default `null`)
* `dns_zone_defaults` (default `null`)
* `dns_zones` (default `{}`): Map of dns zones and their configurations
* `environment` (required): Company environment for which the resources are created (e.g. dev, tst, acc, prd, all).
* `owner` (required): Owner of the resource. This variable is used to set the 'owner' label. Will be used as default for each subnet, but can be overridden using the subnet settings.
* `project` (required): Company project name.

## Output Values
* `dns_policy_defaults`: Defaults for overriding without copy/pasting half the module
* `dns_zone_defaults`: Defaults for overriding without copy/pasting half the module
* `name_servers`: Delegate your managed_zone to these virtual name servers; defined by the server.

## Managed Resources
* `google_dns_managed_zone.map` from `google-beta`
* `google_dns_policy.map` from `google-beta`

## Creating a new release
After adding your changed and committing the code to GIT, you will need to add a new tag.
```
git tag vx.x.x
git push --tag
```
If your changes might be breaking current implementations of this module, make sure to bump the major version up by 1.

If you want to see which tags are already there, you can use the following command:
```
git tag --list
```
