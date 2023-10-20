#!/bin/bash

source ./demo_vars

if [[ $(< $STATUS) != "1" ]]; then
    echo
    echo "ERROR: You need to run ./demo_start.sh"
    echo
else
    mv mongodb.tf.disabled mongodb.tf 2>/dev/null; true
    source $FILE
    terraform plan
    terraform apply --auto-approve
    terraform output -json
fi
