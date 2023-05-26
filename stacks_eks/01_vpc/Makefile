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

DEPLOY_ALL  =  vpc_tag
deploy: $(DEPLOY_ALL)

RM_ALL      =  rm_vpc_tag
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

vpc_tag: data_aws
	@echo "-------------------------------------------"
	@echo " [awscli] vpc_tag"
	@echo "-------------------------------------------"
	@aws ec2 create-tags \
	--profile $(E_PROFILE) \
	--resources $(SUBNET_ID_PUBLIC1) $(SUBNET_ID_PUBLIC2) \
	--tags Key=kubernetes.io/role/elb,Value=1
	@aws ec2 create-tags \
	--profile $(E_PROFILE) \
	--resources $(SUBNET_ID_PUBLIC1) $(SUBNET_ID_PUBLIC2) \
	--tags Key=kubernetes.io/cluster/$(A_EKS_CLUSTER_NAME),Value=owned
	@aws ec2 create-tags \
	--profile $(E_PROFILE) \
	--resources $(SUBNET_ID_PRIVATE1) $(SUBNET_ID_PRIVATE2) \
	--tags Key=kubernetes.io/role/internal-elb,Value=1
	@aws ec2 create-tags \
	--profile $(E_PROFILE) \
	--resources $(SUBNET_ID_PRIVATE1) $(SUBNET_ID_PRIVATE2) \
	--tags Key=kubernetes.io/cluster/${A_EKS_CLUSTER_NAME},Value=owned

#---------------------------
# REMOVE
#---------------------------

rm_vpc_tag: data_aws
	@echo "-------------------------------------------"
	@echo " [awscli] vpc_tag"
	@echo "-------------------------------------------"
	@aws ec2 delete-tags \
	--profile $(E_PROFILE) \
	--resources $(SUBNET_ID_PUBLIC1) $(SUBNET_ID_PUBLIC2) \
	--tags Key=kubernetes.io/role/elb,Value=1
	@aws ec2 delete-tags \
	--profile $(E_PROFILE) \
	--resources $(SUBNET_ID_PUBLIC1) $(SUBNET_ID_PUBLIC2) \
	--tags Key=kubernetes.io/cluster/$(A_EKS_CLUSTER_NAME),Value=owned
	@aws ec2 delete-tags \
	--profile $(E_PROFILE) \
	--resources $(SUBNET_PRIVATE1) $(SUBNET_ID_PRIVATE2) \
	--tags Key=kubernetes.io/role/internal-elb,Value=1
	@aws ec2 delete-tags \
	--profile $(E_PROFILE) \
	--resources $(SUBNET_ID_PRIVATE1) $(SUBNET_ID_PRIVATE2) \
	--tags Key=kubernetes.io/cluster/$(A_EKS_CLUSTER_NAME),Value=owned

#---------------------------
# DATASOURCE
#---------------------------

data_aws:
	@echo "*** data_aws"
	$(eval STACK_VPC_PREFIX := BaseVpc)
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
