<p align=right>
  Documentation for:
  <a href=https://github.com/rails/web-console/tree/v0.1.0>v0.1.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.2.0>v0.2.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.3.0>v0.3.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.4.0>v0.4.0</a>
  <a href=https://github.com/rails/web-console/tree/v1.0.4>v1.0.4</a>
</p>

<p align=center>
  <em>Web Console is currently in beta for <code>2.0.0</code>. If you're searching for a stable
  version documentation, checkout the links above.</em>
</p>

Web Console [![Travis](https://travis-ci.org/rails/web-console.png)](https://travis-ci.org/rails/web-console)
===========

_Web Console_ is a set of debugging tools for your Rails application.

**A debugging tool in the default error page.**

An interactive console is launched automatically in the default Rails error
page. It makes it easy to inspect the stack trace and execute Ruby code in the stack
trace's bindings.

_(Check out [better_errors] as a great alternative for any Rack application!)_

![image](https://cloud.githubusercontent.com/assets/705116/3825943/a010af92-1d5a-11e4-84c2-4ed0ba367f4e.gif)

**A debugging tool in your views.**

Drop `<%= console %>` anywhere in a view to launch an interactive console session and
execute code in it.

![image](https://cloud.githubusercontent.com/assets/705116/3825939/7e284de0-1d5a-11e4-9896-81465a38da76.gif)

**A [VT100] compatible terminal.**

Running `rails console` is quite handy. Sometimes, though, you can't easily
access it, or maybe you want to easily share your session with a friend without
configuring a remote desktop server.

_Web Console_ can help you by running `rails console` _(or any other
commandline app)_, in full featured terminal right in the browser.

![demo](http://f.cl.ly/items/3N3K412T381u2w360F2M/Screen%20Shot%202013-09-06%20at%208.24.57%20PM.png)

Requirements
------------

_Web Console_ has been tested on the following rubies.

* _MRI Ruby_ 2.1.0
* _MRI Ruby_ 2.0.0
* _MRI Ruby_ 1.9.3

There is an experimental _JRuby_ 1.7 support. See Installation section for more
information.

_Rubunius_ in 1.9 mode may work, but it hasn't been explicitly tested.

_Web Console_ is built explicitly for _Rails 4_. Check out the
[web-console-rails3] project for a _Rails 3_ compatible build.

Installation
------------

To install it in your current application, add the following to your `Gemfile`.

```ruby
group :development do
  gem 'web-console', '2.0.0.beta2'
end
```

For _JRuby_ support, you need to add an unreleased version of
`binding_of_caller`.

```ruby
group :development do
  gem 'web-console', '2.0.0.beta2'
  gem 'binding_of_caller', github: 'banister/binding_of_caller'
end
```

After you save the `Gemfile` changes, make sure to run `bundle install` and
restart your server for the _Web Console_ to kick in.

Configuration
-------------

### config.web_console.automount

If you want to automatically mount `WebConsole::Engine`, you can set this
option to `true`. The terminal will be mounted at the location pointed by
`config.web_console.default_mount_path`.

Defaults to `false`.

_(Note that, this option used to default to `true` in the 1.0 days. We no
longer automatically mount the web terminal at `/console`.)_.

### config.web_console.default_mount_path

By default, the console will be mounted on `/console`.

_(This happens only in the development and test environments!)_.

Say you want to mount the console to `/debug`, so you can more easily remember
where to go, when your application needs debugging.

```ruby
class Application < Rails::Application
  config.web_console.default_mount_path = '/debug'
end
```

> Today we have learned in the agony of war that great power involves great
> responsibility.
>
> -- <cite>Franklin D. Roosevelt</cite>

_Web Console_ is a powerful tool. It allows you to execute arbitrary code on
the server, so you should be very careful, who you give access to it.

### config.web_console.whitelisted_ips

By default, only requests coming from `127.0.0.1` are allowed.

`config.web_console.whitelisted_ips` lets you control which IP's have access to
the console.

Let's say you want to share your console with just that one roommate, you like
and his/her IP is `192.168.0.100`.

```ruby
class Application < Rails::Application
  config.web_console.whitelisted_ips = %w( 127.0.0.1 192.168.0.100 )
end
```

From the example, you can guess that `config.web_console.whitelisted_ips`
accepts an array of ip addresses, provided as strings. An important thing to
note here is that, we won't push `127.0.0.1` if you manually set the option!

Now let's assume you like all of your roommates. Instead of enumerating their
IP's, you can whitelist the whole private network. Now every time their IP's
change, you'll have them covered.

```ruby
class Application < Rails::Application
  config.web_console.whitelisted_ips = '192.168.0.0/16'
end
```

You can see that `config.web_console.whitelisted_ips` accepts plains strings
too. More than that, they can cover whole networks.

Again, note that this network doesn't allow `127.0.0.1`. If you want to access
the console, you have to do so from it's external IP or add `127.0.0.1` to the
mix.

### config.web_console.command

By default, _Web Console_ will run `Rails.root.join('bin/rails console)` to
spawn you a fresh Rails console. If the relative `bin/rails` doesn't exist,
`rails console` will be run instead.

One of the advantages of being a [VT100] emulator is that _Web Console_ can run
most of your terminal applications.

Let say _(for some reason)_ you can't run SSH on your server machine. You can
run [`login`][login] instead to let users sign into the host system.

```ruby
class Application < Rails::Application
  # You have to run /bin/login as root. That should worry you and you may work
  # around it by running ssh connecting to the same machine.
  config.web_console.command = 'sudo /bin/login'
end
```

_Poor man's solution to SSH._ ![boom](http://f.cl.ly/items/3n2h0p1w0B261u2d201b/boom.png)

**If you ever decide to use _Web Console_ that way, use SSL to encrypt the
traffic, otherwise all the input (including the negotiated username and
password) can be easily sniffed!**

### config.web_console.term

By default, the _Web Console_ terminal will report itself as `xterm-color`. You
can override this option to change it with this option.

### config.web_console.timeout

You may have noticed that _Web Console_ client sends a lot of requests to the
server. And by a lot, we really mean, **a lot** _(every few milliseconds)_.
We do this since we can't reliably predict when the output of your command
execution will come available, so we poll for it.

This option control how much will the server wait on the process output pipe
for input, before signalling the client to try again.

Maybe some day Web Sockets or SSE can be used for more efficient communication.
Until that day, you can use long-polling. To enable it, use [Puma] as your
development server and add the following to your configuration.

```ruby
class Application < Rails::Application
  # You have to explicitly enable the concurrency, as in development mode,
  # the falsy config.cache_classes implies no concurrency support.
  #
  # The concurrency is enabled by removing the Rack::Lock middleware, which
  # wraps each request in a mutex, effectively making the request handling
  # synchronous.
  config.allow_concurrency = true

  # For long-polling, 45 seconds timeout for the development server seems
  # reasonable. You may want to experiment with the value.
  config.web_console.timeout = 45.seconds
end
```

Styling
-------

If you would like to style the terminal a bit different than the default
appearance, you can do so with the following options.

### config.web_console.style.colors

_Web Console_ supports up to 256 color themes, though most of the common
terminal themes are usually 16 colors.

The default color theme is a white-on-black theme called `light`. For
different appearance you may want to experiment with the other included color
themes.

- `monokai` _the default Sublime Text colors_
- `solarized_dark` _light version of the common solarized colors_
- `solarized_light` _dark version of the common solarized colors_
- `tango` _theme based on the tango colors_
- `xterm` _the standard xterm theme_

If you would like to use a custom theme, you may do so with the following
syntax.

```ruby
class Application < Rails::Application
  # First, you have to define and register your custom color theme. Each color
  # theme is mapped to a name.
  WebConsole::Colors.register_theme(:custom) do |c|
    # The most common color themes are the 16 colors one. They are built from 3
    # parts.

    # 8 darker colors.
    c.add '#000000'
    c.add '#cd0000'
    c.add '#00cd00'
    c.add '#cdcd00'
    c.add '#0000ee'
    c.add '#cd00cd'
    c.add '#00cdcd'
    c.add '#e5e5e5'

    # 8 lighter colors.
    c.add '#7f7f7f'
    c.add '#ff0000'
    c.add '#00ff00'
    c.add '#ffff00'
    c.add '#5c5cff'
    c.add '#ff00ff'
    c.add '#00ffff'
    c.add '#ffffff'

    # Background and foreground colors.
    c.background '#ffffff'
    c.foreground '#000000'
  end

  # Now you have to tell Web Console to actually use it.
  config.web_console.style.colors = :custom
end
```

### config.web_console.style.font

You may also change the font, which is following the CSS font property syntax.
By default it is `large DejaVu Sans Mono, Liberation Mono, monospace`.

Shout-out
---------

Great thanks to [Charlie Somerville] for [better_errors]! Most of the exception
binding code is coming straight out of the [better_errors] project.

FAQ
---

### I'm running JRuby and /console doesn't load.

**TL;DR** Give it a bit of time, it will load.

While spawning processes is relatively cheap on _MRI_, this is not the case in
_JRuby_. Spawning another process is slow. Spawning another **JRuby** process
is even slower. Read more about the problem at the _JRuby_ [wiki].

### I'm running JRuby and there's no console on the default error page.

_JRuby_ support in the default error page requires the latest is experimental
and requires an unreleased version of `web-console` and `binding_of_caller`.

To try it out, put this in your Gemfile.

```ruby
group :development do
  gem 'web-console', github: 'rails/web-console'
  gem 'binding_of_caller', github: 'banister/binding_of_caller'
end
```

You would also have to run you Rails server in JRuby's interpreted mode. Enable
it with code snippet below, then start your development Rails server with
`rails server`, as usual.

```bash
export JRUBY_OPTS=-J-Djruby.compile.mode=OFF

# If you run JRuby 1.7.12 and above, you can use:
# export JRUBY_OPTS=--dev
```

_(Please, note that we don't guarantee master to be stable and we
will appreciate any issue reports!)_

### Changing the colors is broken.

Some of the style sheets may be cached on the file system. Run
`rake tmp:cache:clear` to clear those up.

### How to view local and instance variables in an interactive console?

The interactive console executes Ruby code. Invoking `instance_variables` and
`local_variables` will give you what you want.

  [Docker]: http://www.docker.io/
  [Puma]: http://puma.io/
  [VT100]: http://en.wikipedia.org/wiki/VT100
  [login]: http://linux.die.net/man/1/login
  [web-console-rails3]: https://github.com/gsamokovarov/web-console-rails3
  [wiki]: https://github.com/jruby/jruby/wiki/Improving-startup-time#avoid-spawning-sub-rubies
  [better_errors]: https://github.com/charliesome/better_errors
  [Charlie Somerville]: https://github.com/charliesome
