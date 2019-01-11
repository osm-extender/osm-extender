web: bundle exec rails server puma -b 0.0.0.0 -p $PORT
worker: bundle exec bin/delayed_job run --number-of-workers=${WORKER_CONCURRENCY:-${WEB_CONCURRENCY:-2}}
console: bundle exec rails console
release: bundle exec rake app:deploy
