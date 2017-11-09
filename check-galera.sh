#!/bin/bash
#
# Very simple Galera cluster status checker. It gets the readiness status and cluster size output from galera-status and makes a simple decision.
# ready != "ON"  -> CRIT
# cluster_size == $1 -> OK
# cluster_size > $1/2 -> WARN
# cluster_size <= $1/2 -> CRIT

number='^[0-9]+$'

if ! [[ $1 =~ $number ]]; then
  echo "Improper usage: Send expected cluster size as \$1. Must be numeric."
  exit 3
fi

ready=`galera-status --batch |grep wsrep_ready|awk '{print $2}'`
cluster_size=`galera-status --batch |grep wsrep_cluster_size|awk '{print $2}'`

if [ $cluster_size -gt $1 ]; then
  echo "Cluster size is larger than expected... WTF?"
  exit 3
fi

if [ "$ready" != "ON" ]; then
  echo "CRITICAL: Galera cluster status is $ready (ON expected)"
  exit 2
fi

if [ $cluster_size -eq $1 ]; then
  echo "OK: Cluster size is $cluster_size"
  exit 0
fi

if [ $cluster_size -gt $(( $1 / 2 )) ]; then
  echo "WARNING: Cluster size is $cluster_size; $1 expected"
  exit 1
fi

if [ $cluster_size -le $(( $1 / 2 )) ]; then
  echo "CRITICAL: Cluster size is $cluster_size"
  exit 2
fi

echo "UNKNOWN ... or not implemented"
exit 3
