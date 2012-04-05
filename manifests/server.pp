class varnish::server ($vclfile='default.vcl', $ipaddress='127.0.0.1', $port=5000,
            $telnet_port='6182',
            $storage_size='1G') {

  yumrepo {
    'varnish':
      descr    => 'varnish repository',
      baseurl  => 'http://repo.varnish-cache.org/redhat/el5/x86_64/',
      enabled  => 1,
      gpgcheck => 0,
  }

  package {
    'varnish':
      ensure => 'installed'
  }

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
      content => template('varnish/varnish.erb')
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
      source  => 'puppet:///varnish/varnish.vcl',
      require => Package['varnish'],
      notify  => Service['varnish'],
      replace => true
  }

  file {
    '/etc/varnish/directors.vcl':
      ensure  => 'present',
      replace => false,
      content => '',
      require => Package['varnish']
  }

  file {
    '/etc/varnish/backends.vcl':
      ensure  => 'present',
      replace => false,
      content => '',
      require => Package['varnish']
  }


  Varnish::Director <<||>> {
    notify => Service['varnish']
  }

  Varnish::Backend <<||>> {
    notify => Service['varnish']
  }

  Varnish::Vclconfig <<||>> {
    notify => Service['varnish']
  }

}
