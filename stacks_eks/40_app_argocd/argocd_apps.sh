#!/bin/bash

ACTION=$1
JSON_DATA=./argocd_apps.json

function create_argocd_app()
{
    n_apps=$(cat ${JSON_DATA} | jq '.apps|length')

    for ((i=0; i < $n_apps; i++))
    do
	project=$(cat ${JSON_DATA} | jq -r ".apps[$i].argocd_project")
	app_name=$(cat ${JSON_DATA} | jq -r ".apps[$i].argocd_app_name")
	git_repo_url=$(cat ${JSON_DATA} | jq -r ".apps[$i].git_repository_url")
	git_repo_path=$(cat ${JSON_DATA} | jq -r ".apps[$i].git_repository_path")
	git_rev=$(cat ${JSON_DATA} | jq -r ".apps[$i].git_rev")
	cat ./k8s_argocd_app.yml \
	    | ARGOCD_NAMESPACE=${K8S_ARGOCD_NAMESPACE} \
			      ARGOCD_PROJECT=${project} \
			      APP_NAMESPACE=${K8S_APP_NAMESPACE} \
			      NAME=${A_PROJECT}-${app_name} \
			      GIT_REPO_URL=${git_repo_url} \
			      GIT_REPO_PATH=${git_repo_path} \
			      GIT_REV=${git_rev} \
			      envsubst \
	    | kubectl apply -f - \
		      --server=${EKS_ENDPOINT} \
		      --token="${EKS_TOKEN}" \
		      --certificate_authority=/tmp/ca.crt
    done
}

function create_ingress_app()
{
    n_apps=$(cat ${JSON_DATA} | jq '.apps|length')

    for ((i=0; i < $n_apps; i++))
    do
	ingress_name=$(cat ${JSON_DATA} | jq -r ".apps[$i].ingress_name")
	port=$(cat ${JSON_DATA} | jq -r ".apps[$i].service_port")
	service_name=$(cat ${JSON_DATA} | jq -r ".apps[$i].service_name")
	cat ./k8s_ingress_app.yml \
	    | ARGOCD_NAMESPACE=${K8S_ARGOCD_NAMESPACE} \
			      APP_NAMESPACE=${K8S_APP_NAMESPACE} \
			      NAME=${A_PROJECT}-${ingress_name} \
			      APP_SVC=${service_name} \
			      APP_PORT=${port} \
			      SG_IDS=${ALB_SG} \
			      envsubst \
	    | kubectl apply -f - \
		      --server=${EKS_ENDPOINT} \
		      --token="${EKS_TOKEN}" \
		      --certificate_authority=/tmp/ca.crt
    done
}

function delete_argocd_app()
{
    n_apps=$(cat ${JSON_DATA} | jq '.apps|length')

    for ((i=0; i < $n_apps; i++))
    do
	app_name=$(cat ${JSON_DATA} | jq -r ".apps[$i].argocd_app_name")
	kubectl delete application ${A_PROJECT}-${app_name} -n ${K8S_ARGOCD_NAMESPACE} \
		--server=${EKS_ENDPOINT} \
		--token="${EKS_TOKEN}" \
		--certificate_authority=/tmp/ca.crt
    done
}

function delete_ingress_app()
{
    n_apps=$(cat ${JSON_DATA} | jq '.apps|length')

    for ((i=0; i < $n_apps; i++))
    do
	ingress_name=$(cat ${JSON_DATA} | jq -r ".apps[$i].ingress_name")
	kubectl delete ingress ${A_PROJECT}-${ingress_name} -n ${K8S_APP_NAMESPACE} \
		--server=${EKS_ENDPOINT} \
		--token="${EKS_TOKEN}" \
		--certificate_authority=/tmp/ca.crt
    done
}

if [ "${ACTION}" == "create" ]; then
    create_argocd_app
    create_ingress_app
else
    delete_ingress_app
    delete_argocd_app
fi
