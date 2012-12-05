# == Default manifest
#
#   Manifest that is first executed. An entry.
#
# === Parameters
#   none
#
# === Actions
# - Process configuration files
# - Calls manifests in classes/*.pp + nodes.pp
# - Other default operations
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#
# === Notes
#   Comment format Puppetdoc / RDoc: http://docs.puppetlabs.com/guides/style_guide.html
#

# Global paths that should include all the common locations for executables
# On my system, the path was:
#   "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/opt/vagrant_ruby/bin"

Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

# Run stages (future names: boot, startup, prepare, <main>, post, polish)
#
stage { [
  'boot',
  'startup' ]:
  }

Stage['boot']
  -> Stage['startup']
  -> Stage['main']

# The very first stage
#
class { 'base::bios':
  stage => 'boot'
  }

class { 'base::config':
  stage => 'boot'
  }

# Be sure that everything apt-related
# is executed at the start of a provision
#
class { 'apt::update':
  stage => 'startup'
  }

# Needed because of apt::ppa dependency, in this wierd order
#
class { 'apt':
  disable_keys => true,   # Disable keys, in any case (I had problems with Google Chrome).
  stage => 'startup'      # Wierd apt::ppa needs this declaration
  }


# var_dump in Puppet, for debugging.
# notice dump($base::config::hash)


# Execution.
#
import 'nodes'