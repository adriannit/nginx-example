# Puppet module for managing Nginx
Installs and configures Nginx with the following features:

1. One SSL enabled(self signed certificate) virtualhost domain.com with

- Location / reverse proxy for http://10.10.10.10
- Location /resoure2/ reverse proxy for http://20.20.20.20

2. One virtualhost localhost acting as forward proxy for HTTP only because Nginx doesn't support passing SSL as forward proxy.

# Configuration
Configuration can be done via hiera

```
data/common.yaml
```

Log format can be modified also the reverse proxy hosts.

## Installing
Clone the repository in /etc/puppetlabs/code/environments/

Run 

``` puppet agent --test environment=nginx-example ```

## Depedencies
puppet-nginx

## tbd
Health check