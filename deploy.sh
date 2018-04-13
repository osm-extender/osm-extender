#!/bin/bash

# Do rails stuff
echo -e "\n*\n* Rails Stuff\n*\n"

echo -e "\n** bundle install **"
bundle install

echo -e "\n** assets:precompile **"
rake assets:precompile

echo -e "\n** db:migrate **"
rake db:migrate


# Reload unicorn
echo -e "\n*\n* Reload Unicorn\n*\n"
if [ -e tmp/pids/unicorn.pid ]; then
	# Spawn new master
	kill -s USR2 `cat tmp/pids/unicorn.pid`
	# Close old master
	while ! [ -f tmp/pids/unicorn.pid.oldbin ];
	do
		echo "Waiting for new master to become available"
		sleep 0.25
	done
	kill -s QUIT `cat tmp/pids/unicorn.pid.oldbin`
fi


# Notify rollbar
echo -e "\n*\n* Notify Rollbar\n*\n"
curl https://api.rollbar.com/api/1/deploy/ \
  -F access_token=$ROLLBAR_TOKEN_POST_SERVER_ITEM \
  -F environment=$RAILS_ENV \
  -F revision=`git rev-parse --verify HEAD` \
  -F local_username=`whoami` \
  -F rollbar_username=$ROLLBAR_USERNAME

echo
