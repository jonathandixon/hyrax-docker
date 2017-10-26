#!/bin/bash
#
# A helper script to wait for the rails server.
#
# Usage: wait-for.sh [redis|rails|db] [ max_try [ wait_seconds ] ]

if [[ "$VERBOSE" = "yes" ]]; then
    set -x
fi

function usage {
  echo $@
  echo "$0 [redis|rails|db] [ max_try [ wait_seconds ] ]"
  exit 1
}

service=$1
if [[ $service == "db" ]]; then
  service_command="pg_isready -h $HYRAX_DB_HOST"
elif [[ $service == "rails" ]]; then
  service_command="curl -fkI $HYRAX_URL"
elif [[ $service == "redis" ]]; then
  service_command="redis-cli -h $HYRAX_REDIS_HOST -p $HYRAX_REDIS_PORT ping"
else
  usage "$service is not a recognized service."
fi

max_try=$2
if [[ -z $max_try ]]; then
  max_try=12
else
  grep -q -E '^[0-9]+$' <<<$max_try || usage "$max_try is not a number"
fi

wait_seconds=$3
if [[ -z $wait_seconds ]]; then
  wait_seconds=5
else
  grep -q -E '^[0-9]+$' <<<$wait_seconds || usage "$wait_seconds is not a number"
fi

let i=1
until eval $service_command; do
  echo "$service is not yet available."
  if (( $i == $max_try )); then
    echo "$service is still not available; giving up!"
    exit 1
  fi
  let "i++"
  sleep $wait_seconds
done
echo "$service is available."
