source 'https://rubygems.org'

gemspec name: 'web_console'

gem 'rails', github: 'rails/rails'

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter'
end

platforms :ruby do
  gem 'sqlite3'
end

group :development do
  gem 'puma'

  # Only require this one explicitly.
  gem 'pry-rails', require: false

  platforms :ruby do
    gem 'thin'
  end
end

group :test do
  gem 'rake'
  gem 'mocha', require: false
  gem 'simplecov', require: false
end
