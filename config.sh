#!/bin/bash

RUNNERS=10
NAMESPACE=${NAMESPACE:-testproject}

which jq > /dev/null 2>&1
if [ $? -ne 0 ]; then
  sudo yum -y install jq
fi
