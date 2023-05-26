###########################################################################
#
# Makefile
#
###########################################################################
include ../../global/variables.mk
include ../variables_all.mk
include ../variables_$(ENV).mk

# local variavles

HELM_REL        = external-secrets
K8S_NAMESPACE   = external-secrets
K8S_SVC_NAME    = external-secrets
IAM_POLICY_NAME = $(A_PROJECT)-eso-policy
IAM_ROLE_NAME   = $(A_PROJECT)-eso-role

#---------------------------
# ALL
#---------------------------

all:
	@echo "unknown target. (deploy or remove)"

DEPLOY_ALL  = aws_eso_role
DEPLOY_ALL += helm_eso
DEPLOY_ALL += eso_secret
deploy: $(DEPLOY_ALL)

RM_ALL      = rm_aws_eso_role
RM_ALL     += rm_helm_eso
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

aws_eso_role: data_aws
	@echo "-------------------------------------------"
	@echo " [eksctl] iam role for eso"
	@echo "-------------------------------------------"
	@aws iam create-policy \
	--profile $(E_PROFILE) \
	--policy-name $(IAM_POLICY_NAME) \
	--policy-document file://./aws_eso_policy.json
	@eksctl create iamserviceaccount \
	--profile $(E_PROFILE) \
	--cluster=$(A_EKS_CLUSTER_NAME) \
	--namespace=$(K8S_NAMESPACE) \
	--name=$(K8S_SVC_NAME) \
	--role-name=$(IAM_ROLE_NAME) \
	--attach-policy-arn=arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME) \
	--override-existing-serviceaccounts \
	--approve

helm_eso: data_aws data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] eso"
	@echo "-------------------------------------------"
	@helm repo add external-secrets https://charts.external-secrets.io \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"
	@helm upgrade -i $(HELM_REL) external-secrets/external-secrets \
		--namespace $(K8S_NAMESPACE) \
		--version "0.7.0" \
		--wait \
		--set "clusterName=$(A_EKS_CLUSTER_NAME)" \
		--set "serviceAccount.create=false" \
		--set "serviceAccount.name=external-secrets" \
		--set "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=arn:aws:iam::$(ACCOUNT_ID):role/$(IAM_ROLE_NAME)" \
		--set "installCRDs=true" \
		--set "region=$(REGION)" \
		--set "vpcId=$(VPC_ID)" \
		--set "webhook.port=9443" \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"

eso_secret: data_aws data_eks_auth
	@echo "-------------------------------------------"
	@echo " [kubectl] eso cluster secret"
	@echo "-------------------------------------------"
	@cat ./k8s_eso_cluster_secret.yml \
	| REGION=$(REGION) envsubst \
	| kubectl apply -f - \
		--server=$(EKS_ENDPOINT) \
		--token="$(EKS_TOKEN)" \
		--certificate_authority=/tmp/ca.crt

#---------------------------
# REMOVE
#---------------------------

rm_aws_eso_role: data_aws
	@echo "-------------------------------------------"
	@echo " [eksctl] iam role for eso"
	@echo "-------------------------------------------"
	@eksctl delete iamserviceaccount \
	--profile $(E_PROFILE) \
	--cluster=$(A_EKS_CLUSTER_NAME) \
	--namespace=$(K8S_NAMESPACE) \
	--name=$(K8S_SVC_NAME) \
	--wait
	@aws iam delete-policy \
	--profile $(E_PROFILE) \
	--policy-arn arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME)

rm_helm_eso: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] eso"
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
