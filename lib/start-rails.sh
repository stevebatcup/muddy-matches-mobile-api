#!/bin/bash -e

echo "Bundle check || install"
bundle check || bundle install

if [[ -a /usr/src/app/tmp/pids/server.pid ]]; then
	echo "Removing stale PID file from /usr/src/app/tmp/pids/server.pid...."
	rm /usr/src/app/tmp/pids/server.pid
fi

echo "Booting rails server..."
rails s -b 0.0.0.0 -p 4050 -P /usr/src/app/tmp/pids/server.pid
