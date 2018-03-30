# frozen_string_literal: true

module WebConsole
  # A response object that writes content before the closing </body> tag, if
  # possible.
  #
  # The object quacks like Rack::Response.
  class Response < Struct.new(:body, :status, :headers)
    def write(content)
      raw_body = Array(body).first.to_s

      # We're done with the original body object, so make sure to close it to comply with the Rack SPEC
      body.close if body.respond_to?(:close)

      self.body =
        if position = raw_body.rindex("</body>")
          raw_body.dup.insert(position, content)
        else
          raw_body.dup << content
        end
    end

    def finish
      Rack::Response.new(body, status, headers).finish
    end
  end
end
