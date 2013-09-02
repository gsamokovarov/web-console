require 'active_support/core_ext/hash/indifferent_access'

module WebConsole
  # = Colors
  #
  # Manages the creation and serialization of terminal color themes.
  #
  # Colors is a subclass of +Array+ and it stores a collection of CSS color
  # values, to be used from the client-side terminal.
  #
  # You can specify 8 or 16 colors and additional +background+ and +foreground+
  # colors. If not explicitly specified, +background+ and +foreground+ are
  # considered to be the first and the last of the given colors.
  class Colors < Array
    class << self
      # Registry of color themes mapped to a name.
      #
      # Don't manually alter the registry. Use WebConsole::Colors.register_theme
      # for adding entries.
      def themes
        @@themes ||= {}.with_indifferent_access
      end

      # Register a color theme into the color themes registry.
      #
      # Registration maps a name and Colors instance.
      #
      # If a block is given, it would be yielded with a new Colors instance to
      # populate the theme colors in.
      #
      # If a Colors instance is already instantiated it can be passed directly
      # as the second (_colors_) argument. In this case, if a block is given,
      # it won't be executed.
      def register_theme(name, colors = nil)
        themes[name] = colors || new.tap { |c| yield c }
      end

      # The default colors theme.
      def default
        self[:light]
      end

      # Shortcut for WebConsole::Colors.themes#[].
      def [](name)
        themes[name]
      end
    end

    alias :add :<<

    # Background color getter and setter.
    #
    # If called without arguments it acts like a getter. Otherwise it acts like
    # a setter.
    #
    # The default background color will be the first entry in the colors theme.
    def background(value = nil)
      @background   = value unless value.nil?
      @background ||= self.first
    end

    alias :background= :background

    # Foreground color getter and setter.
    #
    # If called without arguments it acts like a getter. Otherwise it acts like
    # a setter.
    #
    # The default foreground color will be the last entry in the colors theme.
    def foreground(value = nil)
      @foreground   = value unless value.nil?
      @foreground ||= self.last
    end

    alias :foreground= :foreground

    def to_json
      (dup << background << foreground).to_a.to_json
    end
  end

  Colors.register_theme(:tango) do |c|
    c.add '#2e3436'
    c.add '#cc0000'
    c.add '#4e9a06'
    c.add '#c4a000'
    c.add '#3465a4'
    c.add '#75507b'
    c.add '#06989a'
    c.add '#d3d7cf'

    c.add '#555753'
    c.add '#ef2929'
    c.add '#8ae234'
    c.add '#fce94f'
    c.add '#729fcf'
    c.add '#ad7fa8'
    c.add '#34e2e2'
    c.add '#eeeeec'

    c.background '#2e3436'
    c.foreground '#eeeeec'
  end

  Colors.register_theme(:xterm) do |c|
    c.add '#000000'
    c.add '#cd0000'
    c.add '#00cd00'
    c.add '#cdcd00'
    c.add '#0000ee'
    c.add '#cd00cd'
    c.add '#00cdcd'
    c.add '#e5e5e5'

    c.add '#7f7f7f'
    c.add '#ff0000'
    c.add '#00ff00'
    c.add '#ffff00'
    c.add '#5c5cff'
    c.add '#ff00ff'
    c.add '#00ffff'
    c.add '#ffffff'

    c.background '#000000'
    c.foreground '#ffffff'
  end

  Colors.register_theme(:light) do |c|
    c.add '#000000'
    c.add '#cd0000'
    c.add '#00cd00'
    c.add '#cdcd00'
    c.add '#0000ee'
    c.add '#cd00cd'
    c.add '#00cdcd'
    c.add '#e5e5e5'

    c.add '#7f7f7f'
    c.add '#ff0000'
    c.add '#00ff00'
    c.add '#ffff00'
    c.add '#5c5cff'
    c.add '#ff00ff'
    c.add '#00ffff'
    c.add '#ffffff'

    c.background '#ffffff'
    c.foreground '#000000'
  end

  Colors.register_theme(:solarized_dark) do |c|
    c.add '#073642'
    c.add '#dc322f'
    c.add '#859900'
    c.add '#b58900'
    c.add '#268bd2'
    c.add '#d33682'
    c.add '#2aa198'
    c.add '#eee8d5'

    c.add '#002b36'
    c.add '#cb4b16'
    c.add '#586e75'
    c.add '#657b83'
    c.add '#839496'
    c.add '#6c71c4'
    c.add '#93a1a1'
    c.add '#fdf6e3'

    c.background '#002b36'
    c.foreground '#657b83'
  end

  Colors.register_theme(:solarized_light) do |c|
    c.add '#073642'
    c.add '#dc322f'
    c.add '#859900'
    c.add '#b58900'
    c.add '#268bd2'
    c.add '#d33682'
    c.add '#2aa198'
    c.add '#eee8d5'

    c.add '#002b36'
    c.add '#cb4b16'
    c.add '#586e75'
    c.add '#657b83'
    c.add '#839496'
    c.add '#6c71c4'
    c.add '#93a1a1'
    c.add '#fdf6e3'

    c.background '#fdf6e3'
    c.foreground '#657b83'
  end
end
