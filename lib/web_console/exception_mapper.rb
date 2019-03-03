# frozen_string_literal: true

module WebConsole
  class ExceptionMapper
    def initialize(exception)
      @backtrace = exception.backtrace
      @bindings = exception.bindings
    end

    def first
      guess_the_first_application_binding || @bindings.first
    end

    def [](index)
      guess_binding_for_index(index) || @bindings[index]
    end

    private

      def guess_binding_for_index(index)
        file, line = @backtrace[index].to_s.split(":")
        line = line.to_i

        @bindings.find do |binding|
          source_location = SourceLocation.new(binding)
          source_location.path == file && source_location.lineno == line
        end
      end

      def guess_the_first_application_binding
        @bindings.find do |binding|
          source_location = SourceLocation.new(binding)
          source_location.path.to_s.start_with?(Rails.root.to_s)
        end
      end
  end
end
