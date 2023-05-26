###########################################################################
#
# Makefile
#
###########################################################################
include ../../global/variables.mk
include ../variables_all.mk
include ../variables_$(ENV).mk

# local variavles

HELM_REL        = metrics-server
K8S_NAMESPACE   = kube-system

#---------------------------
# ALL
#---------------------------

all:
	@echo "unknown target. (deploy or remove)"

DEPLOY_ALL = helm_metric_server
deploy: $(DEPLOY_ALL)

RM_ALL     = rm_helm_metric_server
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

helm_metric_server: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] metric server"
	@echo "-------------------------------------------"
	@helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"
	@helm upgrade -i $(HELM_REL) metrics-server/metrics-server \
		--namespace "$(K8S_NAMESPACE)" \
		--version "3.8.2" \
		--wait \
		--set "metrics.enabled=false" \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"

#---------------------------
# REMOVE
#---------------------------

rm_helm_metric_server: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] metric server"
	@echo "-------------------------------------------"
	@helm delete $(HELM_REL) \
		--namespace $(K8S_NAMESPACE) \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"

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
