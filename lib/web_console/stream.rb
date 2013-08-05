require 'mutex_m'

module WebConsole
  module Stream
    extend Mutex_m

    def self.threadsafe_capture!(*streams)
      streams = [$stdout, $stderr] if streams.empty?
      synchronize do
        begin
          streams_copy = streams.collect(&:dup)
          replacement  = Tempfile.new(name)
          streams.each do |stream|
            stream.reopen(replacement)
            stream.sync = true
          end
          yield
          streams.each(&:rewind)
          replacement.read
        ensure
          replacement.close
          replacement.unlink
          streams.each_with_index do |stream, i|
            stream.reopen(streams_copy[i])
          end
        end
      end
    end
  end
end
