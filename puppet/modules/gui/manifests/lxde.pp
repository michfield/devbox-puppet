# == Class: LXDE
#
#   Install LXDE Windows Manager with minimal of anything
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class gui::lxde {

  # LXDE as default window manager
  file { "/home/vagrant/.xsession":
    content => 'exec startlxde',
  }

  package { 'lxde-core':
    ensure => installed,
  }

  # Remove annoying screensaver
  package { 'xscreensaver':
    ensure => purged,
    require => Package['lxde-core'],
  }

  # Ensure directory structure

  $profilecfg = '/home/vagrant/.config'

  file { [
    "${profilecfg}",
    "${profilecfg}/pcmanfm",
    "${profilecfg}/lxpanel",
    "${profilecfg}/pcmanfm/LXDE",
    "${profilecfg}/lxpanel/LXDE",
    "${profilecfg}/lxpanel/LXDE/panels"
    ]:

    ensure => directory,
    owner  => 'vagrant',
    group  => 'vagrant',

    before => Package['lxde-core'],
  }

  # Set desktop look - wallpaper & fonts

  # If the file doesn't exist, you should create it from my sample
  file { 'pcmanfm.conf':
    path    => "${profilecfg}/pcmanfm/LXDE/pcmanfm.conf",
    ensure  => present,
    owner   => 'vagrant',
    group   => 'vagrant',
    replace => false,
    force   => true,
    source  => 'puppet:///modules/gui/pcmanfm.conf',
    require => Package['lxde-core'],
    }

  # Later, if changes, force some of parameters
  define pcmanfm_conf($section=undef, $key=$name, $value=undef, $ensure=present) {
    file_line { "ini_config_file: [$section] $key":
      provider => 'ini',
      path     => "${gui::lxde::profilecfg}/pcmanfm/LXDE/pcmanfm.conf",
      ensure   => $ensure,
      key      => $key,
      value    => $value,
      section  => $section,
      replace  => [ "^\\s*${key}\\s*=", "^\\s*#\\s*${key}\\s*=" ],
      require  => File['pcmanfm.conf'],
      ignore   => [],
    }
  }

  pcmanfm_conf { 'wallpaper_mode' : section => 'desktop', key => 'wallpaper_mode', value => '0' }
  pcmanfm_conf { 'desktop_bg'     : section => 'desktop', key => 'desktop_bg',     value => '#023945' }
  pcmanfm_conf { 'desktop_fg'     : section => 'desktop', key => 'desktop_fg',     value => '#d6cca9' }
  pcmanfm_conf { 'desktop_shadow' : section => 'desktop', key => 'desktop_shadow', value => '#000000' }
  pcmanfm_conf { 'desktop_font'   : section => 'desktop', key => 'desktop_font',   value => 'Sans Bold 8' }

  # Icons on a desktop
  file { "desktop-items-0.conf":
    path    => "${profilecfg}/pcmanfm/LXDE/desktop-items-0.conf",
    ensure  => present,
    owner   => 'vagrant',
    group   => 'vagrant',
    replace => false,
    force   => true,
    source  => 'puppet:///modules/gui/desktop-items-0.conf',
    require => Package['lxde-core'],
    }

  # Branding images
  file { "lxde-icon.png":
    path    => '/usr/share/lxde/images/lxde-icon.png',
    ensure  => present,
    replace => true,
    source  => 'puppet:///modules/gui/lxde-icon.png',
    require => Package['lxde-core'],
    }

  file { "logout-banner.png":
    path    => '/usr/share/lxde/images/logout-banner.png',
    ensure  => present,
    replace => true,
    source  => 'puppet:///modules/gui/logout-banner.png',
    require => Package['lxde-core'],
    }

  # Taskbar
  file { "panel":
    path    => "${profilecfg}/lxpanel/LXDE/panels/panel",
    ensure  => present,
    owner   => 'vagrant',
    group   => 'vagrant',
    source  => 'puppet:///modules/gui/panel',
    require => Package['lxde-core'],
    }
}
