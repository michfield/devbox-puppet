# == Definition: server::httpd::vhost
#
#   Creates virtual host structure and configuration files
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#


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

class server::vhosts ( $project_list )
{

  # $vhost_list = []

  # virtual host, for iterating
  define vhost ($http, $conf = undef, $aliases = undef)
  {
    server::vhost { "$title":
      ensure  => present,
      htdocs  => $http,
      aliases => $aliases,
      conf    => $conf,
      project_path => $server::vhosts::this_project_path,
      require => Class ['server::httpd::install'],
      notify  => Class ['server::httpd::reload'],
    }
  }

  # a project, for iterating
  define project ($path, $repo = undef, $conf = undef, $vhosts = undef)
  {
    # if there are multiple virtual hosts
    #
    if $vhosts != undef {
      # $vhost_list += $vhosts

      $this_project_path = $path
      create_resources('server::vhosts::vhost', $vhosts)
    }
    else {
      # or use project name as the only virtual host
      # by default, htdocs are in a 'htdocs' subdirectory

      notice dump($path)
      # $vhost_list += [ $title ]

      server::vhost { "$title":
        ensure  => present,
        conf    => $conf,
        project_path => $path,
        require => Class ['server::httpd::install'],
        notify  => Class ['server::httpd::reload'],
      }
    }
  }

  create_resources('server::vhosts::project', $project_list)

  # notice dump($vhost_list)
}

# This define ensures virtual host is created
define server::vhost (
  $ensure  = present,
  $owner   = 'www-data',
  $group   = 'root',
  $mode    = 2570,
  $htdocs  = 'htdocs',
  $conf    = undef,
  $project_path = undef,
  $aliases = []
  )
{

  # $lighttpd_www = '/var/www'
  $lighttpd_etc = '/etc/lighttpd'

  $docroot = "$project_path/$htdocs"

  case $ensure {
    present: {


#  server.document-root = "<%= lighttpd_www %>/<%= name %>/htdocs/"
#
      file {"${lighttpd_etc}/vhosts/${name}.conf":
        ensure  => present,
        owner   => root,
        mode    => 0644,
        content => template("server/vhost.erb"),
      }

      # Custom options file
      # If there is some addition configuration file
      #
      if $conf != undef {

         notice dump($name)
         notice dump($project_path)

        # file { "conf-custom/$name.conf":
        #   path    =>  "${lighttpd_etc}/vhosts/conf-custom/${name}.conf",
        #   content => template("server/vhost-custom.erb", "$project_path/$conf"),
        #   ensure  => present,
        #   replace => true,
        #   owner   => $owner,
        #   group   => $group,
        #   mode    => 0664,
        # }

      }
      else {
        # Or create an empty one
        #
        file { "conf-custom/$name.conf":
          path    =>  "${lighttpd_etc}/vhosts/conf-custom/${name}.conf",
          content => "# here you can put any option related to your http virtual host\n",
          ensure  => present,
          replace => true,
          owner   => $owner,
          group   => $group,
          mode    => 0664,
        }
      }

    }

    absent: {
      file {"${lighttpd_etc}/vhosts/vhost-${name}.conf":
        ensure => absent,
      }
      exec {"remove ${lighttpd_www}/${name}":
        command => "rm -rf ${lighttpd_www}/${name}",
        onlyif  => ["test -d ${lighttpd_www}/${name}", "test -n ${lighttpd_www}", "test -n ${name}"],
      }
    }

    disabled: {
      file {"${lighttpd_etc}/vhosts/vhost-${name}.conf":
        ensure => absent,
      }
    }
    default: { fail "Unknown \$ensure $ensure for $name"}
  }

}
