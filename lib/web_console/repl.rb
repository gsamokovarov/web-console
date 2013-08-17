require 'pty'
require 'io/console'

module WebConsole
  # = REPL\ Process\ Wrapper
  #
  # Creates and communicates with REPL processses.
  #
  # The communication happens through an input with attached psuedo-terminal.
  # All of the communication is done in asynchrouns way, meaning that when you
  # send input to the process, you have get the output by polling for it.
  class REPL
    # The REPL process id.
    attr_reader :pid

    def initialize(command = File.join(Rails.root, 'bin/rails console'))
      @output, @input, @pid = PTY.spawn(command)
    end

    # Sends input to the REPL process STDIN.
    #
    # Returns immediately.
    def send_input(input)
      input.each_char { |char| @input.putc(char) }
    end

    # Returns whether the REPL process has any pending output in +wait+
    # seconds.
    #
    # By default, the +wait+ is 0 second, e.g. the response is immediate.
    def pending_output?(wait = 0)
      !!IO.select([@output], [], [], wait)
    end

    # Gets the pending output of the process.
    #
    # The pending output is read in an non blocking way by chunks, in the size
    # of +chunk_len+. By default, +chunk_len+ is 4096 bytes.
    #
    # Returns +nil+, if there is no pending output at the moment. Otherwise,
    # returns the output that hasn't been read since the last invocation.
    #
    # Raises Errno:EIO on closed output stream. This can happen if the
    # underlying process exits.
    def pending_output(chunk_len = 4096)
      # Returns nil if there is no pending output.
      return unless pending_output?

      pending = String.new
      while chunk = @output.read_nonblock(chunk_len)
        pending << chunk
      end
      pending
    rescue IO::WaitReadable
      pending
    end

    # Dispose the underlying process, sending +SIGTERM+.
    #
    # After the process is disposed, it is detached from the parent to prevent
    # zombies.
    #
    # If the process is already disposed an Errno::ESRCH will be raised and
    # handled internally. If you want to handle Errno::ESRCH yourself, pass
    # +{raise: true}+ as options.
    #
    # Returns a thread, which can be used to wait for the process termination.
    def dispose(options = {})
      dispose_with(:SIGTERM, options)
    end

    # Dispose the underlying process, sending +SIGKILL+.
    #
    # After the process is disposed, it is detached from the parent to prevent
    # zombies.
    #
    # If the process is already disposed an Errno::ESRCH will be raised and
    # handled internally. If you want to handle Errno::ESRCH yourself, pass
    # +{raise: true}+ as options.
    #
    # Returns a thread, which can be used to wait for the process termination.
    def dispose!(options = {})
      dispose_with(:SIGKILL, options)
    end

    private

      def dispose_with(signal, options = {})
        Process.kill(signal, @pid)
        Process.detach(@pid)
      rescue Errno::ESRCH
        raise if options[:raise]
      end
  end
end
