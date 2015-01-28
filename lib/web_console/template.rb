module WebConsole
  # A facade that handles template rendering and composition.
  #
  # It introduces template helpers to ease the inclusion of scripts only on
  # Rails error pages.
  class Template
    class Context < ActionView::Base
      # Execute a block only on error pages.
      #
      # The error pages are special, because they are the only pages that
      # currently require multiple bindings. We get those from exceptions.
      def only_on_error_page(*args)
        yield if @env['web_console.exception'].present?
      end

      # Render JavaScript inside a script tag and a closure.
      #
      # This one lets write JavaScript that will automatically get wrapped in a
      # script tag and enclosed in a closure, so you don't have to worry for
      # leaking globals, unless you explicitly want to.
      def render_javascript(template)
        render(template: template, layout: 'layouts/javascript')
      end

      # Render inlined string to be used inside of JavaScript code.
      #
      # The inlined string is returned as an actual JavaScript string. You
      # don't need to wrap the result yourself.
      def render_inlined_string(template)
        render(template: template, layout: 'layouts/inlined_string')
      end
    end

    # Lets you customize the default templates folder location.
    cattr_accessor :template_paths
    @@template_paths = [ File.expand_path('../templates', __FILE__) ]

    def initialize(env, session)
      @env = env
      @session = session
    end

    # Render a template (inferred from +template_paths+) as a plain string.
    def render(template)
      context = Context.new(template_paths, instance_values)
      context.render(template: template, layout: false)
    end
  end
end
