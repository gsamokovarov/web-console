Web Console
===========

[![Travis](https://travis-ci.org/gsamokovarov/web-console.png)](https://travis-ci.org/gsamokovarov/web-console) [![Version](https://badge.fury.io/rb/web-console.png)](http://badge.fury.io/rb/web-console)

There is no doubt that `rails console` is one of the most useful commands,
Rails has to offer. However, sometimes you can't easily access it, or maybe
you want to share it with a coworker without configuring remote desktop
server.

This is where _Web Console_ comes to the rescue. It gives you the same
`rails console` experience, right in the browser. It's not just a tool that
let's you evaluate Ruby code, there are a lot of those. It's your `IRB`
session, the way you configured it.

![web-console-demo](http://f.cl.ly/items/1b2E2C052g1v1A233N0g/web-console-demo.png)

Requirements
------------

To run _Web Console_ you need to be running _Rails 4_ and _MRI Ruby 1.9.3_ and
above. It may run on _Rubinius_ and _JRuby_, but we haven't tested those yet.

Installation
------------

To install it in your current application, add the following to your `Gemfile`.

```ruby
group :development do
  gem 'web-console', '~> 0.2.0'
end
```

After you save the `Gemfile` changes, make sure to run `bundle install` and
restart your server for the _Web Console_ to take affect.

By default, it should be available in your development environment under
`/console`. The route is not automatically mounted in a production environment
and we strongly encourage you to keep it that way.

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

Again, note that this network doesn't allow `127.0.0.1`.  If you want to access
the console, you have to do so from it's external IP or add `127.0.0.1` to the
mix.

### config.web_console.prevent_irbrc_execution

By default, the `IRB` adapter will execute the contents of the user's `.irbrc`.
Set this option to `false` if you would like to prevent that.

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

Restart your server and you are done!

Compatibility
-------------

### Pry

_Web Console_ isn't limited to just `IRB`. If you like `Pry` more than `IRB`,
we provide support for it through the [web-console-pry] project. Visit it's
[home page][web-console-pry] for more information.

### Rails 3

For _Rails 3_ support, check out [web-console-rails3].

Test Drive
----------

If you just want to try the web-console, without having to go through the
trouble of installing it, we provide a [Docker] container that does that for
you.

To try it, install [Docker] first and then run the following snippet in your shell.

```bash
sudo docker build -t gsamokovarov/web-console github.com/gsamokovarov/web-console && sudo docker run -i -t !#:3
```

  [web-console-pry]: https://github.com/gsamokovarov/web-console-pry
  [web-console-rails3]: https://github.com/gsamokovarov/web-console-rails3
  [Docker]: http://www.docker.io/
