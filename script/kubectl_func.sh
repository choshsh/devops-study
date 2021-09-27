#! /bin/bash

# @param NAMESPACE  namespace name
# @param RESOURCE   resource
# @param NAME       resource name
# @param REPLICAS   scale replicas count

function scale(){
  if [ "$NAME" == "-1" ] || [ "$REPLICAS" == "-1" ]; then
    echo "Parameter is invalid."
  else
    kubectl scale deployment $NAME --replicas=$REPLICAS -n $NAMESPACE
  fi
}

function get_istio(){
  if [ "$NAME" == "-1" ]; then
    kubectl get vs,dr -n $NAMESPACE
  else
    kubectl get vs, dr $NAME -n $NAMESPACE
  fi
}

function check_coredns(){
  echo "### kube-dns service"
  kubectl -n kube-system describe svc kube-dns
  echo "### kube-dns endpoints"
  kubectl -n kube-system describe endpoints kube-dns
  echo "### coredns deployment"
  kubectl -n kube-system get deploy coredns
  echo "### coredns pod"
  kubectl -n kube-system get po -l k8s-app=kube-dns -o wide
}

if [ -z "$1" ]; then
  echo "Please input function name."
else
  $1
fi

exit 0