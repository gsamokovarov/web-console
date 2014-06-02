module ActionDispatch
  class ExceptionWrapper
    def sources_extract
      res = [];

      exception.backtrace.each do |trace|
        file, line, _ = trace.split(":")
        line_number = line.to_i
        res << {
          code: source_fragment(file, line_number),
          file: file,
          line_number: line_number
        }
      end

      res
    end
  end
end
