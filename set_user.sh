#!/bin/bash

if [ -z "${SSH_USER}" ]; then
	echo "=> Please specify ssh username in SSH_USER environment variable"
	exit 1
fi

# check if user exists
getent passwd ${SSH_USER} > /dev/null

if [ $? -ne 0 ]; then
  USERADD_OPTIONS="-d /home/${SSH_USER} -s /bin/bash"
  if [ -n "${USER_UID}" ]; then
    USERADD_OPTIONS="${USERADD_OPTIONS} -u ${USER_UID}"
  fi
  if [ -n "${USER_GID}" ]; then
    USERADD_OPTIONS="${USERADD_OPTIONS} -g ${USER_GID}"
  fi
  useradd ${USERADD_OPTIONS} ${SSH_USER} \
  && passwd -d ${SSH_USER} \
  && mkdir -p /home/${SSH_USER} \
  && chown ${SSH_USER}:${SSH_USER} /home/${SSH_USER} \
  && chmod 700 /home/${SSH_USER}
fi

# copy keys from secrets
if [ -f /var/lib/sshd-keys/ssh_host_ecdsa_key ]; then
  cp /var/lib/sshd-keys/ssh_host_ecdsa_key /etc/ssh/
fi
if [ -f /var/lib/sshd-keys/ssh_host_ecdsa_key.pub ]; then
  cp /var/lib/sshd-keys/ssh_host_ecdsa_key.pub /etc/ssh/
fi
if [ -f /var/lib/sshd-keys/ssh_host_ed25519_key ]; then
  cp /var/lib/sshd-keys/ssh_host_ed25519_key /etc/ssh/
fi
if [ -f /var/lib/sshd-keys/ssh_host_ed25519_key.pub ]; then
  cp /var/lib/sshd-keys/ssh_host_ed25519_key.pub /etc/ssh/
fi
if [ -f /var/lib/sshd-keys/ssh_host_rsa_key ]; then
  cp /var/lib/sshd-keys/ssh_host_rsa_key /etc/ssh/
fi
if [ -f /var/lib/sshd-keys/ssh_host_rsa_key.pub ]; then
  cp /var/lib/sshd-keys/ssh_host_rsa_key.pub /etc/ssh/
fi
# copy authorized_keys from secret
if [ -f /var/lib/ssh-user/.ssh/authorized_keys ]; then
  cp /var/lib/ssh-user/.ssh/authorized_keys /var/lib/ssh-user-effective/.ssh/authorized_keys
fi
# fixing permissions on ssh keys
chmod 600 /etc/ssh/ssh_host_*_key
chmod 640 /etc/ssh/ssh_host_*_key.pub
chown -R ${SSH_USER} /var/lib/ssh-user-effective
chown ${SSH_USER} /var/lib/ssh-user-effective/.ssh/authorized_keys
chmod 640 /var/lib/ssh-user-effective/.ssh/authorized_keys
chmod 700 /var/lib/ssh-user-effective/.ssh/

# set bash as shell for user, useful is SSH_USER points to a system user
sed -i -e "s/^${SSH_USER}:\(.*\):\/usr\/sbin\/nologin$/${SSH_USER}:\1:\/bin\/bash/" /etc/passwd
sed -i -e "s/^${SSH_USER}:\(.*\):\/bin\/false$/${SSH_USER}:\1:\/bin\/bash/" /etc/passwd

# check if server keys exists, if not create them
if [ ! -f /etc/ssh/ssh_host_ecdsa_key ] || [ ! -f /etc/ssh/ssh_host_ed25519_key ] || [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  dpkg-reconfigure openssh-server
fi

echo "========================================================================"
echo "You can now connect to this container via SSH using:"
echo ""
echo "    ssh -p <port> ${SSH_USER}@<host>"
echo ""
echo "========================================================================"
