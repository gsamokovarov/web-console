begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'socket'
require 'active_support/core_ext/string/strip'
require 'rake/testtask'

EXPANDED_CWD = File.expand_path(File.dirname(__FILE__))

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

# Just ignore this if rake is not runned from the current directory, as is the
# case with docker's container. BUNDLE_GEMFILE won't do for our case, since the
# Gemfile references gemspec.
Bundler::GemHelper.install_tasks if defined? Bundler::GemHelper

namespace :docker do
  task :sync do
    Dir.chdir(EXPANDED_CWD) do
      sh 'git fetch && git reset --hard origin/master', verbose: false
    end
  end

  task run: :sync do
    # Generally, the first ipv4 private address is how we would access the
    # docker container from the current machine.
    container_ip = Socket.ip_address_list.find(&:ipv4_private?).ip_address

    puts <<-NOTICE.strip_heredoc
      Go to http://#{container_ip}:3000/console to preview web-console.
      If it's not showing, please give a few seconds for the server to start.
    NOTICE

    Dir.chdir("#{EXPANDED_CWD}/test/dummy") do
      sh 'rails server', verbose: false
    end
  end
end

task default: :test
