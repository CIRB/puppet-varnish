define varnish::server ($vclfile='default.vcl', $ipaddress='0.0.0.0', $port=5000,
            $telnet_port='6182',
            $storage_size='1G') {

  #yumrepo {
  #  'varnish':
  #    descr    => 'varnish repository',
  #    baseurl  => 'http://repo.varnish-cache.org/redhat/el5/x86_64/',
  #    enabled  => 1,
  #    gpgcheck => 0,
  #}

  #package {
  #  'varnish':
  #    ensure  => 'installed',
  #    require => Yumrepo['varnish']
  #}

  service {
    'varnish':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => Package['varnish']
  }

  file {
    '/etc/sysconfig/varnish':
      ensure  => 'present',
      content => template('varnish/varnish.erb'),
      require => Package['varnish']
  }

  file {
    '/etc/varnish/secret':
      ensure  => 'present',
      content => 'my-dummy-password',
      require => Package['varnish']
  }

  augeas {
    'varnish':
      context => '/augeas/files/etc/sysconfig/varnish',
      changes => [
            'set VARNISH_MIN_THREADS 5',
            ],
      require => Package['varnish'],
      notify  => Service['varnish']
  }

  file {
    '/etc/varnish/sites':
      ensure  => 'directory',
      require => Package['varnish']
  }

  file {
    "/etc/varnish/$vclfile":
      ensure  => 'present',
      source  => 'puppet:///modules/varnish/varnish.vcl',
      require => File['/etc/varnish'],
      before  => Package['varnish'],
      notify  => Service['varnish'],
      replace => true
  }

  file {
    '/etc/varnish':
      ensure => 'directory'
  }

  file {
    '/etc/varnish/directors.vcl':
      ensure  => 'present',
      replace => false,
      content => '',
      require => File['/etc/varnish'],
      before  => Package['varnish']
  }

  file {
    '/etc/varnish/backends.vcl':
      ensure  => 'present',
      replace => false,
      content => '',
      require => File['/etc/varnish'],
      before  => Package['varnish']
  }

  file {
    '/etc/varnish/sites.vcl':
      ensure  => 'present',
      replace => false,
      content => '',
      require => File['/etc/varnish'],
      before  => Package['varnish']
  }

  #Varnish::Director <<||>> {
  #  notify => Service['varnish']
  #}

  #Varnish::Backend <<||>> {
  #  notify => Service['varnish']
  #}

  #Varnish::Vclconfig <<||>> {
  #  notify => Service['varnish']
  #}
}
