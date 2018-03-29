#!/bin/bash

# Do rails stuff
bundle install
rake db:migrate
rake assets:precompile

# Reload unicorn
if [ -e tmp/pids/unicorn.pid ]; then
	kill -s USR2 `cat tmp/pids/unicorn.pid`
fi

# Notify rollbar
curl https://api.rollbar.com/api/1/deploy/ \
  -F access_token=$ROLLBAR_TOKEN_POST_SERVER_ITEM \
  -F environment=$RAILS_ENV \
  -F revision=`git rev-parse --verify HEAD` \
  -F local_username=`whoami` \
  -F rollbar_username=$ROLLBAR_USERNAME
