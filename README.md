acknowledgements
================

fork from https://github.com/krlmlr/debian-ssh
from Kirill Müller <krlmlr+docker@mailbox.org>

sshd-helper
==========

Simple Debian Docker images with *passwordless* SSH access and a regular user
with `sudo` rights

Using
-----

The images are built by [Docker hub](https://registry.hub.docker.com/u/plenus/sshd-helper/).
To run an SSH daemon in a new Debian container:

    docker run -d -p 2222:22 -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" krlmlr/debian-ssh:10.0.1

This requires a public key in `~/.ssh/id_rsa.pub`.

Two users exist in the container: `root` (superuser) and `docker` (a regular user
with passwordless `sudo`). SSH access using your key will be allowed for both
`root` and `docker` users.
To connect to this container as root:

    ssh -p 2222 root@localhost

To connect to this container as regular user:

    ssh -p 2222 docker@localhost

Change `2222` to any local port number of your choice.


Testing
-------

Execute `make test` to create a container and fetch all environment variables
via SSH.  This requires an `.ssh/id_rsa.pub` file in your home, it will be
passed to the container via the environment variable `SSH_KEY` and installed.
The `Makefile` is configured to run the container with the limited `docker`
account, this user is allowed to run `sudo` without requiring a password.
The SSH daemon will be always run with root access.  The `debug-*` targets
can help troubleshooting any issues you might encounter.
