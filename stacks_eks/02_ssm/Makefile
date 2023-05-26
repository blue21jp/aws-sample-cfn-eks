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

DEPLOY_ALL =  ssm
deploy: $(DEPLOY_ALL)

RM_ALL     =  rm_ssm
remove: $(RM_ALL)

#---------------------------
# DEPLOY
#---------------------------

ssm:
	@echo "-------------------------------------------"
	@echo " [awscli] ssm"
	@echo "-------------------------------------------"
	@aws ssm put-parameter \
	--profile $(E_PROFILE) \
	--name $(A_GIT_SSM_PARAMS_NAME) \
	--value "`cat $(A_GIT_SSH_KEY_PATH)|base64 -w0`" \
	--type SecureString \
	--tags Key=author,Value=$(A_TAG_AUTHOR) \
	Key=project,Value=$(A_PROJECT) \
	Key=git,Value=$(A_TAG_REPO) \
	Key=builder,Value=awscli

#---------------------------
# REMOVE
#---------------------------

rm_ssm:
	@echo "-------------------------------------------"
	@echo " [awscli] ssm"
	@echo "-------------------------------------------"
	@aws ssm delete-parameter \
	--profile $(E_PROFILE) \
	--name $(A_GIT_SSM_PARAMS_NAME)
