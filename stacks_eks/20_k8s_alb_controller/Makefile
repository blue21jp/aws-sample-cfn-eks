###########################################################################
#
# Makefile
#
###########################################################################
include ../../global/variables.mk
include ../variables_all.mk
include ../variables_$(ENV).mk

# local variavles

HELM_REL        = aws-load-balancer-controller
K8S_NAMESPACE   = kube-system
K8S_SVC_NAME    = aws-load-balancer-controller
IAM_POLICY_NAME = $(A_PROJECT)-AWSLoadBalancerControllerIAMPolicy
IAM_ROLE_NAME   = $(A_PROJECT)-alb-role

#---------------------------
# ALL
#---------------------------

all:
	@echo "unknown target. (deploy or remove)"

DEPLOY_ALL  = helm_alb
DEPLOY_ALL += aws_alb_iam
deploy: $(DEPLOY_ALL)

RM_ALL      = rm_aws_alb_iam
RM_ALL     += rm_helm_alb
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

helm_alb: data_aws data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] alb controller"
	@echo "-------------------------------------------"
	@helm repo add eks https://aws.github.io/eks-charts \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"
	@helm upgrade -i $(HELM_REL) eks/aws-load-balancer-controller \
		--namespace "$(K8S_NAMESPACE)" \
		--version "1.4.1" \
		--wait \
		--set "clusterName=$(A_EKS_CLUSTER_NAME)" \
		--set "image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller" \
		--set "image.tag=v2.4.2" \
		--set "replicaCount=1" \
		--set "serviceAccount.name=$(K8S_SVC_NAME)" \
		--set "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=arn:aws:iam::$(ACCOUNT_ID):role/$(IAM_ROLE_NAME)" \
		--set "region=$(REGION)" \
		--set "vpcId=$(VPC_ID)" \
		--kube-apiserver "$(EKS_ENDPOINT)" \
		--kube-token "$(EKS_TOKEN)" \
		--kube-ca-file "/tmp/ca.crt"

aws_alb_iam: data_aws
	@echo "-------------------------------------------"
	@echo " [eksctl] iam role for alb controller"
	@echo "-------------------------------------------"
	@aws iam create-policy \
	--profile $(E_PROFILE) \
	--policy-name $(IAM_POLICY_NAME) \
	--policy-document file://./aws_alb_policy.json
	@eksctl create iamserviceaccount \
	--profile $(E_PROFILE) \
	--cluster=$(A_EKS_CLUSTER_NAME) \
	--namespace=$(K8S_NAMESPACE) \
	--name=$(K8S_SVC_NAME) \
	--role-name=$(IAM_ROLE_NAME) \
	--attach-policy-arn=arn:aws:iam::$(ACCOUNT_ID):policy/$(IAM_POLICY_NAME) \
	--override-existing-serviceaccounts \
	--approve

#---------------------------
# REMOVE
#---------------------------

rm_aws_alb_iam: data_aws
	@echo "-------------------------------------------"
	@echo " [eksctl] iam role for alb"
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

rm_helm_alb: data_eks_auth
	@echo "-------------------------------------------"
	@echo " [helm] alb controller"
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
