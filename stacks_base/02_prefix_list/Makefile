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

DEPLOY_ALL = prefix_list
deploy: $(DEPLOY_ALL)

RM_ALL     = rm_prefix_list
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

prefix_list:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)VpcPrefixList$(E_STACK_SUFFIX))
	$(eval CFN_YML      := cfn_prefix_list.yml)
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	cfn-lint $(CFN_YML)
	rain deploy $(CFN_YML) $(STACK_NAME) $(RAINOPT) \
	--profile $(E_PROFILE) \
	--tags $(A_RAIN_DEFAULT_TAG) \
	--params \
	MyGlobalIp=$(G_MY_GLOBAL_IP),\
	VpcCidr=$(G_VPC_CIDR)

#---------------------------
# REMOVE
#---------------------------

rm_prefix_list:
	$(eval STACK_NAME   := $(A_STACK_PREFIX)VpcPrefixList$(E_STACK_SUFFIX))
	@echo "-------------------------------------------"
	@echo " [rain] $(STACK_NAME)"
	@echo "-------------------------------------------"
	rain rm $(STACK_NAME) --profile $(E_PROFILE) $(RAINOPT)
