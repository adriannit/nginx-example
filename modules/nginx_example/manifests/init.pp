# @summary
# Ensures present self signed certificate-key pair
# Creates domain.com vhost with two locations as reverse proxy
# Creates localhost vhost with one location as forward proxy
#
# @param cert_name
#   The name of the SSL certificate file
# @param cert_key_name
#   The name of the SSL certificate key
# @param cert_owner
#   Owner of the certificate file/key
# @param cert_group
#   Group of the certificate file/key
# @param cert_mode
#   Mode of the certificate file/key
# @param cert_path
#   Path of the certificate file
# @param cert_key_path
#   Path of the certificate key
# @param first_host
#   First host to proxy
# @param second_host
#   Second host to proxy
# @param hostname
#   Hostname of the proxy
#
class nginx_example (
  String $cert_name     = 'example.crt',
  String $cert_key_name = 'example.key',
  String $cert_owner    = 'root',
  String $cert_group    = 'root',
  String $cert_mode     = '0600',
  String $cert_path     = '/etc/ssl/certs/example.crt',
  String $cert_key_path = '/etc/ssl/private/example.key',

  String $first_host    = 'http://10.10.10.10',
  String $second_host   = 'http://20.20.20.20',

  String $hostname      = 'domain.com',
) {
  include nginx

  #SSL certificates
  file { $cert_name:
    ensure => 'file',
    path   => $cert_path,
    source => 'puppet:///modules/nginx_example/example.crt',
    owner  => $cert_owner,
    group  => $cert_group,
    mode   => $cert_mode,
    notify => Service['nginx'],
  }

  file { $cert_key_name:
    ensure => 'file',
    path   => $cert_key_path,
    source => $cert_key_path,
    owner  => $cert_owner,
    group  => $cert_group,
    mode   => $cert_mode,
    notify => Service['nginx'],
  }

  # Reverse
  nginx::resource::server { $hostname:
    listen_port => 443,
    ssl         => true,
    ssl_cert    => $cert_path,
    ssl_key     => $cert_key_path,
    proxy       => $first_host,
    require     => File[$cert_name, $cert_key_name],
  }

  nginx::resource::location { '/resoure2/':
    proxy    => $second_host,
    ssl_only => true,
    server   => $hostname,
  }

  #Forward
  nginx::resource::server { 'localhost':
    listen_port => 8080,
    format_log  => 'example',
    proxy       => 'http://$http_host$request_uri',
  }
}
