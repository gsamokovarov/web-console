begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'socket'
require 'rake/testtask'
require 'tmpdir'
require 'securerandom'

EXPANDED_CWD = File.expand_path(File.dirname(__FILE__))

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

namespace :test do
  desc "Run tests for templates"
  task :templates => "templates:all"

  namespace :templates do
    task :all   => [:daemonize, :npm, :rackup, :mocha, :kill]
    task :serve => [:npm, :rackup]

    work_dir    = Pathname(__FILE__).dirname.join("test/templates")
    pid_file    = Pathname(Dir.tmpdir).join("web_console.#{SecureRandom.uuid}.pid")
    server_port = 29292
    rackup_opts = "-p #{server_port}"

    task :daemonize do
      rackup_opts += " -D -P #{pid_file}"
    end

    task :npm do
      Dir.chdir(work_dir) { system "npm install --silent" }
    end

    task :rackup do
      Dir.chdir(work_dir) { system "bundle exec rackup #{rackup_opts}" }
    end

    task :mocha do
      Dir.chdir(work_dir) { system "$(npm bin)/mocha-phantomjs http://localhost:#{server_port}/html/spec_runner.html" }
    end

    task :kill do
      system "kill #{File.read pid_file}"
    end
  end
end

Bundler::GemHelper.install_tasks

task default: :test
