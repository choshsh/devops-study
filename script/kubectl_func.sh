#! /bin/bash

# @param NAMESPACE  namespace name
# @param RESOURCE   resource
# @param NAME       resource name
# @param REPLICAS   scale replicas count

function scale(){
  kubectl scale deployment $NAME --replicas=$REPLICAS -n $NAMESPACE
}

function get_resource(){
  if [ -z "$NAME" ]; then
    kubectl get $RESOURCE -n $NAMESPACE
  else
    kubectl get $RESOURCE $NAME -n $NAMESPACE
  fi
}

function get_istio(){
  if [ -z "$NAME" ]; then
    kubectl get vs,dr -n $NAMESPACE
  else
    kubectl get vs, dr $NAME -n $NAMESPACE
  fi
}

if [ -z "$1" ]; then
  echo "Please input function name."
else
  $1
fi

exit 0