define varnish::backend (
  $port,
  $host = $::ipaddress_eth0,
  $first_byte_timeout = '300s',
  $probe = '')
{

    if $probe != '' {
      tool::line {
        "varnish_backend_$name$host$port":
            file   => '/etc/varnish/backends.vcl',
            line   => template('varnish/backend.erb'),
            notify => Service['varnish']
      }
    } else {
      tool::line {
        "varnish_backend_$name$host$port":
            file   => '/etc/varnish/backends.vcl',
            line   => template('varnish/backend_simple.erb'),
            notify => Service['varnish']
      }
    }

}
