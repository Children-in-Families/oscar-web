FROM ubuntu:20.04

ENV TZ=Asia/Phnom_Penh
RUN useradd -m deployer -s /bin/bash

RUN echo "deb http://security.ubuntu.com/ubuntu bionic-security main" >> /etc/apt/sources.list
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y curl wget libssl1.0-dev libpq-dev git

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
                                        nodejs postgresql-client fonts-khmeros nginx-extras

RUN npm install -g yarn

## Install RVM
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm install 2.3.3"
RUN /bin/bash -l -c "rvm use 2.3.3"

##Install phantomjs in the app container
RUN apt-get install build-essential chrpath libssl-dev libxft-dev libfreetype6-dev libfreetype6 libfontconfig1-dev libfontconfig1 -y

## Download phantomjs
wget -O /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
# COPY phantomjs-2.1.1-linux-x86_64.tar.bz2 /tmp/
RUN tar xvjf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
RUN ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/
RUN rm /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2

##Install Phusion Passenger
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN apt-get install -y apt-transport-https ca-certificates
RUN sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'

RUN apt-get update && apt-get install -y libnginx-mod-http-passenger
RUN if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi

RUN mkdir /var/www/oscar-web
RUN chown deployer /var/www/oscar-web
WORKDIR /var/www/oscar-web

RUN chown deployer -R /var/www/oscar-web
RUN /bin/bash -l -c "gem install bundler -v 1.17.3"

RUN apt install -y ruby-dev

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 80
# Start the nginx process.
CMD ["nginx", "-g", "daemon off;"]
