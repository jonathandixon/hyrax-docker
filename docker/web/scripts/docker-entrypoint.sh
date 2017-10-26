#!/bin/bash
set -e

if [[ "$VERBOSE" = "yes" ]]; then
    set -x
fi

max_try=${WAIT_MAX_TRY:-12}
wait_seconds=${WAIT_SECONDS:-5}

if [ "$1" = 'server' ]; then
    # Wait for the Database
    echo "Checking Database Connectivity"
    if ! /scripts/wait-for.sh "db" "$max_try" "$wait_seconds"; then
        echo "Unable to connect to the database."
        exit 1
    fi

    if [ -f /opt/hyrax/tmp/pids/server.pid ]; then
        echo "Stopping Rails Server and Removing PID File"
        ps aux |grep -i [r]ails | awk '{print $2}' | xargs kill -9
        rm -rf /opt/hyrax/tmp/pids/server.pid
    fi

    echo "Checking and Installing Ruby Gems"
    bundle check || bundle install

    echo "Running Database Migration"
    bundle exec rake db:migrate db:seed

    echo "Load Workflows"
    bundle exec rake hyrax:workflow:load

    echo "Initialize Default Admin Set"
    bundle exec rake hyrax:default_admin_set:create

    echo "Starting the Rails Server"
    exec bundle exec rails s -b 0.0.0.0

elif [[ $1 = sidekiq* ]]; then
    # Wait for Redis
    echo "Checking Redis Connectivity"
    if ! /scripts/wait-for.sh "redis" "$max_try" "$wait_seconds"; then
        echo "Unable to connect to the redis database."
        exit 1
    fi

    # Wait for the rails server to start.
    # The reason for this is to prevent both the worker and web container
    # from trying to download the ruby gem dependencies at the same time.
    rails_max_try=${RAILS_MAX_TRY:-40}
    rails_wait_seconds=${RAILS_WAIT_SECONDS:-15}
    if ! /scripts/wait-for.sh "rails" "$rails_max_try" "$rails_wait_seconds"; then
        echo "Unable to connect to the rails server."
        exit 1
    fi

    echo "Checking and Installing Ruby Gems"
    bundle check || bundle install

    echo "Stopping Existing sidekiq Tasks"
    ps aux |grep -i [s]idekiq | awk '{print $2}' | xargs kill -9 || true

    echo "Starting Sidekiq"
    exec bundle exec sidekiq -c 1

elif [[ "$1" = 'test' ]]; then
    echo "Checking and Installing Ruby Gems"
    bundle check || bundle install

    echo "Running Tests"
    if [[ $# -eq 2 ]] ; then
        exec bundle exec rake spec RAILS_ENV=test SPEC=$2
    else
        exec bundle exec rake spec RAILS_ENV=test CI=true
    fi
fi

exec "$@"
