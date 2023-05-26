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

DEPLOY_ALL = nat
deploy: $(DEPLOY_ALL)

RM_ALL     =  rm_nat
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

nat: data_vpc data_ami
	$(eval STACK_NAME   := $(A_STACK_PREFIX)VpcNAT$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_nat.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	cfn-lint $(CFN_YML)
	rain deploy $(CFN_YML) $(STACK_NAME) $(RAINOPT) \
	--profile $(E_PROFILE) \
	--tags $(A_RAIN_DEFAULT_TAG) \
	--params \
	VpcId=$(VPC_ID),\
	SubnetId=$(SUBNET_ID),\
	RouteTableId=$(ROUTE_TABLE_ID),\
	PrefixListId=$(PREFIX_LIST_ID),\
	AmiId=$(AMI_ID),\
	KeyName=$(G_KEYPAIR)

#---------------------------
# REMOVE
#---------------------------

rm_nat:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)VpcNAT$(E_STACK_SUFFIX))
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	rain rm $(STACK_NAME) --profile $(E_PROFILE) $(RAINOPT)

#---------------------------
# DATASOURCE
#---------------------------

data_vpc:
	@echo "*** data_vpc"
	$(eval VPC_ID := \
		$(shell aws ec2 describe-vpcs \
			--profile $(E_PROFILE) \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(A_STACK_PREFIX)Vpc$(E_STACK_SUFFIX)' \
			--query 'Vpcs[].[VpcId]' \
			--output text))
	$(eval SUBNET_ID := \
		$(shell aws ec2 describe-subnets \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(A_STACK_PREFIX)Vpc$(E_STACK_SUFFIX)-Public1' \
			--profile $(E_PROFILE) \
			--query 'Subnets[].[SubnetId]' \
			--output text))
	$(eval ROUTE_TABLE_ID := \
		$(shell aws ec2 describe-route-tables \
			--filters 'Name=tag-key,Values=Name' \
			'Name=tag-value,Values=$(A_STACK_PREFIX)Vpc$(E_STACK_SUFFIX)-Private' \
			--profile $(E_PROFILE) \
			--query 'RouteTables[].[RouteTableId]' \
			--output text))
	$(eval PREFIX_LIST_ID := \
		$(shell aws ec2 describe-managed-prefix-lists \
			--filters 'Name=prefix-list-name,Values=$(A_STACK_PREFIX)VpcPrefixList$(E_STACK_SUFFIX)-vpc-internal' \
			--profile $(E_PROFILE) \
			--query 'PrefixLists[].[PrefixListId]' \
			--output text))

data_ami:
	@echo "*** data_ami"
	$(eval AMI_ID := \
		$(shell aws ec2 describe-images \
			--profile $(E_PROFILE) \
			--owners amazon \
			--filters "Name=name,Values=amzn-ami-vpc-nat-*" \
			--query 'sort_by(Images[].{id:ImageId,date:CreationDate},&date)' \
			--output text | tail -1 | cut -f2))
