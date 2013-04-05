# == Define: vclconfig
#
#  Create a vcl config for a site
#
# === Parameters
#
# [*backend*]
#   Name of the backend to connect for this site
#
# [*vcl_config*]
#   Configuration template to use
#
# [*aliases*]
#   host aliases to match before using this config
#
define varnish::vclconfig ($backend, $vcl_config='default', $aliases=[]) {

    file {
        "/etc/varnish/sites/${name}.vcl":
            ensure  => 'present',
            content => template("varnish/${vcl_config}_vcl_config.erb"),
            notify  => Service['varnish'],
            require => [Package['varnish'], File['/etc/varnish/sites']]
    }

    file_line {
        "${name}_varnish_vcl_config":
            ensure  => present,
            path    => '/etc/varnish/sites.vcl',
            line    => "include \"/etc/varnish/sites/${name}.vcl\";",
            notify  => Service['varnish'],
            require => Package['varnish']
    }

}
