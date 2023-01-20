#!/bin/bash

# Setup local AWS Env variables

# AWS Target Region needed by CLI.
if [[ ! -z $AWS_REGION ]]; then
    AWS_DEFAULT_REGION="${AWS_REGION}"
fi
if [[ -z $AWS_DEFAULT_REGION ]]; then
    #echo "Input AWS Target Region (ex: us-west-2):"
    #read AWS_DEFAULT_REGION
    #echo "Connecting to region $AWS_DEFAULT_REGION"
    AWS_DEFAULT_REGION="us-west-2"
fi

# get identity
aws sts get-caller-identity

# add EKS cluster to $HOME/.kube/config
aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name presto-aws-team1-eks
export team1_context=$(kubectl config current-context)
alias 'team1=kubectl config use-context $team1_context'

aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name presto-aws-team2-eks
export team2_context=$(kubectl config current-context)
alias 'team2=kubectl config use-context $team2_context'

alias 'kc=kubectl -n consul'
alias 'ka=kubectl -n api'
alias 'kp=kubectl -n payments'