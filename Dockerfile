FROM ruby:2.7.6-slim-bullseye

RUN bash -c "set -o pipefail && apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl libcurl4-openssl-dev git libpq-dev \
  && curl -sSL https://deb.nodesource.com/setup_12.x | bash - \
  && curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y --no-install-recommends nodejs yarn \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean"

RUN apt-get update -qq && apt-get install -y postgresql-client fonts-khmeros memcached cron imagemagick
RUN mkdir /app
WORKDIR /app

RUN node -v
RUN npm -v

RUN apt-get install build-essential chrpath libssl-dev libxft-dev libfreetype6-dev libfreetype6 libfontconfig1-dev libfontconfig1 python -y
#Install phantomjs in the app container
ENV OPENSSL_CONF=/dev/null
RUN apt-get update \
      && mkdir /tmp/phantomjs \
      && curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
              | tar -xj --strip-components=1 -C /tmp/phantomjs \
      && cd /tmp/phantomjs \
      && mv bin/phantomjs /usr/local/bin/ \
      && cd \
      && apt-get purge --auto-remove -y \
          curl \
      && apt-get clean \
      && rm -rf /tmp/* /var/lib/apt/lists/*

RUN phantomjs --version

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock ./
COPY package.json yarn.lock ./

RUN gem install bundler -v 2.3.5
RUN bundle lock --add-platform aarch64-linux
RUN bundle lock --add-platform x86_64-linux
RUN bundle install --verbose --jobs 20 --retry 5
RUN gem install solargraph
RUN yarn install --check-files
RUN service memcached start

# Copy the main application.
COPY . ./

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
