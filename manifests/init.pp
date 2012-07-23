class varnish::init {

  yumrepo {
    'varnish':
      descr    => 'varnish repository',
      baseurl  => 'http://repo.varnish-cache.org/redhat/el5/x86_64/',
      enabled  => 1,
      gpgcheck => 0,
  }

  package {
    'varnish':
      ensure  => 'installed',
      require => Yumrepo['varnish']
  }

}
