FROM ubuntu:12.04

# Install Ruby, Bundler and dependencies for building native gems.
RUN apt-get update && apt-get install -y build-essential curl libsqlite3-dev ruby1.9.1 ruby1.9.1-dev git
RUN gem install --no-ri --no-rdoc bundler

# Clone the repository from GitHub.
RUN git clone https://github.com/rails/web-console.git /web-console

# Install application dependencies.
RUN bash -c 'cd /web-console && bundle install'

EXPOSE 3000

# Note that if you run the container, without allocating a tty and attaching
# the STDIN, irb will use :NULL as a :PROMPT_MODE.
CMD rake docker:run --rakefile /web-console/Rakefile
