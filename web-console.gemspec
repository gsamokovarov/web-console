$:.push File.expand_path("../lib", __FILE__)

require "web_console/version"

Gem::Specification.new do |s|
  s.name     = "web-console"
  s.version  = WebConsole::VERSION
  s.authors  = ["Charlie Somerville", "Genadi Samokovarov", "Guillermo Iguaran", "Ryan Dao"]
  s.email    = ["charlie@charliesomerville.com", "gsamokovarov@gmail.com", "guilleiguaran@gmail.com", "daoduyducduong@gmail.com"]
  s.homepage = "https://github.com/rails/web-console"
  s.summary  = "A debugging tool for your Ruby on Rails applications."
  s.license  = 'MIT'

  s.files      = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.markdown", "CHANGELOG.markdown"]

  s.required_ruby_version = '>= 2.2.2'

  rails_version = ">= 5.x"

  s.add_dependency "railties",    rails_version
  s.add_dependency "activemodel", rails_version
  s.add_dependency "debug_inspector"
end
