# == Class: Sublime
#
#   Installs Sublime Text 2 editor with all
#   default configuration and all the plugins (packages)
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class gui::sublime {

  # Prepare the apt stuff in first puppet stage
  class { 'gui::sublime::apt':
    stage => 'startup',
    }

  # Sublime Text 2

  package { 'sublime-text':
    ensure => installed,
    require => Class['gui::sublime::apt'],
    }

  # Copy the shortcut to the desktop
  file { '/home/vagrant/Desktop':
    ensure => directory,
    owner => 'vagrant',
    group => 'vagrant',
    before => File['Desktop/sublime-text-2.desktop'],
  }

  file { 'Desktop/sublime-text-2.desktop':
    path => '/home/vagrant/Desktop/sublime-text-2.desktop',
    source => '/usr/share/applications/sublime-text-2.desktop',
    owner => 'vagrant',
    group => 'vagrant',
    require => Package['sublime-text'],
    }

  # Another systemwide shortcut (subl), just in case
  file { "bin/subl":
    path => '/usr/local/bin/subl',
    ensure => link,
    owner => 'vagrant',
    group => 'vagrant',
    target => '/usr/bin/sublime-text-2',
    require => Package['sublime-text'],
    }

  # Basic directory structure must be created in this way,
  # because there is no equivalent of 'mkdir /p' in Puppet.

  $user_config = '/home/vagrant/.config'

  file { [
    "${user_config}/sublime-text-2",
    "${user_config}/sublime-text-2/Packages"
    ]:

    ensure => directory,
    owner => 'vagrant',
    group => 'vagrant',

    before => File['Packages/User'],
    require => File["${user_config}"],
  }

  # Directory with User settings

  # Note that Sublime Text's Package Manager will install
  # any plugin that is listed in it's configuration file

  file { "Packages/User":
    path    => "${user_config}/sublime-text-2/Packages/User",
    ensure  => directory,
    source => 'puppet:///modules/gui/User',
    recurse => true,        # enable recursive directory management
    purge   => false,       # don't purge all unmanaged junk (user can have it's custom settings)
    force   => true,        # also purge subdirs and links etc.
    owner   => "vagrant",
    group   => "vagrant",
    mode    => 0644,        # this mode will also apply to files from the source directory
                            # puppet will automatically set +x for directories
  }

  # Manually install Package Manager (Package Control)
  gui::sublime::getpackage { "Package Control":
    url => 'http://sublime.wbond.net/Package%20Control.sublime-package',
    filetype => 'zip',
    require => [
      Package['sublime-text'],
      File['Packages/User']
      ]
    }

  # And my default theme before first start
  gui::sublime::getpackage { "Theme - Phoenix":
    url => "https://github.com/netatoo/phoenix-theme/archive/master.tar.gz",
    extras => '--strip 1',
    require => [
      Package['sublime-text'],
      File['Packages/User']
      ]
    }
}

# Download & unzip some URL Zip to ST2 Packages directory
# $filetype = .tgz | .tbz | .zip
#
define gui::sublime::getpackage ($url, $extras = '', $filetype = '') {

  $package_path = "/home/vagrant/.config/sublime-text-2/Packages"

  exec { "wget ${name}":
    user    => 'vagrant',
    command => "wget -O '${name}.archive' ${url}",
    cwd     => "/var/tmp",
    creates => "/var/tmp/${name}.archive", # command will only run if the file doesn’t exist
    }

  $u = "${url}${force_extension}"

  # Choose expansion method based on file suffix

  if (($u =~ /\.tar.gz$/) or ($u =~ /\.tgz$/)) {
    $cmd = "mkdir -p '${package_path}/${name}' && tar -xzf '/var/tmp/${name}.archive' -C '${package_path}/${name}' ${extras}"
  } elsif (($u =~ /\.tar.bz2$/) or ($u =~ /\.tbz$/)) {
    $cmd = "mkdir -p '${package_path}/${name}' && tar -xjf '/var/tmp/${name}.archive' -C '${package_path}/${name}' ${extras}"
  } else {
    # assume that it's zip: ($u =~ /\.zip$/)
    $cmd = "unzip '/var/tmp/${name}.archive' -d '${package_path}/${name}' ${extras}"
  }

  exec { "unpack ${name}":
    user    => 'vagrant',
    command => $cmd,
    creates => "${package_path}/${name}",
    require => Exec["wget ${name}"],
    }
}

class gui::sublime::apt {

  # Having a lot of problems with this. And I'm not the only one
  # see: https://github.com/alister/puppet-sublimetext2/blob/master/manifests/config.pp
  #
  apt::ppa { 'ppa:webupd8team/sublime-text-2':
    # nothing
  }
}


