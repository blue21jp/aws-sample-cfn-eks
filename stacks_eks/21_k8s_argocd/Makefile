###########################################################################
#
# Makefile
#
###########################################################################
include ../../global/variables.mk
include ../variables_all.mk
include ../variables_$(ENV).mk

# local variavles

HELM_REL         = argocd
K8S_NAMESPACE    = argocd
K8S_INGRESS_NAME = $(A_PROJECT)-argocd

#---------------------------
# ALL
#---------------------------

all:
	@echo "unknown target. (deploy or remove)"

DEPLOY_ALL  = helm_argocd
DEPLOY_ALL += argocd_ingress
deploy: $(DEPLOY_ALL)

RM_ALL      = rm_argocd_ingress
RM_ALL     += rm_helm_argocd
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

helm_argocd: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] argocd"
	@echo "-------------------------------------------"
	@helm repo add argo https://argoproj.github.io/argo-helm \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"
	@helm upgrade -i $(HELM_REL) argo/argo-cd \
		--namespace $(K8S_NAMESPACE) \
		--version "5.16.9" \
		--wait \
		--set "server.extraArgs={--insecure}" \
		--set "configs.cm.exec\\.enabled=true" \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"

argocd_ingress: data_aws data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] argocd ingress"
	@echo "-------------------------------------------"
	@cat ./k8s_argocd_ingress.yml \
	| NAME=$(K8S_INGRESS_NAME) \
	  NAMESPACE=$(K8S_NAMESPACE) \
	  SG_IDS=$(ALB_SG) \
	  envsubst \
	| kubectl apply -f - \
		--server=$(EKS_ENDPOINT) \
		--token="$(EKS_TOKEN)" \
		--certificate_authority=/tmp/ca.crt

#---------------------------
# REMOVE
#---------------------------

rm_helm_argocd: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] argocd"
	@echo "-------------------------------------------"
	@helm delete $(HELM_REL) \
		--namespace $(K8S_NAMESPACE) \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"

rm_argocd_ingress: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] argocd ingress"
	@echo "-------------------------------------------"
	@kubectl delete ingress $(K8S_INGRESS_NAME) \
		--namespace $(K8S_NAMESPACE) \
		--server=$(EKS_ENDPOINT) \
		--token="$(EKS_TOKEN)" \
		--certificate_authority=/tmp/ca.crt

#---------------------------
# DATASOURCE
#---------------------------

data_aws:
	@echo "*** data_aws"
	$(eval STACK_VPC_PREFIX := BaseVpc)
	$(eval STACK_EKS_PREFIX := EksCluster)
	$(eval VPC_ID := \
		$(shell aws ec2 describe-vpcs \
			--profile $(E_PROFILE) \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(STACK_VPC_PREFIX)$(E_STACK_SUFFIX)' \
			--query 'Vpcs[].[VpcId]' \
			--output text))
	$(eval ALB_SG := \
		$(shell aws ec2 describe-security-groups \
			--profile $(E_PROFILE) \
			--filters "Name=group-name,Values=$(STACK_EKS_PREFIX)$(E_STACK_SUFFIX)-alb" \
			--query 'SecurityGroups[].[GroupId]' \
			--output text))
	$(eval REGION := \
		$(shell aws ec2 describe-availability-zones \
			--profile $(E_PROFILE) \
			--query 'AvailabilityZones[0].[RegionName]' \
			--output text))
	$(eval ACCOUNT_ID := \
		$(shell aws sts get-caller-identity \
			--profile $(E_PROFILE) \
			--query 'Account' \
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
