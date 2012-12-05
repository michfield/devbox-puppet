# == Class: Locale
#
#   Sets system locale
#
# === Parameters
#
# - [*default*]
#   Default locale code
#
# - [*available*]
#   Array of desired available locales on system
#
# === Actions
#
# - Creates couple of needed files, and executes two small commands.
#
# === Example
#
#   class { 'locales':
#     default => "en_US.UTF-8",
#     available => ["en_US.UTF-8 UTF-8", "en_GB.UTF-8 UTF-8"]
#   }
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#   Eivind Uggedal <eivind@uggedal.com> (https://github.com/uggedal/puppet-module-locales)
#

class base::locale (
    $default_locale = "en_US.UTF-8",
    $available = ["en_US.UTF-8 UTF-8"] )
  {

  package { 'locales':
    ensure => present,
  }

  # create couple of files

  file { '/etc/locale.gen':
    content => inline_template('<%= available.join("\n") + "\n" %>'),
  }

  file { '/etc/default/locale':
    content => inline_template('LANG=<%= default_locale + "\n" %>'),
  }

  # Whenever any of these files changes,
  # execute `locale-gen` and `update-locale` commands

  exec { "locale-gen":
    subscribe => [File['/etc/locale.gen'], File['/etc/default/locale']],
    refreshonly => true,
  }

  exec { "update-locale":
    subscribe => [File['/etc/locale.gen'], File['/etc/default/locale']],
    refreshonly => true,
  }

  # New syntax of chaining resources - sometime easier to read than before / require
  # http://docs.puppetlabs.com/guides/language_guide.html#chaining-resources

  Package['locales']
    -> File['/etc/locale.gen']
    -> File['/etc/default/locale']
    -> Exec['locale-gen']
    -> Exec['update-locale']
}


