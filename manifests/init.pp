# == Define: init
#
#  Install varnish
#
class varnish::init {

  $version = hiera('varnish-version', 'installed')

  # disable externe repo, we use a "cirb" repo
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
