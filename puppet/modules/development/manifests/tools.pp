# == Class: Development::Tools
#
#   Installs some basic development tools
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class development::tools ()
{
  # It is very important for Git to be the latest version. In version prior 1.7.11 the submodules
  # had absolute path as worktree, so a whole git repository idea became unusable (path is fixed).
  # For me, this is very important, because I want to access a Git repository both from VM (Linux)
  # and from host (eg. Windows)
  #
  # http://stackoverflow.com/questions/8925564/git-submodule-absolute-worktree-path-config
  #
  # Latest Ubuntu official version is 1.7.9.5. So I must use PPA.
  #
  #

  # # Prepare the PPA in first puppet stage
  # class { 'development::tools::ppa':
  #   stage => 'startup',
  #   }

  $pkgs = [ 'build-essential', 'git', 'git-flow', 'curl' ]
  package { $pkgs:
      ensure => latest,
      # require => [ Class[ 'aptget-update' ], Class[ 'base::tools' ] ],
    }
}

# class development::tools::ppa {

#   apt::ppa { 'ppa:pdoes/ppa':
#     # this PPA contains the latest Git versions
#     # before => [ Package['git'], Package['git-flow'] ],
#     }
# }
