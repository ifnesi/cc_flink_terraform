#!/bin/bash

source ./demo_vars
source $FILE

terraform destroy --auto-approve
echo 0 > $STATUS
