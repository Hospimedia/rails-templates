#!/bin/bash

###
# Security checks
#   Allow only development and staging env to execute this script.
#
if [[ ! -z "$RAILS_ENV" ]]; then
  if [ "$RAILS_ENV" != "development" ] && [ "$RAILS_ENV" != "staging" ]; then
    echo "Forbidden script \"$(basename $0)\" in \"$RAILS_ENV\" environment"
    exit 1
  fi
else
  RAILS_ENV="development"
fi

bundle install --jobs 5 --retry 5

if [[ "$DATABASE_RESET" == "true" ]]; then
  bundle exec rake db:reset
fi

exec ${*}
