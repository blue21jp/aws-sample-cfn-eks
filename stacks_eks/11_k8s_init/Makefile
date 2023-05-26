###########################################################################
#
# Makefile
#
###########################################################################
include ../../global/variables.mk
include ../variables_all.mk
include ../variables_$(ENV).mk

#---------------------------
# ALL
#---------------------------

all:
	@echo "unknown target. (deploy or remove)"

DEPLOY_ALL  = eks_fargate_patch
DEPLOY_ALL += eks_namespace
DEPLOY_ALL += eks_cluster_sg
deploy: $(DEPLOY_ALL)

RM_ALL      = rm_eks_namespace
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

eks_fargate_patch: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] eks_fargate_patch"
	@echo "-------------------------------------------"
	@kubectl patch deployment coredns \
	--namespace=kube-system \
	--type=json \
	--patch='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]' \
	--server="$(EKS_ENDPOINT)" \
	--certificate_authority=/tmp/ca.crt \
	--token="$(EKS_TOKEN)"

eks_namespace: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] namespace"
	@echo "-------------------------------------------"
	@kubectl create namespace argocd \
	--server="$(EKS_ENDPOINT)" \
	--certificate_authority=/tmp/ca.crt \
	--token="$(EKS_TOKEN)"
	@kubectl create namespace kubernetes-dashboard \
	--server="$(EKS_ENDPOINT)" \
	--certificate_authority=/tmp/ca.crt \
	--token="$(EKS_TOKEN)"
	@kubectl create namespace app \
	--server="$(EKS_ENDPOINT)" \
	--certificate_authority=/tmp/ca.crt \
	--token="$(EKS_TOKEN)"

eks_cluster_sg: data_vpc
	@echo "-------------------------------------------"
	@echo " [awscli] cluster sg ingress"
	@echo "-------------------------------------------"
	$(eval SG_ID := $(shell aws eks describe-cluster \
			--profile $(E_PROFILE) \
			--name $(A_EKS_CLUSTER_NAME) \
			--query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' \
			--output text))
	@aws ec2 authorize-security-group-ingress \
	--profile $(E_PROFILE) \
	--group-id $(SG_ID) \
	--ip-permissions \
	IpProtocol=-1,PrefixListIds='[{PrefixListId=$(PREFIX_LIST_ID)}]'

#---------------------------
# REMOVE
#---------------------------

rm_eks_namespace: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] namespace"
	@echo "-------------------------------------------"
	@kubectl delete namespace argocd \
	--server="$(EKS_ENDPOINT)" \
	--certificate_authority=/tmp/ca.crt \
	--token="$(EKS_TOKEN)"
	@kubectl delete namespace kubernetes-dashboard \
	--server="$(EKS_ENDPOINT)" \
	--certificate_authority=/tmp/ca.crt \
	--token="$(EKS_TOKEN)"
	@kubectl delete namespace app \
	--server="$(EKS_ENDPOINT)" \
	--certificate_authority=/tmp/ca.crt \
	--token="$(EKS_TOKEN)"

#---------------------------
# DATASOURCE
#---------------------------

data_vpc:
	@echo "*** data_vpc"
	$(eval STACK_VPC_PREFIX := BaseVpc)
	$(eval PREFIX_LIST_ID := \
		$(shell aws ec2 describe-managed-prefix-lists \
			--filters 'Name=prefix-list-name,Values=$(STACK_VPC_PREFIX)PrefixList$(E_STACK_SUFFIX)-vpc-internal' \
			--profile $(E_PROFILE) \
			--query 'PrefixLists[].[PrefixListId]' \
			--output text))

data_eks_auth:
	@echo "*** data_eks_auth"
	$(eval EKS_TOKEN := \
		$(shell aws eks get-token \
			--profile $(E_PROFILE) \
			--cluster-name $(A_EKS_CLUSTER_NAME) \
			| jq -r '.status.token'))
	$(eval EKS_ENDPOINT := \
		$(shell aws eks describe-cluster \
			--profile $(E_PROFILE) \
			--name $(A_EKS_CLUSTER_NAME) \
			--query 'cluster.endpoint' \
			--output text))
	@aws eks describe-cluster \
		--profile $(E_PROFILE) \
		--name $(A_EKS_CLUSTER_NAME) \
		--query 'cluster.certificateAuthority.data' \
		--output text \
		| base64 -d > /tmp/ca.crt
