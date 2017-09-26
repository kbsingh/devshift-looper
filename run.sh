#!/bin/bash

DEFAULT_DC=che
DEFAULT_TIMEOUT_SEC=3600
NAMESPACE=${NAMESPACE:-testproject}
ITERATIONS=${1:-10}

wait_app_availability () {
    dc_name=${DC_NAME:-${DEFAULT_DC}}
    timeout_sec=${START_TIMEOUT:-${DEFAULT_TIMEOUT_SEC}}

    available=$(oc -n $NAMESPACE get dc "${dc_name}" -o json | jq '.status.conditions[] | select(.type == "Available") | .status')

    POLLING_INTERVAL_SEC=5
    end=$((SECONDS+timeout_sec))
    while [ "${available}" != "\"True\"" ] && [ ${SECONDS} -lt ${end} ]; do
        available=$(oc -n $NAMESPACE get dc "${dc_name}" -o json | jq '.status.conditions[] | select(.type == "Available") | .status')
        sleep ${POLLING_INTERVAL_SEC}
    done
}

wait_until_all_resources_are_deleted() {
    timeout_sec=3600
    POLLING_INTERVAL_SEC=3
    resources_num=$(oc -n $NAMESPACE get all -o json 2>/dev/null | jq '.items | length')
    end=$((SECONDS+timeout_sec))
    while [ "${resources_num}" -gt "0" ] && [ ${SECONDS} -lt ${end} ]; do
        resources_num=$(oc -n $NAMESPACE get all -o json 2>/dev/null | jq '.items | length')
        #timeout_in=$((end-SECONDS))
        sleep ${POLLING_INTERVAL_SEC}
    done
}
 

wait_until_all_pods_are_stopped() {
    timeout_sec=3600
    POLLING_INTERVAL_SEC=3
    resources_num=$(oc -n $NAMESPACE get pods -o json 2>/dev/null | jq '.items | length')
    end=$((SECONDS+timeout_sec))
    while [ "${resources_num}" -gt "0" ] && [ ${SECONDS} -lt ${end} ]; do
        resources_num=$(oc -n $NAMESPACE get pods -o json 2>/dev/null | jq '.items | length')
        #timeout_in=$((end-SECONDS))
        sleep ${POLLING_INTERVAL_SEC}
    done
}

# main loop 
for runid in $(seq $ITERATIONS); do

    start=${SECONDS}
    oc -n $NAMESPACE apply -f ./helloworld.yml  >/dev/null 2>&1
    wait_app_availability 
    bringup_duration=$((SECONDS-start))

    start=${SECONDS}
    oc delete all --all -n "${NAMESPACE}" >/dev/null 2>&1
    oc delete pvc --all -n "${NAMESPACE}" >/dev/null 2>&1
    wait_until_all_resources_are_deleted
    teardown_duration=$((SECONDS-start))

    echo "$NAMESPACE $runid $bringup_duration $teardown_duration"

done
