define varnish::director ( $backends ) {
        file_line {
        "varnish_directory_$name":
            ensure  => present,
            path    => '/etc/varnish/directors.vcl',
            line    => template('varnish/director.erb'),
            notify  => Service['varnish'],
            require => File['/etc/varnish/directors.vcl']
        }

}
