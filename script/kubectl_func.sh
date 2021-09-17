#! /bin/bash

# @param NAMESPACE  namespace name
# @param RESOURCE   resource
# @param NAME       resource name
# @param REPLICAS   scale replicas count

# function scale(){
#   kubectl scale deployment $NAME --replicas=$REPLICAS -n $NAMESPACE
# }

function get_all(){
  kubectl get all -n default
}

# function get_istio(){
#   kubectl get vs,dr $NAME -n $NAMESPACE
# }

if [ -z "$1" ]; then
  echo "Parameter is not valid."
else
  $1
fi
