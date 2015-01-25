# Tornado Development Environment

A full featured development environment based on Vagrant, Debian, Puppet and
Pyenv.

This Vagrant box will install an isolated development environment for Tornado
web applications. It should support any platform which supports VirtualBox and
Vagrant.

## Requirements
* VirtualBox (built on 4.3.12)
* Vagrant (built on 1.7.2)
* vagrant-hostmanager (optional, but useful)

## Installation
Clone this repository to your local machine, navigate to the folder in your
preferred console, and take the following steps:

The first two commands install the Tornado application skeleton, so if you want
to use your own, you can skip these steps and clone your own project into the
`app` folder, and just start at step 3.

1. `git submodule init`
2. `git submodule update`
3. `vagrant up`

That's literally all! The last command will take some time, as it has to fetch
the base box from [HashiCorp Atlas](https://atlas.hashicorp.com/) (used to be
Vagrantcloud), then install it and provision the base system.

Once you've got this running, you can tell it to automatically update your
hosts file, so we can get to it via an easily memorable URL. Type
`vagrant hostmanager`, and it will try to automatically create a host alias for
you if you have the
[vagrant-hostmanager plugin](https://github.com/smdahlen/vagrant-hostmanager)
installed.

Now you can access the VM in a web browser at http://tornado.local/.

## The insides
The Tornado application is hosted under supervisord. There are 4 copies
running, on ports 8001 to 8004, all behind a
[nginx proxy pass](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass).

They output their combined stdout to /var/log/app.log and stderr per instance
to /var/log/app-0n.err, where n is the number of the supervisor application
instance (0 to 3 by default).

Port 80 on the VM is mapped to 8080 on your host system, in case you already
have a service running on 80. In this case, access the VM on
http://tornado.local:8080/.
