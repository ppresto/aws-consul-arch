#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

# Setup local AWS Env variables
cd $SCRIPT_DIR/../quickstart-multiregion
output=$(terraform output -json)
PROJECTS=($(echo $output | jq -r '. | to_entries[] | select(.key|endswith("_projects")) | .value.value[]'))

# Authenticate to EKS
for i in ${!PROJECTS[@]}
do
    REGION=$(echo $output | jq -r ".| to_entries[] | select(.key|endswith(\"_regions\")) | .value.value.\"${PROJECTS[$i]}\"")
    EKS_CLUSTER_NAMES=$(echo $output | jq -r ".| to_entries[] | select(.key|endswith(\"_eks_cluster_names\")) | .value.value.\"${PROJECTS[$i]}\"")
    echo
    echo "${PROJECTS[$i]} - Authenticating EKS Credentials..."
    # get identity
    aws sts get-caller-identity

    # add EKS cluster to $HOME/.kube/config
    aws eks --region $REGION update-kubeconfig --name $EKS_CLUSTER_NAMES --alias "${PROJECTS[$i]}"
done

# Setup Global aliases
alias 'kc=kubectl -n consul'
alias 'kw=kubectl -n web'
alias 'ka=kubectl -n api'

# Setup Project aliases
echo
echo "EKS Environments"
echo
for i in ${!PROJECTS[@]}
do
    REGION=$(echo $output | jq -r ".| to_entries[] | select(.key|endswith(\"_regions\")) | .value.value.\"${PROJECTS[$i]}\"")
    EKS_CLUSTER_NAMES=$(echo $output | jq -r ".| to_entries[] | select(.key|endswith(\"_eks_cluster_names\")) | .value.value.\"${PROJECTS[$i]}\"")
    echo "${PROJECTS[$i]}"
    echo "  Region: ${REGION}"
    echo "  EKS_CLUSTER_NAMES: ${EKS_CLUSTER_NAMES}"
    alias $(echo ${PROJECTS[$i]})="kubectl config use-context ${PROJECTS[$i]}"
    echo "  alias: ${PROJECTS[$i]} = kubectl config use-context ${PROJECTS[$i]}"
    echo
done
echo "extra aliases"
echo "  alias: kc=kubectl -n consul"
echo "  alias 'kw=kubectl -n web"
echo "  alias 'ka=kubectl -n api"

cd ..
