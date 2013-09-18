# == Define: directory
#
#  Create a varnish director to load balance a site against different backends for a site
#
# === Parameters
#
# [*backends*]
#   List of backends (see varnish::backend) to use for this director
#
define varnish::director ( $backends ) {
  concat::fragment {"varnish_directory_${name}":
    target  => '/etc/varnish/directors.vcl',
    content => template('varnish/director.erb'),
    notify  => Service['varnish'],
  }
}
