# == Class: Server::Apache
#
#   Installs full LAMP stack
#
# === Authors
#   Colovic Vladan <cvladan@gmail.com>
#

class server::php
{
    $pkgs = [ 'php5', 'php5-fpm' ]

    package { $pkgs:
        ensure => installed,
        require => Class[ 'server::httpd' ]
    }
}

# , 'php-pear'
#



#
# not used
class server::php-composer
{
    exec { 'install_composer':
        command => 'curl -s https://getcomposer.org/installer | php -- --install-dir="/bin"',
        require => Class['server::php'],
        unless => 'which composer.phar',
    }
}

# not used
class server::php-pear-packages
{
    exec { 'PEAR upgrade':
        command => 'pear upgrade PEAR',
        require => Class[ 'server::apache' ]
    }
    exec { 'PEAR autodiscover':
        command => 'pear config-set auto_discover 1',
        require => Exec[ 'PEAR upgrade' ]
    }
    exec { 'PEAR discover PHPMD':
        command => 'pear channel-discover pear.phpmd.org',
        require => Exec[ 'PEAR autodiscover' ]
    }

    exec { 'PEAR discover PHPUNIT':
        command => 'pear channel-discover pear.phpunit.de',
        require => Exec[ 'PEAR autodiscover' ]
    }

    exec { 'PEAR install phpunit':
        command => 'pear install phpunit/PHPUnit',
        require => Exec[ 'PEAR discover PHPUNIT' ]
    }
    exec { 'PEAR dbunit':
        command => 'pear install phpunit/DbUnit',
        require => Exec[ 'PEAR install phpunit' ]
    }
    exec { 'PEAR PHPUnit selenium':
        command => 'pear install phpunit/PHPUnit_Selenium',
        require => Exec[ 'PEAR install phpunit' ]
    }
    exec { 'PEAR PHPMD':
        command => 'pear install phpmd/PHP_PMD',
        require => Exec[ 'PEAR discover PHPMD' ]
    }
}
