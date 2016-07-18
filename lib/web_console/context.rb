module WebConsole
  # A context lets you get object names related to the current session binding.
  class Context
    def initialize(binding)
      @binding = binding
    end

    # Extracts entire objects which can be called by the current session unless the objpath is present.
    # Otherwise, it extracts methods and constants of the object specified by the objpath.
    def extract(objpath)
      if objpath.present?
        local(objpath)
      else
        global
      end
    end

    private

      GLOBAL_OBJECTS = [
        'global_variables',
        'local_variables',
        'instance_variables',
        'instance_methods',
        'class_variables',
        'methods',
        'Object.constants',
        'Kernel.methods',
      ]

      def global
        GLOBAL_OBJECTS.map { |cmd| eval(cmd) }.flatten
      end

      def local(objpath)
        [
          eval("#{objpath}.methods").map { |m| "#{objpath}.#{m}" },
          eval("#{objpath}.constants").map { |c| "#{objpath}::#{c}" },
        ].flatten
      end

      def eval(cmd)
        @binding.eval(cmd) rescue []
      end
  end
end
