ARG RUBY_VERSION

FROM ruby:${RUBY_VERSION}-slim-buster

ARG BUNDLER_VERSION
ARG NODE_MAJOR
ARG YARN_VERSION
ARG SECRET_KEY_BASE
ARG DATABASE_URL

# Install common dependencies
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        gnupg2 \
        graphicsmagick \
        graphicsmagick-imagemagick-compat \
        libmariadb-dev \
        nginx \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

# Add NodeJS to sources list
RUN curl -sL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash -

# Add Yarn to the sources list
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# Install NodeJS and Yarn package manager
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        nodejs \
        yarn=${YARN_VERSION}-1 \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

# Configure nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf

ENV RAILS_ROOT /app/

# Configuring non-root user for the application
RUN adduser \
    --home ${RAILS_ROOT} \
    --disabled-password \
    --gecos '' \
    railsuser

WORKDIR ${RAILS_ROOT}

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

# Upgrade RubyGems and install required Bundler version
RUN gem update --system && \
    gem install bundler:${BUNDLER_VERSION}

# Setting env up
ENV RAILS_ENV='production'
ENV RACK_ENV='production'

# Installing Gem dependencies
COPY --chown=railsuser:railsuser \
    Gemfile \
    Gemfile.lock \
    ${RAILS_ROOT}

RUN bundle config --local without 'development test' &&\
    bundle install --jobs=4 --retry=3

# Copying application files
COPY --chown=railsuser:railsuser \
    . ${RAILS_ROOT}

RUN SECRET_KEY_BASE=${SECRET_KEY_BASE} DATABASE_URL=${DATABASE_URL} bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
