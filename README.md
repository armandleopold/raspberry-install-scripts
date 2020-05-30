# Raspberry Install Scripts
Scripts and configuration tunning i use to setup my raspberry cluster.

> For hardware & infrastructure requirements go see my other repo : https://github.com/armandleopold/raspberry-cluster

# Summary :

* [1. Download and install Operating System](#1-download-and-install-operating-system)
* [2. Boot Config](#2-boot-config)
* [3. Net Config](#3-net-config)
* [4. Install K3S](#4-install-k3s)
* [5. Install Rancher](#5-install-rancher)

## Sources : 
* http://www.pidramble.com/wiki
* https://blog.alexellis.io/serverless-kubernetes-on-raspberry-pi/
* https://gitlab.com/xavki/raspberry-tricks
* https://github.com/likamrat/ARMadillo
* https://github.com/Raspbernetes

> from https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl

Steps
1. Install Docker
```
curl -sSL https://get.docker.com | sh
```
2. Add permission to Pi User to run Docker Commands
```
sudo usermod -aG docker pi
```
Reboot here or run the next commands with a sudo

3. Test Docker installation
```
docker run hello-world
```
4. IMPORTANT! Install proper dependencies
```
sudo apt-get install -y libffi-dev libssl-dev

sudo apt-get install -y python3 python3-pip

sudo apt-get remove python-configparser
```
5. Install Docker Compose
```
sudo pip3 install docker-compose
```
Boom! 🔥 It's done!
