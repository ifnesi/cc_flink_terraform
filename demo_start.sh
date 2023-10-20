#!/bin/bash

source ./demo_vars
echo 0 > $STATUS

if [ ! -f "$FILE" ]; then
    echo
    echo "ERROR: File '$FILE' does not exist. Please create this file (example shown below)"
    echo
    echo "------------------------------"
    cat .env_example
    echo "------------------------------"
else
    mv mongodb.tf mongodb.tf.disabled 2>/dev/null; true
    source $FILE
    terraform init
    terraform plan
    terraform apply --auto-approve
    terraform output -json
    echo 1 > $STATUS
fi
