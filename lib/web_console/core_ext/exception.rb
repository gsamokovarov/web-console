if defined? JRUBY_VERSION
  require 'web_console/core_ext/exception/jruby'
elsif RUBY_ENGINE == 'rbx'
  require 'web_console/core_ext/exception/rubinius'
else
  require 'web_console/core_ext/exception/cruby'
end
