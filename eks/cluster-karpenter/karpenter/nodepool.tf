resource "kubernetes_manifest" "node_class_default" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1beta1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      amiFamily = "AL2"
      role      = var.karpenter_role_name
      subnetSelectorTerms = [{ tags = var.eks_discovery_tag }]
      securityGroupSelectorTerms = [{ tags = var.eks_discovery_tag }]
      blockDeviceMappings = [
        {
          deviceName = "/dev/xvda"
          ebs = {
            volumeSize = "20Gi"
            volumeType = "gp3"
            encrypted  = true
          }
        }
      ]
      tags = var.eks_discovery_tag
    }
  }
}

# 공식문서: https://karpenter.sh/docs/concepts/disruption/
#
# consolidationPolicy: WhenUnderutilized | WhenEmpty
#   - WhenUnderutilized: Karpenter는 통합을 위해 모든 노드를 고려하고 노드가 충분히 활용되지 않고 비용을 줄이기 위해 변경할 수 있다는 것을 발견했을 때 노드를 제거하거나 교체하려고 시도
#   - WhenEmpty: 워크로드 포드가 없는 통합을 위한 노드만 고려 (데몬셋 무시)
# consolidateAfter: 종료 결정 후 대기할 시간 (WhenEmpty 때만 사용 가능)
# expireAfter: ttl
resource "kubernetes_manifest" "node_pool_spot" {
  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "NodePool"
    metadata = {
      name = "default-spot"
      labels = {
        "karpenter.sh/managed" = "true"
      }
    }
    spec = {
      template = {
        spec = {
          nodeClassRef = {
            name = "default"
          }
          requirements = [
            {
              key      = "karpenter.k8s.aws/instance-category"
              operator = "In"
              values = ["c", "m"]
            },
            {
              key      = "karpenter.k8s.aws/instance-cpu"
              operator = "In"
              values = ["2", "4"]
            },
            {
              key      = "karpenter.k8s.aws/instance-generation"
              operator = "Gt"
              values = ["2"]
            },
            {
              key      = "karpenter.k8s.aws/instance-memory"
              operator = "Gt"
              values = ["2048"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values = ["arm64"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values = ["spot"]
            },
            {
              key      = "topology.kubernetes.io/zone"
              operator = "In"
              values   = var.azs
            },
            {
              key      = "capacity-spread-2"
              operator = "In"
              values = ["2"]
            },
            {
              key      = "capacity-spread-4"
              operator = "In"
              values = ["2", "3", "4"]
            },
            {
              key      = "capacity-spread-6"
              operator = "In"
              values = ["2", "3", "4", "5", "6"]
            },
            {
              key      = "role"
              operator = "In"
              values = ["app"]
            }
          ]
          kubelet = {
            imageGCHighThresholdPercent = 75
            imageGCLowThresholdPercent  = 70
          }
        }
      }
      limits = {
        cpu    = "32"
        memory = "128Gi"
      }
      disruption = {
        consolidationPolicy = "WhenEmpty"
        expireAfter         = "24h"
        consolidateAfter    = "10s"
      }
    }
  }

  field_manager {
    force_conflicts = true
  }

  depends_on = [kubernetes_manifest.node_class_default]
}

# resource "kubernetes_manifest" "node_pool_on_demand" {
#   manifest = {
#     apiVersion = "karpenter.sh/v1beta1"
#     kind       = "NodePool"
#     metadata   = {
#       name   = "default-on-demand"
#       labels = {
#         "karpenter.sh/managed" = "true"
#       }
#     }
#     spec = {
#       template = {
#         spec = {
#           nodeClassRef = {
#             name = "default"
#           }
#           requirements = [
#             {
#               key      = "karpenter.k8s.aws/instance-category"
#               operator = "In"
#               values   = ["t", "c", "m"]
#             },
#             {
#               key      = "karpenter.k8s.aws/instance-cpu"
#               operator = "In"
#               values   = ["2", "4"]
#             },
#             {
#               key      = "karpenter.k8s.aws/instance-generation"
#               operator = "Gt"
#               values   = ["2"]
#             },
#             {
#               key      = "karpenter.k8s.aws/instance-memory"
#               operator = "Gt"
#               values   = ["2048"]
#             },
#             {
#               key      = "kubernetes.io/arch"
#               operator = "In"
#               values   = ["arm64"]
#             },
#             {
#               key      = "karpenter.sh/capacity-type"
#               operator = "In"
#               values   = ["on-demand"]
#             },
#             {
#               key      = "topology.kubernetes.io/zone"
#               operator = "In"
#               values   = var.azs
#             },
#             {
#               key      = "capacity-spread-2"
#               operator = "In"
#               values   = ["1"]
#             },
#             {
#               key      = "capacity-spread-3"
#               operator = "In"
#               values   = ["1"]
#             },
#             {
#               key      = "capacity-spread-4"
#               operator = "In"
#               values   = ["1"]
#             },
#             {
#               key      = "capacity-spread-6"
#               operator = "In"
#               values   = ["1"]
#             },
#             {
#               key      = "role"
#               operator = "In"
#               values   = ["app"]
#             }
#           ]
#           kubelet = {
#             imageGCHighThresholdPercent = 75
#             imageGCLowThresholdPercent  = 70
#           }
#         }
#       }
#       limits = {
#         cpu    = "32"
#         memory = "128Gi"
#       }
#       disruption = {
#         consolidationPolicy = "WhenEmpty"
#         expireAfter         = "24h"
#         consolidateAfter    = "10s"
#       }
#     }
#   }
#
#   field_manager {
#     force_conflicts = true
#   }
#
#   depends_on = [kubernetes_manifest.node_class_default]
# }
