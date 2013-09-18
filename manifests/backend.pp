#
#  Create a varnish backend for a site
#
# === Parameters
#
# [*port*]
#   Port where the backend is running
#
# [*host*]
#   IP/Hostname where the backend is running
#
# [*first_byte_timeout*]
#   Timeout period in seconds in which a backend has to answer
#
# [*probe*]
#
#
define varnish::backend (
  $port,
  $host,
  $first_byte_timeout = '300s',
  $probe = '')
{
    if $probe != '' {
      concat::fragment {$title:
        target  => '/etc/varnish/backends.vcl',
        content => template('varnish/backend.erb'),
        notify  => Service['varnish'],
      }
    } else {
      concat::fragment {$title:
        target  => '/etc/varnish/backends.vcl',
        content => template('varnish/backend_simple.erb'),
        notify  => Service['varnish'],
      }
    }

}
