#!/bin/sh

is_command() {
  type $1 > /dev/null 2>&1
}

find_chrome_binary() {
  for name in 'chromium' 'google-chrome' 'chromium-browser'; do
    if is_command $name; then
      echo $name
      return
    fi
  done
}

CHROME_BINARY=${CHROME_BINARY:-`find_chrome_binary`}

if is_command $CHROME_BINARY; then
  $CHROME_BINARY $@
else
  echo 'ERROR: Chrome is not found.'
  echo 'Please try "CHROME_BINARY=path/to/chrome".'
  exit 1
fi
