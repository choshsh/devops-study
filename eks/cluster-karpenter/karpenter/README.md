## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.node_class_default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.node_pool_default](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input\_azs) | The availability zones to use for the EKS cluster | `list(string)` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | The name of the EKS cluster to create for Karpenter | `string` | n/a | yes |
| <a name="input_eks_discovery_tag"></a> [eks\_discovery\_tag](#input\_eks\_discovery\_tag) | The tag to use for EKS cluster, security\_group, subnet discovery | `map(number)` | n/a | yes |
| <a name="input_karpenter_role_name"></a> [karpenter\_role\_name](#input\_karpenter\_role\_name) | The name of the IAM role to create for Karpenter | `string` | n/a | yes |

## Outputs

No outputs.
