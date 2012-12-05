# == Class: Browser
#
#   Install Mozilla Firefox and Chrome stable (not Chromium) from Google's repository
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class gui::browsers {

  # Execute this at the first stage
  class { 'gui::browsers::apt':
    stage => 'startup',
    }

  # Google Chrome

  package{ 'google-chrome-stable':
    ensure => installed,
    require => Class ['gui::browsers::apt'],
    }

  # Mozilla Firefox
  package{ 'firefox':
    ensure => installed,
    }

}

class gui::browsers::apt {

  # The main problem with Google Chrome is that installer adds a key and source in apt-get, every
  # time. So, everything is re-triggered on every run. Anyway, this is the best way to do it - after
  # a couple of provisions, it gets quiet.
  #
  apt::source { "google-chrome":
    location => "http://dl.google.com/linux/chrome/deb/",
    release => "stable",
    repos => "main",
    key_source => "https://dl-ssl.google.com/linux/linux_signing_key.pub",
    include_src => false,
  }
}