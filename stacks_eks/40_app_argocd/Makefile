###########################################################################
#
# Makefile
#
###########################################################################
include ../../global/variables.mk
include ../variables_all.mk
include ../variables_$(ENV).mk

# Makefileの環境変数をターゲットで実行するシェルで参照可能にする

export

# local variavles

K8S_ARGOCD_NAMESPACE    = argocd
K8S_APP_NAMESPACE       = app

#---------------------------
# ALL
#---------------------------

all:
	@echo "unknown target. (deploy or remove)"

DEPLOY_ALL  = argocd_secret
DEPLOY_ALL += argocd_repo
DEPLOY_ALL += argocd_app
deploy: $(DEPLOY_ALL)

RM_ALL      = rm_argocd_app
RM_ALL     += rm_argocd_repo
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

argocd_secret: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] external secret"
	@echo "-------------------------------------------"
	@cat ./k8s_external_secret.yaml \
	| ARGOCD_NAMESPACE=$(K8S_ARGOCD_NAMESPACE) \
	  GIT_SSH_PRIVATE_KEY=$(A_GIT_SSM_PARAMS_NAME) \
	  envsubst \
	| kubectl apply -f - \
		--wait=true \
		--server=$(EKS_ENDPOINT) \
		--token="$(EKS_TOKEN)" \
		--certificate_authority=/tmp/ca.crt

argocd_repo: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] argocd repository"
	@echo "-------------------------------------------"
	bash ./argocd_git_repositorys.sh create

argocd_app: data_aws data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] argocd application"
	@echo "-------------------------------------------"
	bash ./argocd_apps.sh create

#---------------------------
# REMOVE
#---------------------------

rm_argocd_app: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] argocd app"
	@echo "-------------------------------------------"
	bash ./argocd_apps.sh delete

rm_argocd_repo: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] argocd repository"
	@echo "-------------------------------------------"
	bash ./argocd_git_repositorys.sh delete

#---------------------------
# DATASOURCE
#---------------------------

data_aws:
	@echo "*** data_aws"
	$(eval STACK_VPC_PREFIX := BaseVpc)
	$(eval STACK_EKS_PREFIX := EksCluster)
	$(eval ALB_SG := \
		$(shell aws ec2 describe-security-groups \
			--profile $(E_PROFILE) \
			--filters "Name=group-name,Values=$(STACK_EKS_PREFIX)$(E_STACK_SUFFIX)-alb" \
			--query 'SecurityGroups[].[GroupId]' \
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
