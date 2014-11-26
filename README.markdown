<p align=right>
  Documentation for:
  <a href=https://github.com/rails/web-console/tree/v0.1.0>v0.1.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.2.0>v0.2.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.3.0>v0.3.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.4.0>v0.4.0</a>
  <a href=https://github.com/rails/web-console/tree/v1.0.4>v1.0.4</a>
</p>

Web Console [![Build Status](https://travis-ci.org/rails/web-console.svg?branch=master)](https://travis-ci.org/rails/web-console)
===========

_Web Console_ is a set of debugging tools for your Rails application.

**A debugging tool in the default error page.**

An interactive console is launched automatically in the default Rails error
page. It makes it easy to inspect the stack trace and execute Ruby code in the stack
trace's bindings.

_(Check out [better_errors] as a great alternative for any Rack application!)_

![image](https://cloud.githubusercontent.com/assets/705116/3825943/a010af92-1d5a-11e4-84c2-4ed0ba367f4e.gif)

**A debugging tool in your controllers and views.**

Drop `<%= console %>` anywhere in a view to launch an interactive console
session and execute code in it. Drop `console` anywhere in a controler and do
the same in the context of the controller action.

![image](https://cloud.githubusercontent.com/assets/705116/3825939/7e284de0-1d5a-11e4-9896-81465a38da76.gif)

Requirements
------------

_Web Console_ has been tested on the following rubies.

* _MRI Ruby_ 2.1.0
* _MRI Ruby_ 2.0.0
* _MRI Ruby_ 1.9.3

There is an experimental _JRuby_ 1.7 support. See Installation section for more
information.

_Web Console_ is built explicitly for _Rails 4_.

Installation
------------

To install it in your current application, add the following to your `Gemfile`.

```ruby
group :development do
  gem 'web-console', '~> 2.0'
end
```

If you are running JRuby, you can get experimental support with adding a
pre-release version of [binding_of_caller].

```ruby
group :development do
  gem 'web-console', '~> 2.0'

  gem 'binding_of_caller', '0.7.3.pre1'
end
```

After you save the `Gemfile` changes, make sure to run `bundle install` and
restart your server for the _Web Console_ to kick in.

Configuration
-------------

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

Let's say you want to share your console with `192.168.0.100`. You can do this:

```ruby
class Application < Rails::Application
  config.web_console.whitelisted_ips = %w( 127.0.0.1 192.168.0.100 )
end
```

From the example, you can guess that `config.web_console.whitelisted_ips`
accepts an array of ip addresses, provided as strings. An important thing to
note here is that, we won't push `127.0.0.1` if you manually set the option!

If you want to whitelist a whole network, you can do:

```ruby
class Application < Rails::Application
  config.web_console.whitelisted_ips = '192.168.0.0/16'
end
```

Again, note that this network doesn't allow `127.0.0.1`. If you want to access
the console, you have to do so from it's external IP or add `127.0.0.1` to the
mix.

Credits
-------

* Shoutout to [Charlie Somerville] for [better_errors]! Most of the exception
  binding code is coming straight out of the [better_errors] project.

* _Web Console_ wouldn't be possible without the work [John Mair] put in
  [binding_of_caller]. This is the technology that let us execute a console
  right where an error occurred.

* Thanks to [Charles Oliver Nutter] for all the JRuby feedback and support he
  has given us.

FAQ
---

### I'm running JRuby and there's no console on the default error page.

You would also have to run you Rails server in JRuby's interpreted mode. Enable
it with code snippet below, then start your development Rails server with
`rails server`, as usual.

```bash
export JRUBY_OPTS=-J-Djruby.compile.mode=OFF

# If you run JRuby 1.7.12 and above, you can use:
# export JRUBY_OPTS=--dev
```

### How to inspect local and instance variables?

The interactive console executes Ruby code. Invoking `instance_variables` and
`local_variables` will give you what you want.

  [better_errors]: https://github.com/charliesome/better_errors
  [binding_of_caller]: https://github.com/banister/binding_of_caller
  [Charlie Somerville]: https://github.com/charliesome
  [John Mair]: https://github.com/banister
  [Charles Oliver Nutter]: https://github.com/headius
