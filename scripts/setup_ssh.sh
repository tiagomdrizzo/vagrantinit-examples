# Create ssh keys on the provisioned system.
# Variables
ROOT_HOME="/root"
ROOT_SSH_HOME="$ROOT_HOME/.ssh"
ROOT_AUTHORIZED_KEYS="$ROOT_SSH_HOME/authorized_keys"
VAGRANT_HOME="/home/vagrant"
VAGRANT_SSH_HOME="$VAGRANT_HOME/.ssh"
VAGRANT_AUTHORIZED_KEYS="$VAGRANT_SSH_HOME/authorized_keys"

#sudo sed -i -e 's/^\(#\)\?PermitRootLogin\s\+\(yes\|no\)/PermitRootLogin yes/' \
#  -e 's/^\(#\)\?PasswordAuthentication\s\+\(yes\|no\)/PasswordAuthentication yes/' \
#  -e 's/^\(#\)\?UseDNS\s\+\(yes\|no\)/UseDNS yes/' /etc/ssh/sshd_config

# Setup keys for root user.
echo -e 'n\n' | ssh-keygen -q -C "root ssh key" -f "$ROOT_SSH_HOME/id_rsa" -q -N ""
cat "$ROOT_SSH_HOME/id_rsa.pub" >> "$ROOT_AUTHORIZED_KEYS"
chmod 644 "$ROOT_AUTHORIZED_KEYS"
# OpenSSH client configuration
cat << EOF > "$CUSTOM_USER_SSH_HOME"/config
Host *
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   PasswordAuthentication yes
   IdentitiesOnly yes
   LogLevel FATAL
   ForwardAgent yes
EOF
chown -R root:root "$ROOT_SSH_HOME"

# Setup keys for vagrant user.
echo -e 'n\n' | ssh-keygen -q -C "root ssh key" -f "$VAGRANT_SSH_HOME/id_rsa" -q -N ""
cat "$VAGRANT_SSH_HOME/id_rsa.pub" >> "$ROOT_AUTHORIZED_KEYS"
cat "$VAGRANT_SSH_HOME/id_rsa.pub" >> "$VAGRANT_AUTHORIZED_KEYS"
chmod 644 "$VAGRANT_AUTHORIZED_KEYS"
# OpenSSH client configuration
cat << EOF > "$CUSTOM_USER_SSH_HOME"/config
Host *
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   PasswordAuthentication yes
   IdentitiesOnly yes
   LogLevel FATAL
   ForwardAgent yes
EOF
chown -R vagrant:vagrant "$VAGRANT_SSH_HOME"
