define varnish::vclconfig ($backend, $vcl_config='default', $aliases=[]) {

    file {
        "/etc/varnish/sites/$name.vcl":
            ensure  => 'present',
            content => template("varnish/${vcl_config}_vcl_config.erb"),
            require => File['/etc/varnish/sites']
    }

    file_line {
        "${name}_varnish_vcl_config":
            path    => '/etc/varnish/sites.vcl',
            line    => "include \"/etc/varnish/sites/$name.vcl\";",
            require => Package['varnish']
    }

}
