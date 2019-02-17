# Create ssh keys on the provisioned system.
# WARNING: There is no security considerations here!!!
# Variables
CUSTOM_USER_NAME="testuser1"
CUSTOM_USER_GROUP="testuser1"
CUSTOM_USER_PASSWD="testuser1"
CUSTOM_USER_HOME="/home/$CUSTOM_USER_NAME"
CUSTOM_USER_SSH_HOME="$CUSTOM_USER_HOME/.ssh"
CUSTOM_USER_AUTHORIZED_KEYS="$CUSTOM_USER_SSH_HOME/authorized_keys"

# Root user information
ROOT_HOME="/root"
ROOT_SSH_HOME="$ROOT_HOME/.ssh"
ROOT_AUTHORIZED_KEYS="$ROOT_SSH_HOME/authorized_keys"

# Add user without a password
adduser -s /bin/bash -d "$CUSTOM_USER_HOME" -c "$CUSTOM_USER_NAME user" $CUSTOM_USER_NAME
echo "$CUSTOM_USER_NAME:$CUSTOM_USER_PASSWD" | chpasswd

# Add sudoers to the user's group
echo "%"$CUSTOM_USER_GROUP" ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/"$CUSTOM_USER_NAME"
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Setup keys for custom user
# WARNING: the "echo y" means it to overwrite the key file if it already exists
mkdir -m 0700 -p $CUSTOM_USER_SSH_HOME
echo -e 'n\n' | ssh-keygen -q -C "$CUSTOM_USER_NAME ssh key" -f "$CUSTOM_USER_SSH_HOME/id_rsa" -q -N ""
cat "$CUSTOM_USER_SSH_HOME/id_rsa.pub" >> "$ROOT_AUTHORIZED_KEYS"
cat "$CUSTOM_USER_SSH_HOME/id_rsa.pub" >> "$CUSTOM_USER_AUTHORIZED_KEYS"
chmod 644 "$CUSTOM_USER_AUTHORIZED_KEYS"

# OpenSSH client configuration
cat << EOF > "$CUSTOM_USER_SSH_HOME"/config
Host *
   UserKnownHostsFile /dev/null
   StrictHostKeyChecking no
   PasswordAuthentication no
   IdentitiesOnly yes
   LogLevel FATAL
   ForwardAgent yes
EOF

chown -R "$CUSTOM_USER_NAME:$CUSTOM_USER_NAME" "$CUSTOM_USER_SSH_HOME"

