#
# run option default
#

ENV     := prd
RAINOPT :=-y

#
# common variavles for all stacks
#

A_PROJECT          := base
A_STACK_PREFIX     := Base
A_TAG_AUTHOR       := $(G_UNIT)
A_TAG_PROJECT      := $(A_PROJECT)
A_TAG_REPO         := $(G_GIT)
A_RAIN_DEFAULT_TAG := author=$(A_TAG_AUTHOR),project=$(A_TAG_PROJECT),cfn-template=$(A_TAG_REPO),builder=rain
