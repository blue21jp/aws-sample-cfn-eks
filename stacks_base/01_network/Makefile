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

DEPLOY_ALL =  vpc
deploy: $(DEPLOY_ALL)

RM_ALL     =  rm_vpc
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

vpc:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)Vpc$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_vpc.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	cfn-lint $(CFN_YML)
	rain deploy $(CFN_YML) $(STACK_NAME) $(RAINOPT) \
	--profile $(E_PROFILE) \
	--tags $(A_RAIN_DEFAULT_TAG) \
	--params \
	VpcCidr=$(G_VPC_CIDR),\
	SubnetCidrPublic1=$(G_SUBNET_CIDR_PUBLIC1),\
	SubnetCidrPublic2=$(G_SUBNET_CIDR_PUBLIC2),\
	SubnetCidrPrivate1=$(G_SUBNET_CIDR_PRIVATE1),\
	SubnetCidrPrivate2=$(G_SUBNET_CIDR_PRIVATE2)

#---------------------------
# REMOVE
#---------------------------

rm_vpc:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)Vpc$(E_STACK_SUFFIX))
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	rain rm $(STACK_NAME) --profile $(E_PROFILE) $(RAINOPT)
