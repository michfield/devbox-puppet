# == Class: XRDP
#
#   Install xrdp + VNC server
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class gui::xrdp {

  package { 'xrdp':
    ensure => installed,
  }
}

