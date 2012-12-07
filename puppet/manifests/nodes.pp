# == Manifest: Nodes
#
#   Executing classes based on VM's node name.
#   This manifest is called from default.pp manifest.
#
# === Requires
#   Class[aptget-update] - for apt-get update
#   Class[timezone] - for setting timezone
#
# === Notes
# - Avoided using node inheritance, because it's not really working in Puppet.
# - It's not possible to use variables in node names this is why this is so complicated
# - Couldn't use Augeas (class { 'augeas': }). It has a nasty bug that renders it unusable.
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>

# this is the only node directive
node default
{

  # Common part for all VM's

  # Basic command line tools
  class { 'base::tools': }

  # Set the same timezone for every VM
  class { 'base::timezone':
    timezone => "${base::config::hash['timezone']}"
    }

  # Set locale
  class { 'base::locale':
    default_locale => "en_US.UTF-8"
    }

  # Server
  class { 'server::httpd': }
  class { 'server::php': }
  # class { 'server::php-pear-packages': }
  # class { 'server::php-composer': }

  # Jump to semaphore / truth enforcer
  include semaphore
}

class semaphore
{
  case $hostname {

    # main php system
    #
    "${base::config::hash['nodes']['main']['host']}": {

      # GUI part
      class { 'gui::lxde': }
      class { 'gui::fonts': }

      class { 'gui::browsers':
        require => Class['gui::lxde']
        }

      class { 'gui::xrdp':
        require => Class['gui::lxde']
        }

      class { 'gui::sublime':
        require => Class['gui::lxde']
        }

      # development tools
      class { 'development::tools':
        before => Class['development::projects']
      }

      # hash contains list of projects
      class { 'development::projects':
        project_list => $base::config::hash['nodes']['main']['projects']
        }

      # This is exactly why I switched to Chef (Ruby DSL is shit)
      server::vhost { "none": ensure  => absent }

      # project can have multiple virtual hosts
      class { 'server::vhosts':
        project_list => $base::config::hash['nodes']['main']['projects'],
        require => Class['development::projects']
        }

    }

    # node.js system
    #
    "${base::config::hash['nodes']['node.js']['host']}": {

      class { 'development::nodejs': }

      }

    default:  {
      # nothing to do by default
    }
  }
}
