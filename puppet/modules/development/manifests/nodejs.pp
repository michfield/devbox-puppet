# == Class: Development::NodeJS
#
#   Installs Node.js packages
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class development::nodejs {

    $pkgs = [ "curl", "git", "nodejs", "npm" ]
    package { $pkgs:
        ensure => "installed",
        require => Exec['apt-get update'],
    }

    exec { 'install less using npm':
        command => 'npm install less -g',
        require => Package["npm"],
    }

}