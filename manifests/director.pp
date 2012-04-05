define varnish::director ( $backends ) {
        file_line {
        "varnish_directory_$name":
            path    => '/etc/varnish/directors.vcl',
            line    => template('varnish/director.erb'),
            require => File['/etc/varnish/directors.vcl']
        }

}
