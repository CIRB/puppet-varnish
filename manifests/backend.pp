define varnish::backend (
  $port,
  $host,
  $first_byte_timeout = '300s',
  $probe = '')
{

    if $probe != '' {
      file_line {
        "varnish_backend_$name$host$port":
            path    => '/etc/varnish/backends.vcl',
            line    => template('varnish/backend.erb'),
            notify  => Service['varnish'],
            require => [File['/etc/varnish/backends.vcl']]
      }
    } else {
      file_line {
        "varnish_backend_$name$host$port":
            path    => '/etc/varnish/backends.vcl',
            line    => template('varnish/backend_simple.erb'),
            notify  => Service['varnish'],
            require => [File['/etc/varnish/backends.vcl']]
      }
    }

}
