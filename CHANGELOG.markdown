# CHANGELOG

## 1.0.1 (September 20, 2013

* Break the rails meta-package dependency. [[#5](https://github.com/rails/web-console/pull/5)]
* Fix activemodel load error happening on some setups. [[#4](https://github.com/rails/web-console/pull/4)]

## 1.0.0 (September 16, 2013)

* Don't throw server errors on finished slave processes.
* Add the a monokai color theme.

## 0.4.0 (September 6, 2013)

* Drop the GPL dependency of vt100.js.
* Use term.js as vt100.js replacement.
* Add config.web_console.term for using custom $TERM.
* Add config.web_console.style.colors for color theming.
* Add config.web_console.style.font for using custom fonts.
* Fix zsh repeating the first command argument on servers started inside a TMUX session.

## 0.3.0 (August 23, 2013)

* Proper VT100 emulation.
* Add config.web_console.command to allow custom programs execution.
* Add config.web_console.timeout to allow for long-polling, where available.
* Remove config.web_console.prevent_irbrc_execution.

## 0.2.0 (August 1, 2013)

* Run closest .irbrc config while initializing the IRB adapters.
* Add config.web_console.prevent_irbrc_execution option.

## 0.1.0 (July 30, 2013)

* Initial release.
