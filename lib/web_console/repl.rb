require 'pty'

module WebConsole
  # = REPL\ Process\ Wrapper
  #
  # Creates and communicates with REPL processses.
  class REPL
    # The REPL process id.
    attr_reader :pid

    def initialize(command = 'bin/rails console', cwd = Rails.root)
      @output, @input, @pid = Dir.chdir(cwd) { PTY.spawn(command) }
    end

    # Sends input to the REPL process STDIN.
    #
    # Returns immediately.
    def send_input(input)
      @input.puts(input)
    end

    # Sends an interrupt signal +(SIGINT)+ to the REPL process.
    #
    # Returns immediately.
    def send_interrupt
      Process.kill(:SIGINT, @pid)
    end

    # Returns whether the REPL process has any pending output in +wait+
    # seconds.
    #
    # By default, the wait is 1 second. For immediate return, use a
    # wait of 0.
    def pending_output?(wait = 1)
      !!IO.select([@output], [], [], wait)
    end

    # Returns whether the REPL process is still alive.
    def alive?
      PTY.check(@pid).nil?
    end

    # Gets the pending output of the process.
    #
    # The pending output is read in an non blocking way by chunks, in the size
    # of +chunk_len+. By default, +chunk_len+ is 4096 bytes.
    #
    # Returns +nil+, if there is no pending output at the moment. Otherwise,
    # returns the output that hasn't been read since the last invocation.
    def pending_output(chunk_len = 4096)
      # Return if the process is no longer alive or  if the output is not readable or the process is no longer
      # running.
      return unless pending_output?

      pending = String.new
      while chunk = @output.read_nonblock(chunk_len)
        pending << chunk
      end
      pending
    rescue IO::WaitReadable
      pending
    end

    # Dispose the underlying process, by sending it termination signal
    # +(SIGTERM)+.
    def dispose
      Process.kill(:SIGTERM, @pid)
      Process.detach(@pid)
    end

    # Dispose the underlying process, by sending it kill signal +(SIGKILL)+.
    def dispose!
      Process.kill(:SIGKILL, @pid)
      Process.detach(@pid)
    end
  end
end
