# Installation script to run Docker, OVS and Bridge Utils on Ubuntu 14.04

# Install required packages
apt-get update
apt-get install -q -y openvswitch-switch bridge-utils wget

# Install Docker
wget -qO- https://get.docker.com/ | sh

# Add Docker Options to pickup the bridge name.
# Default to docker0. if alternate name is used, update the file with that name
echo 'DOCKER_OPTS="--bridge=docker0"' >> /etc/default/docker

# Restart docker
service docker restart
