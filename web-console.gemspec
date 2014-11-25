$:.push File.expand_path("../lib", __FILE__)

require "web_console/version"

Gem::Specification.new do |s|
  s.name     = "web-console"
  s.version  = WebConsole::VERSION
  s.authors  = ["Charlie Somerville", "Genadi Samokovarov", "Guillermo Iguaran", "Ryan Dao"]
  s.email    = ["gsamokovarov@gmail.com", "guilleiguaran@gmail.com", "daoduyducduong@gmail.com"]
  s.homepage = "https://github.com/rails/web_console"
  s.summary  = "A set of debugging tools for your Rails application."
  s.license  = 'MIT'
  s.files    = []

  s.add_dependency "web_console", WebConsole::VERSION

  s.post_install_message = <<-END
#######################################################

The `web-console` gem has been renamed to `web_console`.
Instead of installing `web-console`, you should install
`web_console`.  Please update your Gemfile and other
dependencies accordingly as the legacy `web-console`
gem will not be updated after version 3.0.

#######################################################
END
end
