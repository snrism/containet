Docker-OVS Integration
==========

The goal is to connect docker containers hosted in multiple nodes via OpenvSwitch.
In this setup, we will take control of the networking feature in the containers and use OVS instead of docker bridge.
We will setup GRE tunnels between OVS switches in 2 nodes and connect the containers to OVS.

Installation
===========
Note: If you have 2 hosts that is already running docker, you can skip to the Containet Setup

    - Install virtualbox https://www.virtualbox.org/wiki/Downloads
    - Install vagrant https://www.vagrantup.com/downloads.html

In this setup, we plan to use 2 Ubuntu Trusty nodes

    - Pull the Ubuntu image using:
        $ vagrant box add ubuntu/trusty64 https://vagrantcloud.com/ubuntu/boxes/trusty64/versions/1/providers/virtualbox.box
    - Once you have the image in your host node, use the vagrantfile to bring up the 2 nodes that we will use in our experiment
        $ mkdir vagrant/cluster
        $ cd vagrant/cluster
    - Edit your Vagrant file to update the source folder where you have downloaed the "containet" scripts.
    - Check the script on how to set the correct folder. Once your vagrantfile is updated, initialize.
        $ vagrant init
    - Bringup the 2 nodes:
        $ vagrant up
    - SSH into the nodes
        $ vagrant ssh host1
        $ vagrant ssh host2

Cotainet Setup
=======

Assuming you are in the top folder:
    - Run the installation script
        $ sudo ./install.sh
    - Install ubuntu image
        $ sudo docker build -t ubuntu config/Dockerfile
    - In Host1, update 'tunrc' to reflect your setting
    - (e.g., update REMOTE_IP: to host2's IP. Incase if you are using our vagrant setup, no changes required)
        $ source config/host1_tunrc
    - In Host2, update 'tunrc' to reflect your setting
    - (e.g., update REMOTE_IP: to host1's IP. Incase if you are using our vagrant setup, no changes required)
        $ source config/host2_tunrc


Experiment 1 - Connect docker bridge and OVS bridge to connect containers hsoted in 2 hosts:
=======
    - Use the below folder for this experiment:
        $ cd tunnel_via_docker_and_ovs/

    In Host1:
    - Setup GRE Tunnel
        $ ./ovs-tunnel-setup.sh #Creates a gre tunnel port and adds to the OVS bridge

    - Setup required iptables rules for containers to reach external world.
        $ ./iptables.sh

    - Start a container without using docker's default network config
        $ docker run -d --net=none -t -i ubuntu /bin/bash

        - Record the Container ID that just started
        $ docker ps

        - If you are using default configuration from tunrc, copy the container-id from above and pick an IP in the 172.15.42.X subnet.
        - We started containers without any iface and now configure 'eth0' with our own IP in the specified subnet.
        - This ensures we do not have conflicting IP addresses in our setup.
        $ ./start-container.sh <container-id> <172.15.42.X>

    Repeat the above steps in Host2..

    Test Connection:
    - Attach to the containers
        $ docker attach <container-id>
    - Ping ...
        $ ping 172.15.42.X


Experiment 2 - Only use OVS to directly connect containers hosted in 2 hosts:
=======
    - Use the below folder for this experiment:
        $ cd tunnel_via_ovs/

    In Host1:
    - Setup GRE Tunnel
        $ ./ovs-tunnel-setup.sh #Creates a gre tunnel port and adds to the OVS bridge

    - Setup required iptables rules for containers to reach external world.
        $ ./iptables.sh # We do not need this step, if your iptables was previously set during experiment 1.

    - Start a container without using docker's default network config
        $ docker run -d --net=none -t -i ubuntu /bin/bash

        - Record the Container ID that just started
        $ docker ps

        - If using default configurations in tunrc, copy the container-id from above and pick an IP in the 172.15.42.X subnet.
        - the diff with start-container script is this will create 'eth1' interface and attach it directly to the OVS bridge
        $ ./connect-container.sh <container-pid> <172.15.42.X>

    Repeat the above steps in Host2

Network Isolation Test:
    - If you want to seggregate the containers in separate VLAN
    $ ./connect-container.sh <container-pid> <172.15.42.X> <vlan-id>

Test Connection:
    - Attach to the containers
        $ docker attach <container-id>
    - Ping ...
        $ ping 172.15.42.X

References
=======
The scripts used in our experiements have been adapted from the following links to exhibit OVS features.
    - https://goldmann.pl/blog/2014/01/21/connecting-docker-containers-on-multiple-hosts/
    - http://fbevmware.blogspot.com/2013/12/coupling-docker-and-open-vswitch.html

Next Steps
=======
Use OVS to specify QoS for different containers
Setup VXLAN instead of GRE tunnel

