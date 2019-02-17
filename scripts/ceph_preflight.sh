#!/bin/bash
# From: http://docs.ceph.com/docs/mimic/start/quick-start-preflight/#ceph-deploy-setup
# Variables
CEPH_USER_NAME="cephuser"
CEPH_USER_GROUP="cephuser"
CEPH_USER_PASSWD="cephuser"
CEPH_USER_HOME="/home/$CEPH_USER_NAME"
CEPH_USER_SSH_HOME="$CEPH_USER_HOME/.ssh"
CEPH_USER_AUTHORIZED_KEYS="$CEPH_USER_SSH_HOME/authorized_keys"

ceph_repos(){
yum-config-manager --enable centosplus extras
yum install -y -q https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y -q yum-plugin-priorities

#Ceph Luminous repository
cat << EOM > /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph packages for x86_64
baseurl=https://download.ceph.com/rpm-luminous/el7/x86_64
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-luminous/el7/noarch
enabled=1
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc

[ceph-source]
name=Ceph source packages
baseurl=https://download.ceph.com/rpm-luminous/el7/SRPMS
enabled=0
priority=2
gpgcheck=1
gpgkey=https://download.ceph.com/keys/release.asc
EOM
}

ceph_pkg_admin_node() {
  yum install -y -q ceph-deploy ansible sshpass
}

ceph_pkg_nodes() {
  yum install -y -q ntp ntpdate python
  systemctl enable ntpd.service
  systemctl start ntpd.service
}

ceph_user_create() {
# Add user without a password
adduser -s /bin/bash -d "$CEPH_USER_HOME" -c "$CEPH_USER_NAME user" $CEPH_USER_NAME
echo "$CEPH_USER_NAME:$CEPH_USER_PASSWD" | chpasswd

# Add sudoers to the user's group
echo "%"$CEPH_USER_GROUP" ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/"$CEPH_USER_NAME"
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
}

ceph_sshkey_admin_node() {
# Setup keys for custom user
mkdir -m 0700 -p $CEPH_USER_SSH_HOME
echo -e 'n\n' | ssh-keygen -q -C "$CEPH_USER_NAME ssh key" -f "$CEPH_USER_SSH_HOME/id_ceph_rsa" -q -N ""
cat "$CEPH_USER_SSH_HOME/id_ceph_rsa.pub" >> "$CEPH_USER_AUTHORIZED_KEYS"
chmod 644 "$CEPH_USER_AUTHORIZED_KEYS"

# OpenSSH client configuration
cat << EOF > "$CEPH_USER_SSH_HOME"/config
Host *
   User $CEPH_USER_NAME
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   PasswordAuthentication no
   IdentityFile $CEPH_USER_SSH_HOME/id_ceph_rsa
   IdentitiesOnly yes
   LogLevel FATAL
   ForwardAgent yes
EOF

chown -R "$CEPH_USER_NAME:$CEPH_USER_NAME" "$CEPH_USER_SSH_HOME"
}

ceph_monitors_firewall() {
  firewall-cmd --zone=public --add-service=ceph-mon --permanent
  firewall-cmd --reload
}

ceph_osd_mds_firewall() {
  sudo firewall-cmd --zone=public --add-service=ceph --permanent
  firewall-cmd --reload
}

case $1 in
  repos) ceph_repos ;;
  admpkg) ceph_pkg_admin_node;;
  nodepkg) ceph_pkg_nodes ;;
  cephuser) ceph_user_create ;;
  admin_sshkey) ceph_sshkey_admin_node ;;
  fw_mon) ceph_monitors_firewall ;;
  fw_osd_mon) ceph_osd_mds_firewall ;;
  *) "Options:
      repos) ceph_repos
      admpkg) ceph_pkg_admin_node
      nodepkg) ceph_pkg_nodes
      cephuser) ceph_user_privileges
      admin_sshkey) ceph_sshkey_admin_node
      fw_mon) ceph_monitors_firewall
      fw_osd_mon) ceph_osd_mds_firewall";;
esac
