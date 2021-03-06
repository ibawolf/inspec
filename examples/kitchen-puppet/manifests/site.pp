# == Class prepare::site
#

# Install nginx from package repos
case $osfamily {
  'RedHat': {
    yumrepo { 'nginx':
      descr   => 'Nginx Repo',
      baseurl => 'http://nginx.org/packages/centos/7/x86_64',
      gpgkey  => 'http://nginx.org/keys/nginx_signing.key',
      enabled => 1,
    }

    package { 'nginx':
      ensure  => 'latest'
      require => [Yumrepo[nginx]],
    }
  }
  'Debian': {
    package { 'nginx':
      ensure => 'latest',
    }
  }
  default: {
    fail("Unsupported platform: ${osfamily}/${operatingsystem}")
  }
}

# Start the service
service { 'nginx':
  ensure => 'running',
  enable => true,
}
