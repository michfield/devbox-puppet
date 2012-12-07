# == Definition: server::httpd::vhost
#
#   Creates virtual host structure and configuration files
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

hostclass :'server::vhosts', :arguments => { "project_list" => nil } do

  # vhost_list = []
  project_list = @project_list

  project_list.each do |prj_name, prj_hash|

    this_project_path = prj_hash['path']

    if prj_hash.has_key?('vhosts')

      this_vhosts = prj_hash['vhosts']

      this_vhosts.each do |vhost_name, vhost_hash|

        create_resource :'server::vhost',
          :name => vhost_name,
          :ensure => 'present',
          :htdocs => vhost_hash['http'],
          :conf => vhost_hash['conf'],
          :project_path => this_project_path,
          :aliases => vhost_hash['aliases'],
          :require => 'Class[server::httpd::install]',
          :notify => 'Class[server::httpd::reload]'

      end

    else

      create_resource :'server::vhost',
        :name => prj_name,
        :ensure => 'present',
        :conf => prj_hash['conf'],
        :project_path => this_project_path,
        :require => 'Class[server::httpd::install]',
        :notify => 'Class[server::httpd::reload]'

    end
  end
end