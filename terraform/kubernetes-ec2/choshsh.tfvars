cidr_block   = "10.0.0.0/16"
domain       = "choshsh.com"
domain_alias = ["www", "argocd", "grafana", "jenkins", "jaeger", "kiali"]

# EC2 config
master_node_count         = 1
master_node_instance_type = "t3a.medium"
worker_node_count         = 2
worker_node_instance_type = "t3a.large"
