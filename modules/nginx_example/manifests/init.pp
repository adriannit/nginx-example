#
# Ensures present self signed certificate-key pair
# Creates domain.com vhost with two locations as reverse proxy
# Creates localhost vhost with one location as forward proxy
#
class nginx_example(
    $cert_name = 'example.crt',
    $cert_key_name = 'example.key',
    $cert_owner = 'root',
    $cert_group = 'root',
    $cert_mode  = '0600',
    $cert_path  = '/etc/ssl/certs/example.crt',
    $cert_key_path = '/etc/ssl/private/example.key',

    $first_host = 'http://10.10.10.10',
    $second_host = 'http://20.20.20.20',

    $hostname = 'domain.com',
)
{
    include nginx

    #SSL certificates
    file { $cert_name:
        ensure => 'present',
        path   => $cert_path,
        source => 'puppet:///modules/nginx_example/example.crt',
        owner  => $cert_owner,
        group  => $cert_group,
        mode   => $cert_mode,
        notify => Service['nginx'],
    }

    file { $cert_key_name:
        ensure => 'present',
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

    nginx::resource::location{'/resoure2/ ':
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
