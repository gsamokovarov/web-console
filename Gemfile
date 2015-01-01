source 'https://rubygems.org'

gemspec

gem 'rails', github: 'rails/rails'

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :ruby do
  gem 'sqlite3'
end

group :test do
  gem 'rake'
  gem 'mocha', require: false
  gem 'simplecov', require: false
end
