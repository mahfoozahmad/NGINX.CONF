class nginx-dev {

# CentOS repos don't provide nginx by default. we use 'epel' instead
    if $::operatingsystem == 'CentOS' {
        exec { 'install_epel':
            command => '/bin/rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm || true',
            notify => Exec['repo_refresh'],
            creates => '/etc/yum.repos.d/epel.repo',
        }
    }

    $package_manager_update_cmd = $::operatingsystem ? {
            /(Red Hat|CentOS|Fedora)/ => 'yum makecache',
            /(Debian|Ubuntu)/ => 'apt-get update',
    }
# try to run this for best-effort, and return 0 so that the rest of the
# puppet run follows accordingly, regardless of the availability of external
# repos, the state of the package cache, whatever might make this cmd
# return non-zero on your particular distro
    exec { 'repo_refresh':
        command => "/usr/bin/$package_manager_update_cmd || true",
        cwd => "/usr/bin",
    }
# gonna need this
    package { 'nginx':
        ensure => present,
        require => Exec['repo_refresh'],
    }

# we're going to replace nginx.conf. it describes where the webroot is, as
# well as what user to run nginx as. create the pre-requisites for that
# and then put the file in place, restarting nginx in the process.
    user { 'www-data':
        ensure => present,
    }
# where we'll serve our index.html file from
    file { 'webroot':
        path => '/tmp/nginx/',
        owner => 'root',
        group => 'root',
        mode => 0755,
        ensure => directory,
    }

# grab the content we're going to serve up
    exec { 'wget':
        command => '/usr/bin/wget https://raw.github.com/puppetlabs/exercise-webpage/master/index.html',
        cwd => '/tmp/nginx/',
        require => File['webroot'],
        notify => Exec['sed_png'],
    }

# As of 2 Jun 2013 at 21:55 EST, the logo png URL referenced in the html in Exec['wget']
# does not serve a valid png file. There is this:
# http://www.puppetlabs.com/wp-content/uploads/2010/12/PL_logo_vertical_RGB_sm.png
    exec { 'sed_png':
        command => "/bin/sed -i 's/Puppet-Labs-Logo-Vertical.png/PL_logo_vertical_RGB_sm.png/' /tmp/nginx/index.html",
        cwd => '/tmp/nginx/',
        require => Exec['wget'],
    }

# this solution gets a fraction more portable if I do this ugly thing:
    $conf = "user www-data;
worker_processes 1;

error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
worker_connections 1024;
}

http {
include /etc/nginx/mime.types;
access_log /var/log/nginx/access.log;
sendfile on;
keepalive_timeout 65;
tcp_nodelay on;

server {
listen 8080;
server_name localhost.localdomain;

location / {
root /tmp/nginx/;
index index.html;
}
}
}"
# pull nginx.conf off the vagrant root, restart the service if it's running
    file { 'nginx.conf':
        path => '/etc/nginx/nginx.conf',
        content => "$conf",
        require => [ Package ['nginx'], User['www-data'] ],
        notify => Service ['nginx'],
    }
    
    exec { 'kill_fw':
        command => '/sbin/service iptables stop && true',
    }

    service { 'nginx':
        ensure => 'running',
        require => [ Package['nginx'], Exec['kill_fw'] ],
    }
}

include nginx-dev
