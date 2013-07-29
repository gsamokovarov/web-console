# Try Rails' web-console.
#
# VERSION  0.0.1

FROM ubuntu:12.04

# Install Ruby, Bundler and dependencies for building native gems.
RUN apt-get update && apt-get install -y build-essential curl libsqlite3-dev ruby1.9.1 ruby1.9.1-dev git
RUN gem install --no-ri --no-rdoc bundler

# Clone the repository from GitHub.
RUN git clone https://github.com/gsamokovarov/web-console.git /web-console

# Install application dependencies.
RUN bash -c 'cd /web-console && bundle install'

EXPOSE 3000

# Run the docker specific rake task in a bash session! Otherwise, irb may set
# its prompt to :NULL.
CMD bash -c 'rake docker:run --rakefile /web-console/Rakefile'
