#
# common variavles for all stacks
#

G_UNIT := blue21
G_GIT  := /sandbox

G_MY_GLOBAL_IP := $(shell curl -s inet-ip.info)

G_VPC_CIDR             := 10.0.0.0/16
G_SUBNET_CIDR_PUBLIC1  := 10.0.1.0/24
G_SUBNET_CIDR_PUBLIC2  := 10.0.2.0/24
G_SUBNET_CIDR_PRIVATE1 := 10.0.3.0/24
G_SUBNET_CIDR_PRIVATE2 := 10.0.4.0/24

G_KEYPAIR := sandbox
