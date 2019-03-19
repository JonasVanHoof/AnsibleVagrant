### Make the directive three

Vagrant up -- provision

Add the installation for ansibleto the bootstrap.sh file =>

apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible


### Add the needed servers to the Vagrantfile:

#### Example:

#Management
  config.vm.define :management do |management|
    management.vm.box = "ubuntu/xenial64"
    management.vm.hostname = "Management"
    management.vm.network :private_network, ip:"192.168.15.2"
    management.vm.synced_folder "playbooks", "/home/vagrant/playbooks"
    #management.vm.synced_folder"
    management.vm.provision :shell, path: "bootstrap.sh"

    management.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = "1"
    end
  end

#### Example for putting up multiple servers that are the same:

#Webservers

  (1..4).each do |i|
    config.vm.define "Web#{i}" do |web|
      web.vm.box = "ubuntu/xenial64"
      web.vm.hostname = "Webserver"
      web.vm.network :private_network, ip:"192.168.15.#{4+i}"
    
      web.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
        vb.cpus = "1"
    end
  end

This is almost the same for every server:

-Management

-Database

-Loadblancer

-Web servers x4

-Backend servers x 4

In the boostrap.sh file => 
Add the hosts to the host file /etc/hosts

cat >> /etc/hosts <<EOF

192.168.15.2 management
192.168.15.3 database
192.168.15.4 loadBalancer
192.168.15.5 web1
192.168.15.6 web2
wdqdqw192.168.15.7 web3
192.168.15.8 web4
192.168.15.9 backend1
192.168.15.10 backend2
192.168.15.11 backend3
192.168.15.12 backend4
EOF

#### Add the listed servers to the group you want:

cat >> /home/vagrant/inventory.ini << EOF
[web]
web1
web2
web3
web4

[backend]
backend1
backend2
backend3
backend4

[db]
database

[lb]
loadBalancer
EOF

#### Add in the playbook frontend.yml =>

#Web
 - hosts: web
   sudo: yes
  
   tasks:
    - name: Install nginx
      apt: name=nginx state=present
    - name: content
      template: src=labo1_vagrant/frontend_app/index.html dest=/var/www/html/index.html

   handlers:
    - name: Restart nginx
      service: name=nginx state=restarted
      
#### Generate an ssh-key

@management: ssh-keygen

Add directory ssh to cfg =>
-addSSHKey.sh
-id_rsa.pub
-id_rsa

share the sshkey with the servers => addSSHKey.sh =>
cat /vagrant/cfg/ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

Add the playbooks to the right server =>
ansible-playbook ~/playbooks/frontend.yml
ansible-playbook ~/playbooks/lb.yml
ansible-playbook ~/playbooks/backend.yml
ansible-playbook ~/playbooks/db.yml

ansible-playbook playbook/frontend.yml -e 'ansible_python_interpreter=/usr/bin/python3'

#### vagrant ssh database
@database: mysql -u root -p

#### Problems

Localhost unreachable

shell provisioner:
* `path` for shell provisioner does not exist on the host system: /cfg/ssh/addSSHKey.sh
FIXED => loadBalancing.vm.provision :shell, path: "cfg/ssh/addSSHKey.sh"
      
