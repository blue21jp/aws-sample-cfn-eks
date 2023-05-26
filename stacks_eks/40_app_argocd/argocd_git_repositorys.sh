#!/bin/bash

ACTION=$1
JSON_DATA=./argocd_git_repositorys.json

function create_argocd_repository()
{
    ssh_key=$(kubectl get secret argocd-external-secret \
		      -n argocd -o json \
		      --server=${EKS_ENDPOINT} \
		      --token="${EKS_TOKEN}" \
		      --certificate_authority=/tmp/ca.crt \
		| jq -r '.data.ssh_private_key' \
	        | base64 -d)
    n_apps=$(cat ${JSON_DATA} | jq '.repositorys|length')

    for ((i=0; i < $n_apps; i++))
    do
	name=$(cat ${JSON_DATA} | jq -r ".repositorys[$i].name")
	url=$(cat ${JSON_DATA} | jq -r ".repositorys[$i].url")
	cat ./k8s_argocd_repo.yml \
	    | ARGOCD_NAMESPACE=${K8S_ARGOCD_NAMESPACE} \
	      NAME=argocd-git-${name} \
	      REPOSITORY_NAME=${name} \
	      REPOSITORY_URL=${url} \
	      SSH_PRIVATE_KEY_B64=${ssh_key} \
	      envsubst \
	    | kubectl apply -f - \
		      --server=${EKS_ENDPOINT} \
		      --token="${EKS_TOKEN}" \
		      --certificate_authority=/tmp/ca.crt
    done
}

function delete_argocd_repository()
{
    n_apps=$(cat ${JSON_DATA} | jq '.repositorys|length')

    for ((i=0; i < $n_apps; i++))
    do
	name=$(cat ${JSON_DATA} | jq -r ".repositorys[$i].name")
	kubectl delete secret argocd-git-${name} -n ${K8S_ARGOCD_NAMESPACE} \
		      --server=${EKS_ENDPOINT} \
		      --token="${EKS_TOKEN}" \
		      --certificate_authority=/tmp/ca.crt
    done
}

if [ "${ACTION}" == "create" ]; then
    create_argocd_repository
else
    delete_argocd_repository
fi
