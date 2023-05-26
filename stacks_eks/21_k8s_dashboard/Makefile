###########################################################################
#
# Makefile
#
###########################################################################
include ../../global/variables.mk
include ../variables_all.mk
include ../variables_$(ENV).mk

# local variavles

HELM_REL         = kubernetes-dashboard
K8S_NAMESPACE    = kubernetes-dashboard
K8S_INGRESS_NAME = $(A_PROJECT)-dashboard

#---------------------------
# ALL
#---------------------------

all:
	@echo "unknown target. (deploy or remove)"

DEPLOY_ALL  = helm_dashboard
DEPLOY_ALL += dashboard_ingress
deploy: $(DEPLOY_ALL)

RM_ALL      = rm_dashboard_ingress
RM_ALL     += rm_helm_dashboard
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

helm_dashboard: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] dashboard"
	@echo "-------------------------------------------"
	@helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"
	@helm upgrade -i $(HELM_REL) kubernetes-dashboard/kubernetes-dashboard \
		--namespace "$(K8S_NAMESPACE)" \
		--version "6.0.0" \
		--wait \
		--set "service.externalPort=9090" \
		--set "protocolHttp=true" \
		--set "extraArgs={--enable-skip-login,--enable-insecure-login,--disable-settings-authorizer,--insecure-bind-address=0.0.0.0}" \
		--set "rbac.clusterReadOnlyRole=true" \
		--set "metricsScraper.enabled=true" \
		--set "resources.requests.cpu=2" \
		--set "resources.requests.memory=200Mi" \
		--set "resources.limits.cpu=2" \
		--set "resources.limits.memory=200Mi" \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"

dashboard_ingress: data_aws data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] dashboard ingress"
	@echo "-------------------------------------------"
	@cat ./k8s_dashboard_ingress.yml \
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

rm_helm_dashboard: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] dashboard"
	@echo "-------------------------------------------"
	@helm delete $(HELM_REL) \
		--namespace $(K8S_NAMESPACE) \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"

rm_dashboard_ingress: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] dashboard ingress"
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
