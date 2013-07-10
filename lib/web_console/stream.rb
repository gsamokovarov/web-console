module WebConsole
  module Stream
    LOCK = Mutex.new

    def self.threadsafe_capture!(*streams)
      streams = [$stdout, $stderr] if streams.empty?
      LOCK.synchronize do
        begin
          streams_copy = streams.collect(&:dup)
          replacement  = Tempfile.new(name)
          streams.each { |stream| stream.reopen(replacement) }
          yield
          streams.each(&:rewind)
          replacement.read
        ensure
          replacement.unlink
          streams.each_with_index do |stream, i|
            stream.reopen(streams_copy[i])
          end
        end
      end
    end
  end
end
