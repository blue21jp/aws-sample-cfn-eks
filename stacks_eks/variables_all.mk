#
# run option default
#

ENV     := prd
RAINOPT :=-y

#
# common variavles for this stack
#

A_PROJECT      := eks
A_STACK_PREFIX := Eks

A_TAG_AUTHOR          := $(G_UNIT)
A_TAG_PROJECT         := $(A_PROJECT)
A_TAG_REPO            := $(G_GIT)
A_RAIN_DEFAULT_TAG    := author=$(A_TAG_AUTHOR),project=$(A_TAG_PROJECT),git=$(A_TAG_REPO),builder=rain

A_EKS_CLUSTER_NAME    := $(A_PROJECT)-main
A_EKS_VERSION         := 1.24

A_GIT_SSM_PARAMS_NAME := /bitbucket/ssh_key
A_GIT_SSH_KEY_PATH    := ~/.ssh/id_rsa
