# == Class: Development::Projects
#
#   Clone repositories.
#
# === Parameters
#
# - [*project_list*]
#   A hash (kind of associative array) that contains a list of repositories with their url and a
#   local path to clone to. Example:
#
# === Actions
#
# - Default private key preparation - copies private key file to a users .ssh/id_rsa.
#   It WILL overwrite any content there, so be aware of that.
# - Clone specified repositories, only if they are non-existent. Used default private key directly
#   from ~/.ssh/id_rsa
#
# === Requires
#   Class[vcsrepo] - used to clone repositories
#
# === Example
#
#   class { 'gitprojects':
#     $project_list => {
#       "one.com" => { "path" => "/one", "repo" => "ssh://user@host.com:port/repo/one.git" },
#       "two.com" => { "path" => "/two", "repo" => "ssh://user@host.com:port/repo/two.git" }
#     }
#   }
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class development::projects ( $project_list )
{
  file {'id_rsa':
    path    => "/home/vagrant/.ssh/id_rsa",
    ensure  => present,
    owner   => "vagrant",
    group   => "vagrant",
    mode    => 0600,
    replace => true,
    source  => 'puppet:///modules/development/privatekey.ppk',
  }

  # I used parameter 'identity' to specify private key because then server's host key checking is
  # skipped. Btw, server's key is not added to 'known_hosts'.

  # vhosts parameter is unused
  define project ($path, $repo, $vhosts = undef)
  {
    vcsrepo { $path:
      ensure   => present,
      provider => git,
      user     => 'vagrant',
      identity => '/home/vagrant/.ssh/id_rsa',
      source   => $repo,
      require  => File['id_rsa'],
    }

    notice dump($repo)

  /*, $root, $conf = undef

    # Symlink vhost root
    #
    # Puppet does not enforce directory tree creation in its 'File' resource type
    # So I need to have this Exec here + force=true for File.
    # At the end, functionality is the same, only uglier.
    #
    exec { "ensure $root":
      command => "mkdir -p $root",
      creates => "$root"
    }

    file { $root:
      ensure  => link,
      path    => $root,
      target  => $path,
      force   => true,
      require => [ Vcsrepo[$path], Exec["ensure $root"] ],
    }

    # notice dump($conf)

    if $conf != false {
      # notice dump($conf)
    }
*/
  }

  create_resources('development::projects::project', $project_list)
}
