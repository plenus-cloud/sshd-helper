FROM debian:10
#
#
#
#MAINTAINER "Kirill Müller" <krlmlr+docker@mailbox.org>
# fork from https://github.com/krlmlr/debian-ssh
MAINTAINER "Massimiliano Ferrero" <m.ferrero@cognitio.it>

# Install packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ADD set_user.sh /set_user.sh
ADD run.sh /run.sh
RUN chmod 755 /set_user.sh /run.sh

RUN mkdir -p /var/run/sshd
RUN sed -i -e 's/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g' /etc/ssh/sshd_config
RUN sed -i -e 's/^#AuthorizedKeysFile.*/AuthorizedKeysFile \/var\/lib\/ssh-user-effective\/.ssh\/authorized_keys/' /etc/ssh/sshd_config
RUN mkdir -p /var/lib/ssh-user/.ssh /var/lib/ssh-user-effective/.ssh
RUN chmod 700 /var/lib/ssh-user/.ssh /var/lib/ssh-user-effective/.ssh
RUN touch /root/.Xauthority

RUN rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ed25519_key \
     /etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key.pub
RUN mkdir /var/lib/sshd-keys

EXPOSE 22
CMD ["/run.sh"]
