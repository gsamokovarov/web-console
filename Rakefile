begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'socket'
require 'rake/testtask'

EXPANDED_CWD = File.expand_path(File.dirname(__FILE__))

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

Bundler::GemHelper.install_tasks

task default: :test
