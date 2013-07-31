# == Define: init
#
#  Install varnish
#
class varnish::init {

  $version = hiera('varnish-version', 'installed')
  if $version == 'installed' {
    yumrepo {'varnish':
      descr    => 'varnish repository',
      baseurl  => 'http://repo.varnish-cache.org/redhat/el5/x86_64/',
      enabled  => 1,
      gpgcheck => 0,
    }

    package {'varnish':
      ensure  => 'installed',
      require => Yumrepo['varnish']
    }
  } else {
    yumrepo {'varnish':
      descr    => 'varnish repository',
      baseurl  => 'http://repo.varnish-cache.org/redhat/el5/x86_64/',
      enabled  => 0,
      gpgcheck => 0,
    }

    package {'varnish':
      ensure  => $version,
    }

  }

}
