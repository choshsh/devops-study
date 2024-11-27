AWS_PROFILE := choshsh
AWS_REGION := us-east-1

# ---------------------------------------------------------------------------------------------------------------------
# Init
# ---------------------------------------------------------------------------------------------------------------------
.PHONY: plan-init
plan-init:
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform plan -var init=true

.PHONY: apply-init
apply-init:
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform apply -var init=true

# ----------------------------------------------------------------------------------------------------------------------
# After
# ----------------------------------------------------------------------------------------------------------------------
.PHONY: plan-after
plan-after:
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform plan

.PHONY: apply-after
apply-after:
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform apply


# ----------------------------------------------------------------------------------------------------------------------
# Destroy
# ----------------------------------------------------------------------------------------------------------------------
.PHONY: destroy-helm
destroy-helm:
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform destroy -target=module.helm

.PHONY: destroy-karpenter
destroy-karpenter:
	# PDB 때문에 노드 수동 삭제 필요
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform destroy -target=module.karpenter

.PHONY: destroy-eks
destroy-eks:
	# 노드 ENI 수동 삭제 필요
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform destroy -target=module.eks -var init=true


.PHONY: destroy-vpc
destroy-vpc:
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform destroy -var init=true

.PHONY: state
state:
	AWS_PROFILE=${AWS_PROFILE} AWS_REGION=${AWS_REGION} terraform state list