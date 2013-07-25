# Try Rails' web-console.
#
# VERSION  0.0.1

FROM ubuntu:12.04

# Install Ruby, Bundler and dependencies for building native gems.
RUN apt-get update && apt-get install -y build-essential curl libsqlite3-dev ruby1.9.1 ruby1.9.1-dev unzip wget
RUN gem install --no-ri --no-rdoc bundler

# Download and extract the prototype ZIP distribution from GitHub.
RUN wget --no-check-certificate https://github.com/gsamokovarov/web-console/archive/master.zip && mkdir /web-console/ && unzip master.zip -d /web-console/
# Install application dependencies.
RUN bash -c 'cd /web-console/web-console-master/ && bundle install'

EXPOSE 3000

# Run the Rails built-in server from the dummy directory.
CMD bash -c 'echo "Listening on $( ip -4 addr | grep inet | grep eth0 | awk "{ print \$2 }" | cut -d/ -f1 ):3000[/console] (allow a few seconds for Rails to start)..." && cd /web-console/web-console-master/test/dummy/ && rails s'
