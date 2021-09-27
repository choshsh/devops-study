#! /bin/bash

# @param NAMESPACE  namespace name
# @param RESOURCE   resource
# @param NAME       resource name
# @param REPLICAS   scale replicas count

function scale(){
  if [ "$NAME" == "-1" ] || [ "$REPLICAS" == "-1" ]; then
    echo "Parameter is invalid."
  else
    kubectl -n $NAMESPACE get deployment $NAME
    kubectl -n $NAMESPACE scale deployment $NAME --replicas=$REPLICAS
    kubectl -n $NAMESPACE get deployment $NAME
  fi
}

function get_istio(){
  if [ "$NAME" == "-1" ]; then
    kubectl -n $NAMESPACE get vs,dr
  else
    kubectl -n $NAMESPACE get vs, dr $NAME
  fi
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
else
  $1
fi

exit 0