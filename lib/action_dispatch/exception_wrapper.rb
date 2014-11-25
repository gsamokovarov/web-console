module ActionDispatch
  class ExceptionWrapper
    def traces
      appplication_trace_with_ids = []
      framework_trace_with_ids = []
      full_trace_with_ids = []

      if full_trace
        full_trace.each_with_index do |trace, idx|
          trace_with_id = { id: idx, trace: trace }

          appplication_trace_with_ids << trace_with_id if application_trace.include?(trace)
          framework_trace_with_ids << trace_with_id if framework_trace.include?(trace)
          full_trace_with_ids << trace_with_id
        end
      end

      {
        "Application Trace" => appplication_trace_with_ids,
        "Framework Trace" => framework_trace_with_ids,
        "Full Trace" => full_trace_with_ids
      }
    end

    def extract_sources
      exception.backtrace.map do |trace|
        file, line  = trace.split(":")
        line_number = line.to_i

        {
          code: source_fragment(file, line_number) || {},
          file: file,
          line_number: line_number
        }
      end if exception.backtrace
    end
  end
end
