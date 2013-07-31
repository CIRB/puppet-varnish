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
        file_line {
        "varnish_directory_${name}":
            ensure  => present,
            path    => '/etc/varnish/directors.vcl',
            line    => template('varnish/director.erb'),
            notify  => Service['varnish'],
            require => File['/etc/varnish/directors.vcl']
        }

}
