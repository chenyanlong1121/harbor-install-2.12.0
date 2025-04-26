#!/bin/sh
command_exists() {
   command -v "$@" > /dev/null 2>&1
}
if ! command_exists docker; then
   set -x
   tar --strip-components=1 -xvzf ../docker/docker.tgz -C /usr/local/bin
   cp ../conf/docker.service /usr/lib/systemd/system/docker.service
   systemctl enable  docker.service
   systemctl restart docker.service

storage=${1:-/var/docker/lib}

mkdir -p $storage

mkdir -p /etc/docker
touch /etc/docker/daemon.json

cat > /etc/docker/daemon.json  << eof
{
  "registry-mirrors": [
     "http://373a6594.m.daocloud.io"
  ],
  "bip": "192.168.100.1/24",
  "default-address-pools" : [
    {
      "base" : "192.168.0.0/16",
      "size" : 24
    }
  ],
  "insecure-registries":
        ["docker-registry.supconit.com"],
  "data-root":"${storage}",
  "log-driver":"json-file",
  "log-opts":{
      "max-size":"500m",
      "max-file":"1"
  }
}
eof
   systemctl daemon-reload
   systemctl restart docker.service
   docker version
fi
