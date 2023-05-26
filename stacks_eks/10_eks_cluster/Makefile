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

DEPLOY_ALL  =  eks_cluster
DEPLOY_ALL +=  eks_oidc
DEPLOY_ALL +=  eks_fargate_profile
deploy: $(DEPLOY_ALL)

RM_ALL      =  rm_eks_fargate_profile
RM_ALL     +=  rm_eks_oidc
RM_ALL     +=  rm_eks_cluster
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

eks_cluster: data_aws
	$(eval STACK_NAME   := $(A_STACK_PREFIX)Cluster$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_eks_cluster.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	cfn-lint $(CFN_YML)
	rain deploy $(CFN_YML) $(STACK_NAME) $(RAINOPT) \
	--profile $(E_PROFILE) \
	--tags $(A_RAIN_DEFAULT_TAG) \
	--params \
	EKSClusterName=$(A_EKS_CLUSTER_NAME),\
	EKSVersion=$(A_EKS_VERSION),\
	VpcId=$(VPC_ID),\
	SubnetIdPublic1=$(SUBNET_ID_PUBLIC1),\
	SubnetIdPublic2=$(SUBNET_ID_PUBLIC2),\
	SubnetIdPrivate1=$(SUBNET_ID_PRIVATE1),\
	SubnetIdPrivate2=$(SUBNET_ID_PRIVATE2),\
	PrefixListId=$(PREFIX_LIST_ID)

eks_oidc:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)Oidc$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_eks_oidc.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	cfn-lint $(CFN_YML)
	rain deploy $(CFN_YML) $(STACK_NAME) $(RAINOPT) \
	--profile $(E_PROFILE) \
	--tags $(A_RAIN_DEFAULT_TAG) \
	--params \
	EKSClusterName=$(A_EKS_CLUSTER_NAME)

eks_fargate_profile: data_aws
	$(eval STACK_NAME   := $(A_STACK_PREFIX)FargateProfile$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_eks_fargate_profile.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	cfn-lint $(CFN_YML)
	rain deploy $(CFN_YML) $(STACK_NAME) $(RAINOPT) \
	--profile $(E_PROFILE) \
	--tags $(A_RAIN_DEFAULT_TAG) \
	--params \
	EKSClusterName=$(A_EKS_CLUSTER_NAME),\
	SubnetId1=$(SUBNET_ID_PRIVATE1),\
	SubnetId2=$(SUBNET_ID_PRIVATE2)

#---------------------------
# REMOVE
#---------------------------

rm_eks_cluster:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)Cluster$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_eks_cluster.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	rain rm $(STACK_NAME) --profile $(E_PROFILE) $(RAINOPT)

rm_eks_oidc:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)Oidc$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_eks_oidc.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	rain rm $(STACK_NAME) --profile $(E_PROFILE) $(RAINOPT)

rm_eks_fargate_profile:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)FargateProfile$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_eks_fargate_profile.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	rain rm $(STACK_NAME) --profile $(E_PROFILE) $(RAINOPT)

#---------------------------
# DATASOURCE
#---------------------------

data_aws:
	@echo "*** data_aws"
	$(eval STACK_VPC_PREFIX := BaseVpc)
	$(eval VPC_ID := \
		$(shell aws ec2 describe-vpcs \
			--profile $(E_PROFILE) \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(STACK_VPC_PREFIX)$(E_STACK_SUFFIX)' \
			--query 'Vpcs[].[VpcId]' \
			--output text))
	$(eval SUBNET_ID_PUBLIC1 := \
		$(shell aws ec2 describe-subnets \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(STACK_VPC_PREFIX)$(E_STACK_SUFFIX)-Public1' \
			--profile $(E_PROFILE) \
			--query 'Subnets[].[SubnetId]' \
			--output text))
	$(eval SUBNET_ID_PUBLIC2 := \
		$(shell aws ec2 describe-subnets \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(STACK_VPC_PREFIX)$(E_STACK_SUFFIX)-Public2' \
			--profile $(E_PROFILE) \
			--query 'Subnets[].[SubnetId]' \
			--output text))
	$(eval SUBNET_ID_PRIVATE1 := \
		$(shell aws ec2 describe-subnets \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(STACK_VPC_PREFIX)$(E_STACK_SUFFIX)-Private1' \
			--profile $(E_PROFILE) \
			--query 'Subnets[].[SubnetId]' \
			--output text))
	$(eval SUBNET_ID_PRIVATE2 := \
		$(shell aws ec2 describe-subnets \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(STACK_VPC_PREFIX)$(E_STACK_SUFFIX)-Private2' \
			--profile $(E_PROFILE) \
			--query 'Subnets[].[SubnetId]' \
			--output text))
	$(eval PREFIX_LIST_ID := \
		$(shell aws ec2 describe-managed-prefix-lists \
			--filters 'Name=prefix-list-name,Values=$(STACK_VPC_PREFIX)PrefixList$(E_STACK_SUFFIX)-safe-public' \
			--profile $(E_PROFILE) \
			--query 'PrefixLists[].[PrefixListId]' \
			--output text))
