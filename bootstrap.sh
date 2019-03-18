#!/bin/bash
echo "installing ansible"
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible

cat >> /home/vagrant/ansible.cfg << EOF
[defaults]
inventory=/home/vagrant/inventory.ini
EOF

#Add servers to hostfile
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

#Add servers to group
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