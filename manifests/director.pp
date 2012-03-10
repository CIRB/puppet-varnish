define varnish::director ( $backends ) {
        tool::line {
        "varnish_directory_$name":
            file => '/etc/varnish/directors.vcl',
            line => template('varnish/director.erb')
        }

}
