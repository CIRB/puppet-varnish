define varnish::vclconfig ($backend, $vcl_config='default', $aliases=[]) {

    file {
        "/etc/varnish/sites/$name.vcl":
            ensure  => 'present',
            content => template("varnish/${vcl_config}_vcl_config.erb"),
            notify  => Service['varnish'],
            require => [Package['varnish'], File['/etc/varnish/sites']]
    }

    file_line {
        "${name}_varnish_vcl_config":
            ensure  => present,
            path    => '/etc/varnish/sites.vcl',
            line    => "include \"/etc/varnish/sites/$name.vcl\";",
            notify  => Service['varnish'],
            require => Package['varnish']
    }

}
