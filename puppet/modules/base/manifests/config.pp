# == Class: Config
#
#   Some basic configuration directives. The most important part is loading of the main config file
#   and make it global hash variable.
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class base::config {

  # Load Puppet configs in YAML (JSON) format
  # Returns is a hash - tree-like object that follows the JSON hierachy
  # And merge with user's specific configuration
  #
  # There is no error checking. It's stupid in Puppet, and Vagrant already accepted these files
  #

  $hash = deep_merge( loadyaml('/vagrant/vagrantfile.defaults.yaml' ),
                      loadyaml('/vagrant/vagrantfile.config.yaml'   ))
}
