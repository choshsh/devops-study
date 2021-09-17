#! /bin/bash

# @param NAMESPACE  namespace name
# @param RESOURCE   resource
# @param NAME       resource name
# @param REPLICAS   scale replicas count

# function scale(){
#   kubectl scale deployment $NAME --replicas=$REPLICAS -n $NAMESPACE
# }

function get_all(){
  kubectl get po -n $NAMESPACE
}

function get_istio(){
  kubectl get vs,dr $NAME -n $NAMESPACE
}

if [ -z "$1" ]; then
  echo "Please input function name."
else
  $1
fi

exit 0