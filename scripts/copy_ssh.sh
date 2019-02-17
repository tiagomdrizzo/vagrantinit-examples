#!/bin/bash

case $1 in
hosts)
  'ls' -1 /vagrant/.vagrant/machines/ > /vagrant/scripts/hosts.txt
;;

copy)
echo 'Input Password:';
read -s SSHPASS;
export SSHPASS
 for NODE in $(cat /vagrant/scripts/hosts.txt); do
   sshpass -e ssh-copy-id -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o PasswordAuthentication=yes $NODE;
 done
export SSHPASS=''
;;
esac
