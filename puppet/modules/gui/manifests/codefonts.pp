# == Class: Codefonts
#
#   Install coding fonts.
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class gui::codefonts {

  $pkgs = [ 'ttf-inconsolata', 'ttf-droid', 'ttf-dejavu', 'ttf-liberation', 'xfonts-terminus', 'console-terminus', 'ttf-ubuntu-font-family'  ]

  package { $pkgs:
    ensure  => installed,
    }

}
