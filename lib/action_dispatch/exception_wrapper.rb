module ActionDispatch
  class ExceptionWrapper
    def extract_sources
      exception.backtrace.map do |trace|
        file, line  = trace.split(":")
        line_number = line.to_i

        {
          code: source_fragment(file, line_number) || {},
          file: file,
          line_number: line_number
        }
      end
    end
  end
end
