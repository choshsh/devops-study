#! /bin/bash

helm upgrade -i loki . -f values.yaml -f values-choshsh.yaml -f values-choshsh-secret.yaml -n monitoring

exit 0
