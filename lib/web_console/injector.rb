# frozen_string_literal: true

module WebConsole
  # Injects content into a Rack body.
  class Injector
    def initialize(body)
      @body = "".dup

      body.each { |part| @body << part }
      body.close if body.respond_to?(:close)
    end

    def inject(content)
      if position = @body.rindex("</body>")
        [ @body.insert(position, content) ]
      else
        [ @body << content ]
      end
    end
  end
end
