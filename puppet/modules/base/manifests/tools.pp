# == Class: Base::Tools
#
#   Installs some basic tools
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class base::tools ()
{
    $pkgs = [ 'htop', 'mc' ]
    package { $pkgs:
        ensure => "installed",
        # require => Exec['apt-get update'],
    }
}

