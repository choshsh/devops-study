#! /bin/bash

# @param NAMESPACE  namespace name
# @param RESOURCE   resource
# @param NAME       resource name
# @param REPLICAS   scale replicas count

function scale(){
  if [ -z "$NAME" ] || [ -z "$REPLICAS" ]; then
    echo "Parameter is invalid."
    exit 1
  else
    kubectl -n $NAMESPACE scale deployment $NAME --replicas=$REPLICAS
  fi
}

function get_istio(){
  kubectl -n $NAMESPACE get vs,dr $NAME
}

function check_coredns(){
  printf "\n### kube-dns service\n"
  kubectl -n kube-system describe svc kube-dns

  printf "\n### kube-dns endpoints\n"
  kubectl -n kube-system describe endpoints kube-dns
  
  printf "\n### coredns deployment\n"
  kubectl -n kube-system get deploy coredns

  printf "\n### coredns pod\n"
  kubectl -n kube-system get po -l k8s-app=kube-dns -o wide
}

if [ -z "$1" ]; then
  echo "Please input function name."
  exit 1
else
  $1
  exit 0
fi
