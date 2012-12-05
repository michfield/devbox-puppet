# == Class: Timezone
#
#   Sets timezone
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class base::timezone ($timezone = 'Europe/Belgrade')
{
  package { 'tzdata':
    ensure => installed
  }

  # the '\n' in 'content' is actually very important.
  # If you omit it, the file will be recreated on every run

  file { 'timezone':
    ensure => present,
    path => '/etc/timezone',
    content => "${timezone}\n",
    notify => Exec['set-timezone'],
  }

  exec { 'set-timezone':
    command => 'dpkg-reconfigure -f noninteractive tzdata',
    require => [
      File['timezone'],
      Package['tzdata']
      ],
    subscribe => File['timezone'],
    refreshonly => true,
  }
}
