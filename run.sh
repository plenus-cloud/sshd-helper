#!/bin/bash

set -e

/set_user.sh
exec /usr/sbin/sshd -D
