<p align=right>
  Documentation for:
  <a href=https://github.com/rails/web-console/tree/v0.1.0>v0.1.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.2.0>v0.2.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.3.0>v0.3.0</a>
  <a href=https://github.com/rails/web-console/tree/v0.4.0>v0.4.0</a>
  <a href=https://github.com/rails/web-console/tree/v1.0.4>v1.0.4</a>
</p>

<p align=center>
  <em>Web Console is going through an overhaul. If you are looking for a stable
  version documentation, checkout the links above.</em>
</p>

Web Console [![Travis](https://travis-ci.org/rails/web-console.png)](https://travis-ci.org/rails/web-console)
===========

Web Console is a debugging console for your Rails application. It is launched whenever an error occurs or manually by using the console helper.


Requirements
------------

_Web Console_ has been tested on the following rubies.

* _MRI Ruby_ 2.0.0
* _MRI Ruby_ 1.9.3

_Web Console_ is built explicitly for _Rails 4_.

Dependencies
------------

Web Console is bundled with [`binding_of_caller`](https://github.com/banister/binding_of_caller). Because of the dependency, the gem only works on MRI Ruby at the moment.

Installation
------------

Add the `web-console` gem to your Gemfile. Be sure to use the master branch version for now:

    gem 'web-console', git: 'git://github.com/rails/web-console'


Use Cases
-------------

### Debug when an error happens

Web Console is launched automatically in the default Rails error page. It's easy to inspect the stack trace and execute Ruby code in the stack trace's bindings.

![image](https://cloud.githubusercontent.com/assets/705116/3825943/a010af92-1d5a-11e4-84c2-4ed0ba367f4e.gif)

### Inspect view and controller binding

In your view, drop `<%= console %>` anywhere to launch the console and execute code in the view binding. A helper for running the console in the controller binding is under development.

![image](https://cloud.githubusercontent.com/assets/705116/3825939/7e284de0-1d5a-11e4-9896-81465a38da76.gif)

FAQ
---

### Is there any plan to support JRuby and Rubinius?

[`binding_of_caller`](https://github.com/banister/binding_of_caller) only works on MRI Ruby at the moment. There's a plan to make Web Console work with JRuby and Rubinius, but most likely without the ability to navigate exception backtrace.

### How to get local and instance variables of a binding in the console?

The console executes Ruby code, and therefore, invoking `instance_variables` and `local_variables` will give you what you want.
