source 'https://rubygems.org'

gemspec

gem 'rails', github: 'rails/rails'
gem 'arel', github: 'rails/arel'
gem 'rack', github: 'rack/rack'

platforms :jruby do
  gem 'binding_of_caller', '0.7.3.pre1'
end

group :test do
  gem 'rake'
  gem 'mocha', require: false
  gem 'simplecov', require: false
end
