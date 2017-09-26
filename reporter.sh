#!/bin/bash

. ./config.sh

echo "Average bringup/teardown numbers"
for i in $(seq $RUNNERS); do
    RUNS=$(wc -l "data/$NAMESPACE$i.log" | awk '{print $1}')
    AVGRUN=$(awk '{sum+=$3} END {print sum/NR}' "data/$NAMESPACE$i.log")
    AVGDEL=$(awk '{sum+=$4} END {print sum/NR}' "data/$NAMESPACE$i.log")
    echo "$NAMESPACE$i $RUNS $AVGRUN $AVGDEL"
done

echo "Abnormal events for each project"
for i in $(seq $RUNNERS); do
    oc -n "$NAMESPACE$i" get events -o custom-columns=TIMESTAMP:.lastTimestamp,TYPE:.type,NAME:.involvedObject.name,KIND:.involvedObject.kind,REASON:.reason,MESSAGE:.message --no-headers > "data/$NAMESPACE$i.events.log"
    echo -n "$NAMESPACE$i "; grep -v " Normal " "data/$NAMESPACE$i.events.log"
done

echo "EBS error events for each project"
for i in $(seq $RUNNERS); do
    oc -n "$NAMESPACE$i" get events -o custom-columns=TIMESTAMP:.lastTimestamp,TYPE:.type,NAME:.involvedObject.name,KIND:.involvedObject.kind,REASON:.reason,MESSAGE:.message --no-headers > "data/$NAMESPACE$i.events.log"
    echo -n "$NAMESPACE$i "; grep -v " Normal " "data/$NAMESPACE$i.events.log" | grep -ci ebs
done