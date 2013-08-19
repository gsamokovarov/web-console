$:.push File.expand_path("../lib", __FILE__)

require "web_console/version"

Gem::Specification.new do |s|
  s.name     = "web-console"
  s.version  = WebConsole::VERSION
  s.authors  = ["Genadi Samokovarov", "Guillermo Iguaran"]
  s.email    = ["gsamokovarov@gmail.com", "guilleiguaran@gmail.com"]
  s.homepage = "https://github.com/gsamokovarov/web-console"
  s.summary  = "Rails Console on the Browser."
  s.license  = 'MIT'

  s.files      = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_development_dependency "sqlite3"
end
