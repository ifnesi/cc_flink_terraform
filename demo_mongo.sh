#!/bin/bash
mv mongodb.tf.disabled mongodb.tf 2>/dev/null; true
terraform plan
terraform apply --auto-approve
terraform output -json