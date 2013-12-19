NGINX.CONF
==========
Author

Mahfooz Ahmad mahfooz_ahmad20@yahoo.com

Manifest: nginx-dev

Technical Challenge - Automate the installation and configuration of a nginx web server

The nginx server should:
a) serve requests over port 8080
b) serve a page with the content of the following repository: https://github.com/puppetlabs/exercise-webpage.

Your solution should:
i) ensure that the required configuration is completed reliably when all the steps are completed
ii) ensure that subsequent applications of the solution do not cause failures or repeat redundant configuration tasks

Prerequisites

The latest version of virtual box should be installed to ensure that the vagrant boxes specified in the Vagrantfile's contained in this solution will run. For development and testing, Virtualbox 4.2.12 for Mac OS X was used: (http://download.virtualbox.org/virtualbox/4.2.12/VirtualBox-4.2.12-84980-OSX.dmg)

Vagrant is available for all major x86_64 OS's, including Linux and Solaris: http://puppet-vagrant-boxes.puppetlabs.com/

In addition, it is assumed that the user has a variant of git installed on their system in order to retrieve the author's solution from Github.

Parameters

nginx port = 8080

index.html = https://github.com/puppetlabs/exercise-webpage/blob/master/index.html

Variables

Created the following port forwarding mapping for nginx within the Vagrantfiles,With port and index.html defined in the scope, we don't need any additional variables and nither it is in the Puppet code.

 precise64   - localhost:8081 -> VM:8080
 precise32   - localhost:8082 -> VM:8080
 fedora18    - localhost:8083 -> VM:8080 
 centos6.4   - localhost:8084 -> VM:8080
 debian6.0.7 - localhost:8085 -> VM:8080
 
For the we built this solution to make use of multiple platforms with Vagrant/VirtualBox, and because it is possible to run multiple VMs simultaneously and want to make sure there is no port conflicts on localhost.


