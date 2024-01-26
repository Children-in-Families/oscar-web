FROM ruby:2.3.7

RUN echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list
RUN apt-get update -q && \
    apt-get install -qy procps curl ca-certificates gnupg2 build-essential --no-install-recommends && apt-get clean
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash -
RUN curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client fonts-khmeros memcached cron
RUN mkdir /app
WORKDIR /app

RUN node -v
RUN npm -v

#Install phantomjs in the app container
RUN apt-get install build-essential chrpath libssl-dev libxft-dev libfreetype6-dev libfreetype6 libfontconfig1-dev libfontconfig1 -y
RUN apt-get update \
      && apt-get install -y --no-install-recommends \
          curl \
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

RUN gem install bundler -v 1.17.3
RUN bundle install --verbose --jobs 20 --retry 5
RUN gem install solargraph -v 0.39.17 --force
RUN npm install -g yarn
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
