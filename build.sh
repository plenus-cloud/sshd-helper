#!/bin/sh

TAG=sshd-helper:10.0.8

# build locally
docker build -t ${TAG} .
