FROM ruby:2.6.1-alpine3.7

LABEL maintainer="Robert Gauld <robert@robertgauld.co.uk>"

RUN apk add --update --no-cache \
    build-base libc-dev linux-headers \
    postgresql-dev nodejs \
    curl \
    && gem install bundler

# Create and a user called app
RUN adduser -D app
WORKDIR /home/app

# Install dependencies
COPY --chown=app:app Gemfile Gemfile.lock /home/app/
COPY --chown=app:app vendor /home/app/vendor
RUN bundle install --without development test ;\
    chmod -R og=rX /usr/local/bundle

# Copy app and make usable
COPY --chown=app:app . /home/app
RUN su app -c "mkdir -p /home/app/tmp/pids"
RUN mailgun_domain='a' contact_us_to_address='a' secret_key_base='a' \
    osm_api_name='a' osm_api_id='a' osm_api_token='a' \
    recaptcha_public_key='a' recaptcha_private_key='a' mailgun_api_key='a' \
    DATABASE_URL='postgres://a:a@a/a' REDIS_URL='redis://:a@a' \
    bundle exec rake assets:precompile


# Save commit information to image for status page to use
ARG HEROKU_SLUG_COMMIT
ARG HEROKU_SLUG_DESCRIPTION
ENV HEROKU_SLUG_COMMIT=${HEROKU_SLUG_COMMIT}
ENV HEROKU_SLUG_DESCRIPTION=${HEROKU_SLUG_DESCRIPTION}
#ARG git_commit
#RUN if [ -z "$git_commit" ]; then exit 1; else : ; fi ;\
#    echo -e "$git_commit" > /home/app/config/git_commit.txt


USER app
CMD bin/console

#EXPOSE 3000/tcp
#CMD bin/console
#CMD bin/server
#CMD bin/worker
