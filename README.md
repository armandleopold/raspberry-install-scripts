# Raspberry Install Scripts
Scripts and configuration tunning i use to setup my raspberry cluster.

> For hardware & infrastructure requirements go see my other repo : https://github.com/armandleopold/raspberry-cluster

# Summary :

* [1. OS Install](os-boot-install/README.md)
* [2. Install K3S](k3s-install/README.md)
* [3. Helm Chart Install](helm-charts-install/README.md)
* [4. CI/CD Install](ci-cd-install/README.md)

## Sources : 
* http://www.pidramble.com/wiki
* https://blog.alexellis.io/serverless-kubernetes-on-raspberry-pi/
* https://gitlab.com/xavki/raspberry-tricks
* https://github.com/likamrat/ARMadillo
* https://github.com/Raspbernetes

> from https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl

## [Bonus] Add docker :

Steps
1. Install Docker
```
curl -sSL https://get.docker.com | sh
```
2. Add permission to Pi User to run Docker Commands
```
sudo groupadd docker
sudo usermod -aG docker pi
sudo usermod -aG docker root
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
## [Bonus] Add docker-compose :

5. Install Docker Compose
```
sudo pip3 install docker-compose
```
Boom! 🔥 It's done!


## [Bonus] Edit Edge Router Config : 

```
configure

delete port-forward rule 3
delete port-forward rule 4
delete port-forward rule 5

commit ; save

configure

set port-forward rule 3 description minecraft
set port-forward rule 3 forward-to address 192.168.2.39
set port-forward rule 3 forward-to port 25565
set port-forward rule 3 original-port 25565
set port-forward rule 3 protocol tcp

commit ; save
exit

configure

set port-forward rule 4 description tomcat
set port-forward rule 4 forward-to address 192.168.2.39
set port-forward rule 4 forward-to port 32050
set port-forward rule 4 original-port 32050
set port-forward rule 4 protocol tcp

commit ; save
exit
```

## (Bonus) Add a valid SSL certificate for EdgeRouter UI : 
> from https://www.stevejenkins.com/blog/2015/10/install-an-ssl-certificate-on-a-ubiquiti-edgemax-edgerouter/

Get cert from your Cert provider (me from traefik with acme challenge to Let's Encrypt Authority)
```
# Copy cert
scp armandleopold-fr-chain.pem aleopold@ubnt:/home/aleopold
# Connect to router
ssh aleopold@ubnt
# Copy cert
sudo cp  armandleopold-fr-chain.pem /etc/lighttpd/server.pem
# Stop http server
sudo kill -SIGINT $(cat /var/run/lighttpd.pid)
# Start http server
sudo  /usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
```
