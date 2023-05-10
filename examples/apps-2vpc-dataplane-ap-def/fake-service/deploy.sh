#!/bin/bash
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

deploy() {
    # deploy eastus services
    kubectl config use-context web
    kubectl apply -f ${SCRIPT_DIR}/vpc-web/init-consul-config
    kubectl apply -f ${SCRIPT_DIR}/vpc-web/

    # deploy westus2 services
    kubectl config use-context api
    kubectl apply -f ${SCRIPT_DIR}/vpc-api/init-consul-config
    kubectl apply -f ${SCRIPT_DIR}/vpc-api

    # Output Ingress URL for fake-service
    kubectl config use-context web
    echo
    echo "http://$(kubectl -n consul get svc -l component=ingress-gateway -o json | jq -r '.items[].status.loadBalancer.ingress[].hostname'):8080/ui"
    echo
    
}

delete() {
    kubectl config use-context web
    kubectl delete -f ${SCRIPT_DIR}/vpc-web
    kubectl delete -f ${SCRIPT_DIR}/vpc-web/init-consul-config
    
    kubectl config use-context api
    kubectl delete -f ${SCRIPT_DIR}/vpc-api
    kubectl delete -f ${SCRIPT_DIR}/vpc-api/init-consul-config

}
#Cleanup if any param is given on CLI
if [[ ! -z $1 ]]; then
    echo "Deleting Services"
    delete
else
    echo "Deploying Services"
    deploy
fi