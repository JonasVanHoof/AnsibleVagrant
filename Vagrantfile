# -*- mode: ruby -*-
#vi: set ft=ruby :
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  #Management
  config.vm.define :management do |management|
    management.vm.box = "ubuntu/xenial64"
    management.vm.hostname = "Management"
    management.vm.network :private_network, ip:"192.168.15.2"
    management.vm.synced_folder "playbooks", "/home/vagrant/playbooks"
    management.vm.synced_folder "cfg", "/home/vagrant/cfg"
    management.vm.provision :shell, path: "bootstrap.sh"

    management.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = "1"
    end
  end

  #Database
  #config.vm.define :database do |db|
   # db.vm.box = "ubuntu/xenial64"
    #db.vm.hostname = "Database"
    #db.vm.network :private_network, ip:"192.168.15.3"
    #db.vm.provision :shell, path: "/cfg/ssh/addSSHKey.sh"

    #db.vm.provider "virtualbox" do |vb|
     # vb.memory = "512"
     # vb.cpus = "1"
    #end
  #end

  #LoadBalancer
  #config.vm.define :LoadBalancer do |loadBalancing|
   # loadBalancing.vm.box = "ubuntu/xenial64"
   # loadBalancing.vm.hostname = "LoadBalancer"
   # loadBalancing.vm.network :private_network, ip:"192.168.15.4"
   # loadBalancing.vm.network "forwarded_port", guest: 80, host: 2019
   # loadBalancing.vm.provision :shell, path: "/cfg/ssh/addSSHKey.sh"

   # loadBalancing.vm.provider "virtualbox" do |vb|
    #  vb.memory = "512"
    #  vb.cpus = "1"
   # end
  #end

  #Webservers
  (1..4).each do |i|
    config.vm.define "Web#{i}" do |web|
      web.vm.box = "ubuntu/xenial64"
      web.vm.hostname = "Webserver"
      web.vm.network :private_network, ip:"192.168.15.#{4+i}"
      web.vm.provision :shell, path: "cfg/ssh/addSSHKey.sh"
    
      web.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
        vb.cpus = "1"
    end
  end

  #Backend servers
  #(1..1).each do |i|
   # config.vm.define "Backend#{i}" do |backend|
    #backend.vm.box = "ubuntu/xenial64"
    #backend.vm.hostname = "Backend"
    #backend.vm.network :private_network, ip:"192.168.15.#{10+i}"
    #backend.vm.provision :shell, path: "/cfg/ssh/addSSHKey.sh"
    
    #  backend.vm.provider "virtualbox" do |vb|
     #   vb.memory = "512"
      #  vb.cpus = "1"
    #end
  #end

#end
end




end
