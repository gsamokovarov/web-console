module WebConsole
  # Detect unsupported platforms and try to help the user, if there is
  # something they can do about it.
  #
  # For example, not every JRuby mode is unsupported, we can guide the user
  # what to do to enable support for that platform.
  module UnsupportedPlatforms
    class << self
      def jruby_in_non_interpreted_mode
        return unless RUBY_PLATFORM =~ /java/

        compile_mode     = JRuby.runtime.instance_config.compile_mode
        interpreted_mode = Java::OrgJruby::RubyInstanceConfig::CompileMode::OFF

        yield if compile_mode != interpreted_mode
      end
    end

    jruby_in_non_interpreted_mode do
      warn <<-END.strip_heredoc
        JRuby needs to run in interpreted mode for Web Console support.

        To turn on interpreted mode, put -J-Djruby.compile.mode=OFF in the
        JRUBY_OPTS environment variable.
      END
    end
  end
end
