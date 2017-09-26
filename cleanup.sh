#!/bin/bash

. ./config.sh

echo "This will delete the following projects on cluster: "
oc whoami -c
echo
for i in $(seq $RUNNERS); do
    echo "$NAMESPACE$i"
done

echo
echo "Press enter to continue. Ctrl-C to abort."
read a

for i in $(seq $RUNNERS); do
    oc delete project "$NAMESPACE$i"
done