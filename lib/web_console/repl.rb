require 'pty'

module WebConsole
  # = REPL\ Process\ Wrapper
  #
  # Creates and communicates with REPL processses.
  class REPL
    # The REPL process id.
    attr_reader :pid

    def initialize(console_command = 'rails console')
      @output, @input, @pid = Dir.chdir(Rails.root) do
        PTY.spawn(console_command)
      end
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

    # Returns whether the REPL process has any pending output at the moment.
    def pending_output?
      ! IO.select([@output], [], [], 0).nil?
    end

    # Gets the pending output of the process.
    #
    # The pending output is read in an non blocking way by chunks, in the size
    # of +chunk_len+. By default, +chunk_line+ is 4096 bytes.
    #
    # Returns +nil+ immediately, if there is no pending output at the moment.
    # Otherwise, returns the pending output.
    def pending_output(chunk_len = 4096)
      # Return if the output is not immediately readable.
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
