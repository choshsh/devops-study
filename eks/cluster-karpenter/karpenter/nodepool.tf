resource "kubernetes_manifest" "node_class_default" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      amiFamily                  = "AL2"
      role                       = var.karpenter_role_name
      subnetSelectorTerms        = [{ tags = var.eks_discovery_tag }]
      securityGroupSelectorTerms = [{ tags = var.eks_discovery_tag }]
      blockDeviceMappings = [
        {
          deviceName = "/dev/xvda"
          ebs = {
            volumeSize = "30Gi"
            volumeType = "gp3"
            encrypted  = true
          }
        },
      ]
      kubelet = {
        imageGCHighThresholdPercent = 75
        imageGCLowThresholdPercent  = 70
      }
      amiSelectorTerms = [{
        # https://karpenter.sh/v1.0/concepts/nodeclasses/#specamiselectorterms
        alias = "al2@v20241121"
      }]
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
    apiVersion = "karpenter.sh/v1"
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
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
          expireAfter = "24h"
          requirements = [
            {
              key      = "karpenter.k8s.aws/instance-category"
              operator = "In"
              values   = ["c", "m"]
            },
            {
              key      = "karpenter.k8s.aws/instance-cpu"
              operator = "In"
              values   = ["2", "4", "8"]
            },
            {
              key      = "karpenter.k8s.aws/instance-generation"
              operator = "Gt"
              values   = ["5"]
            },
            {
              key      = "karpenter.k8s.aws/instance-memory"
              operator = "Gt"
              values   = ["4095"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["spot", "on-demand"]
            },
            {
              key      = "topology.kubernetes.io/zone"
              operator = "In"
              values   = var.azs
            },
          ]
        }
      }
      limits = {
        cpu    = "32"
        memory = "128Gi"
      }
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "10s"
        budgets = [
          { nodes = "20%" }
        ]
      }
    }
  }

  field_manager {
    force_conflicts = true
  }

  depends_on = [kubernetes_manifest.node_class_default]
}
