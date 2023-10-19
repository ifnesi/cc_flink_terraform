#!/bin/bash
mv mongodb.tf.disabled mongodb.tf 2>/dev/null; true
terraform destroy --auto-approve