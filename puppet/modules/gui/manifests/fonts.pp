# == Class: Fonts
#
#   Installs Microsoft fonts. For them, user must click to accept EULA, so this class is little
#   different. For coding font packages, everything is standard, though.
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class gui::fonts {

  exec { "accept_license":
    command => 'echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && touch /var/tmp/mscorefonts-answers.semaphore',
    creates => '/var/tmp/mscorefonts-answers.semaphore',
    }

  package { 'ttf-mscorefonts-installer':
    ensure  => installed,
    require => Exec['accept_license']
    }

  # And coding font packages

  $pkgs = [
    'ttf-inconsolata',
    'ttf-droid',
    'ttf-dejavu',
    'ttf-liberation',
    'xfonts-terminus',
    'console-setup',
    'ttf-ubuntu-font-family'
    ]

  package { $pkgs:
    ensure  => installed,
    }
}
