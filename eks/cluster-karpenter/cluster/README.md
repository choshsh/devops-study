## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.11 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.24 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.11 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.24 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.20.0 |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | terraform-aws-modules/eks/aws//modules/karpenter | 19.20.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.eks_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.eks_cluster_to_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_storage_class.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [aws_ecrpublic_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecrpublic_authorization_token) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_addons"></a> [cluster\_addons](#input\_cluster\_addons) | 클러스터의 애드온. Ref: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#addons | <pre>map(object({<br>    addon_version        = string<br>    configuration_values = string<br>  }))</pre> | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | 클러스터의 이름 | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | 클러스터의 버전 | `string` | n/a | yes |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | 클러스터의 컨트롤 플레인 서브넷 ID | `list(string)` | n/a | yes |
| <a name="input_eks_discovery_tag"></a> [eks\_discovery\_tag](#input\_eks\_discovery\_tag) | EKS 클러스터를 찾기 위한 태그 | `map(number)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | 클러스터의 서브넷 ID | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 클러스터의 태그 | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | 클러스터의 VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | EKS 클러스터의 API Server의 CA 인증서 |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS 클러스터의 API Endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS 클러스터의 이름 |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | n/a |
| <a name="output_control_plane_security_group_id"></a> [control\_plane\_security\_group\_id](#output\_control\_plane\_security\_group\_id) | n/a |
| <a name="output_eks_discovery_tag"></a> [eks\_discovery\_tag](#output\_eks\_discovery\_tag) | n/a |
| <a name="output_karpenter_role_name"></a> [karpenter\_role\_name](#output\_karpenter\_role\_name) | karpenter로 생성되는 NodeGroup의 IAM Role 이름 |
| <a name="output_node_group_security_group_id"></a> [node\_group\_security\_group\_id](#output\_node\_group\_security\_group\_id) | n/a |
