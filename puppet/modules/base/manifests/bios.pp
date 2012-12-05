# == Class: Bios
#
#   This code gets executed absolutely first. And it is executed only once for VM
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class base::bios {

  exec { "apt update":
    command => 'apt-get update && touch /var/tmp/already-booted-once.semaphore',
    creates => '/var/tmp/already-booted-once.semaphore',
  }

  # Package is not really needed, but fixes a bug in puppetlabs-apt module
  #   https://bugs.launchpad.net/ubuntu/+source/cloud-init/+bug/1021418
  # until the pull-request gets merged:
  #   https://github.com/puppetlabs/puppetlabs-apt/pull/96
  #
  # Not needed anymore
  #
  # package { "software-properties-common":
  #   ensure => installed,
  #   require => Exec ['apt update']
  #   }
}

