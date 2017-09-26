#!/bin/bash

. ./config.sh

echo "Checking cluster context..."
oc whoami -c
echo
echo "Are you sure you want to run this script on the above cluster? Ctrl-C to abort. Enter to continue"
read -r a

# create projects
echo "Creating projects..."
for i in $(seq $RUNNERS); do
    oc new-project "$NAMESPACE$i"
done

echo "Waiting 15 seconds for projects to be fully created."
sleep 15

echo "Launching background run.sh processes..."
for i in $(seq $RUNNERS); do
    NAMESPACE="$NAMESPACE$i" ./run.sh 10 > "data/$NAMESPACE$i.log" 2>&1 &
done
wait

echo "Parallel runs have finished."
echo "Run reporter.sh to generate stats."
