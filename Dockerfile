FROM ruby:2.5.1-alpine3.7

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
#RUN bundle exec rake assets:precompile ## REQUIRES ENVIRONMENT


# Save commit information to image for status page to use
ARG git_commit
RUN if [ -z "$git_commit" ]; then exit 1; else : ; fi ;\
    echo -e "$git_commit" > /home/app/config/git_commit.txt


USER app
CMD ["bundle", "exec", "rails", "console"]

#EXPOSE 3000/tcp
#CMD ["bundle", "exec", "rake", "app:deploy"]  # migrate db, compile assets and post to rollbar
#CMD ["bundle", "exec", "rails", "server"]
#CMD ["bundle", "exec", "rake", "jobs:work"]
