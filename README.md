# Multimachine environement

## Used packages
* Vagrant
* Ansible
* Haproxy
* Flask
* nginx
* MySQL

## Folder structure
```
Project
├── backend_app
│   ├── flask
│   └── server.py
├── cfg
│   ├── ssh
│   └──  haproxy.cfg
├── frontend_app
├── playbooks
│   ├── backend.yml
│   ├── db.yml
│   ├── frontend.yml
│   ├── get-pip.py
│   └── lb.yml
├── Vagrantfile
└── README.md
```
## Sources
* [Vagrant docs](https://www.vagrantup.com/docs/index.html)
* [Vagrant/anisble](https://www.vagrantup.com/docs/provisioning/ansible.html)
* [Stackoverflow](https://stackoverflow.com/questions/tagged/vagrant)
* [HAProxy](https://serversforhackers.com/c/load-balancing-with-haproxy)

=> Make the directive three
```
Vagrant up -- provision
```
Add the installation for ansibleto the bootstrap.sh file =>
```bash
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible
```

Add the needed servers to the Vagrantfile:

Example:
```ruby
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
```
Example for putting up multiple servers that are the same:
```ruby
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
```
This is almost the same for every server:

-Management
-Database
-Loadblancer
-Web servers x4
-Backend servers x 4

In the boostrap.sh file =>
Add the hosts to the host file /etc/hosts
```bash
cat >> /etc/hosts <<EOF
192.168.15.2 management
192.168.15.3 database
192.168.15.4 loadBalancer
192.168.15.5 web1
192.168.15.6 web2
192.168.15.7 web3
192.168.15.8 web4
192.168.15.9 backend1
192.168.15.10 backend2
192.168.15.11 backend3
192.168.15.12 backend4
EOF
```
Add the listed servers to the group you want:
```bash
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
```
Add in the playbook frontend.yml =>
```yml
#Web
 - hosts: web
   sudo: yes

   tasks:
    - name: Install nginx
      apt: name=nginx state=present
    - name: content
      template: src=/vagrant/frontend_app/index.html dest=/var/www/html/index.html
    - name: start nginx
      service:
          name: nginx
          state: started

   handlers:
    - name: Restart nginx
      service: name=nginx state=restarted
```
Generate an ssh-key
```bash
@management: ssh-keygen
```
Add directory ssh to cfg =>
-addSSHKey.sh
-id_rsa.pub
-id_rsa

share the sshkey with the servers => addSSHKey.sh =>
```bash
cat /vagrant/cfg/ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
```
Add the playbooks to the right server =>

* ansible-playbook ~/playbooks/frontend.yml
* ansible-playbook ~/playbooks/lb.yml
* ansible-playbook ~/playbooks/backend.yml
* ansible-playbook ~/playbooks/db.yml

vagrant ssh database
```bash
@database: mysql -u root -p
```
=> Deleted management server
Added playbook to webservers

 ```ruby
 web.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "playbooks/frontend.yml"
 end
```
Backend playbook
```yml
#backend
 - hosts: all
   sudo: yes

   tasks:
    - name: Download pip
      command: curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py warn=false

    - name: Install pip
      command: python3 get-pip.py

    - pip:
        name:
         - Flask
         - flask-cors

    - name: Copy backend scripts to the flask server
      copy:
        src: /vagrant/backend_app/server.py
        dest: /home/vagrant/backend.py
        owner: vagrant
        group: vagrant
        mode: 0770

    - name: Copy init.d script
      copy:
        src: /vagrant/backend_app/flask
        dest: /etc/init.d/flask
        owner: root
        group: root
        mode: 0775

    - name: Add flask daemon to the startup configs
      shell: update-rc.d flask defaults

    - name: Start flask script
      service:
        name: flask state=started
```
Make a simple flask server =>
```python
from flask import Flask
import random

app = Flask(__name__)

@app.route("/")
def hello():
    return "This is a response from the backend!"

app.run(host="0.0.0.0")
```
Make a script that starts the flask service =>
```bash
#! /bin/sh
# /etc/init.d/flask

case "$1" in
  start)
    echo "Starting flask server"
    python3 /home/vagrant/backend.py &
    ;;
  stop)
    echo "Stopping flask server"
    killall python3
    ;;
  *)
    echo "Usage: /etc/init.d/flask{start|stop}"
    exit 1
    ;;
esac

exit 0
```
Loadbalancer playbook =>
```yml
#Loadbalancer
  - hosts: all
    sudo: yes

    tasks:
    - apt_repository: ppa:vbernat/haproxy-1.5 state=present

    - name: Update system
      command: apt update

    - name: Install haproxy
      apt: haproxy

    - name: Install socat
      apt: socat

    - name: Enable HAProxy
      lineinfile: dest=/etc/default/haproxy regexp="^ENABLED" line="ENABLED=1"
      notify: Restart HAProxy

    - name: Deploy HAProxy config
      template:
        src: /vagrant/cfg/haproxy.cfg
        dest: /etc/haproxy/haproxy.cfg
      notify: Restart HAProxy

    handlers:
      - name: Restart HAProxy
        service: name=haproxy state=restarted
```
Added HAProxy config file =>
```cfg
#Config HAProxy
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

frontend LOAD_BALANCER_FRONT
    bind *:80
    balance roundrobin
    mode http
    server Web1 192.168.15.5:80 check
    server Web2 192.168.15.6:80 check
    server Web3 192.168.15.7:80 check
    server Web4 192.168.15.8:80 check

frontend LOAD_BALANCER_BACK
    bind *:5000
    balance roundrobin
    mode http
    server Backend1 192.168.15.11:5000 check
    server Backend2 192.168.15.12:5000 check
    server Backend3 192.168.15.13:5000 check
    server Backend4 192.168.15.14:5000 check
```
Put all machines up =>
```bash
vagrant up --parallel
```