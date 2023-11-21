module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.20.0"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  enable_karpenter_instance_profile_creation = true

  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "v0.32.1"

  values = [
    <<-EOT
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueueName: ${module.karpenter.queue_name}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn}
    EOT
  ]

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }
}

resource "kubectl_manifest" "node_class_default" {

  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: ${module.karpenter.role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      blockDeviceMappings:
        - deviceName: /dev/xvda
          ebs:
            volumeSize: 20Gi
            volumeType: gp3
            encrypted: true
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "node_pool_default" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["c", "m"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["2", "4", "8"]
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["5"]
            - key: "kubernetes.io/arch"
              operator: In
              values: ["arm64"]
            - key: "karpenter.sh/capacity-type"
              operator: In
              values: ["spot", "on-demand"]
      limits:
        cpu: 50
        memory: 128Gi
      disruption:
        consolidationPolicy: WhenEmpty
        expireAfter: 24h
        consolidateAfter: 0s
expireAfter
  YAML

  # 공식문서: https://karpenter.sh/docs/concepts/disruption/
  #
  # consolidationPolicy: WhenUnderutilized | WhenEmpty
  #   - WhenUnderutilized: Karpenter는 통합을 위해 모든 노드를 고려하고 노드가 충분히 활용되지 않고 비용을 줄이기 위해 변경할 수 있다는 것을 발견했을 때 노드를 제거하거나 교체하려고 시도
  #   - WhenEmpty: 워크로드 포드가 없는 통합을 위한 노드만 고려 (데몬셋 무시)
  # consolidateAfter: 종료 결정 후 대기할 시간 (WhenEmpty 때만 사용 가능)
  # expireAfter: ttl
  depends_on = [
    kubectl_manifest.node_class_default
  ]
}
