#!/bin/bash
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
nodeSelector="--set nodeSelector.nodegroup=default"
# Target Metrics deployment to nodeSelector 'nodegroup=default'
# If No nodes have the label 'nodegroup=default' then set this for all nodes.
fixNodeLabels(){
    label=""
    nodes=$(kubectl get nodes -o json | jq -r '.items[].metadata.labels."kubernetes.io/hostname"')
    for node in ${nodes}
    do
        test=$(kubectl get nodes $node --show-labels | grep -w "nodegroup=default")
        if [[ $test != "" ]]; then
            echo "Label Found. Not Creating labels"
            label="exists"
            break
        fi
    done

    if [[ $label != "exists" ]]; then
        for node in ${nodes}
        do
            echo "Creating Lable: nodegroup=default"
            kubectl label nodes $node nodegroup=default
        done
    fi
}

helmDeploy() {
    kubectl create namespace metrics
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    helm install -n metrics -f ${SCRIPT_DIR}/helm/prometheus-values-with-nodeselector.yaml prometheus prometheus-community/prometheus --version "15.5.3" --wait
    helm install -n metrics -f ${SCRIPT_DIR}/helm/prometheus-consul-exporter.yaml prometheus-consul-exporter prometheus-community/prometheus-consul-exporter ${nodeSelector} --wait

    helm repo add grafana https://grafana.github.io/helm-charts
    helm install -n metrics -f ${SCRIPT_DIR}/helm/grafana-values-with-lb.yaml grafana grafana/grafana ${nodeSelector} --wait
}

helmUndeploy() {
    helm uninstall -n metrics prometheus 
    helm uninstall -n metrics prometheus-consul-exporter
    helm uninstall -n metrics grafana
    kubectl delete ns metrics
}

# Connect to K8s cluster
#kubectl config use-context usw2-app1

#Cleanup if any param is given on CLI
if [[ ! -z $1 ]]; then
    echo "helmUndeploy"
    helmUndeploy
else
    echo "helmDeploy"
    fixNodeLabels
    helmDeploy
    sleep 3
    kubectl get pods
    echo 
    echo "grafana"
    echo "http://$(kubectl -n metrics get svc -l app.kubernetes.io/name=grafana -o json | jq -r '.items[].status.loadBalancer.ingress[].hostname'):3000"
fi
