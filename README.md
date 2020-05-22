# Raspberry Install Scripts
Scripts and configuration tunning i use to setup my raspberry cluster.

## Summary  :

* [1. Download and install Operating System](#1-download-and-install-operating-system)
* [2. Boot Config](#2-boot-config)
* [3. Net Config](#3-net-config)
* [4. Install K3S](#4-install-k3s)
* [5. Install Rancher](#5-install-rancher)

> For hardware & infrastructure requirements go see my other repo : https://github.com/armandleopold/raspberry-cluster

# 1. Download and install Operating System
> from https://www.raspberrypi.org/downloads/raspbian/

1. Download rapsbian lite version.
2. Donwload Etcher balena : https://www.balena.io/etcher/
3. Copy raspbian iso onto sdcard with etcher.

# 2. Boot Config
## Enable SSH 
> from https://www.raspberrypi.org/documentation/remote-access/ssh/

Add a file named `ssh` at the root path of the boot partition of the SDCARD before running it

## Optimize Power Consumption
> from https://www.jeffgeerling.com/blogs/jeff-geerling/raspberry-pi-zero-conserve-energy


* Disable HDMI	25mA	If you're running a headless Raspberry Pi, there's no need to power the display circuitry, and you can save a little power by running /usr/bin/tvservice -o (-p to re-enable). Add the line to /etc/rc.local to disable HDMI on boot.
* Disable LEDs	5mA per LED	If you don't care to waste 5+ mA for each LED on your Raspberry Pi, you can disable the ACT LED on the Pi Zero.
> from https://www.jeffgeerling.com/blogs/jeff-geerling/controlling-pwr-act-leds-raspberry-pi
If you want to disable both LEDs permanently, add the following to `/boot/config.txt`:
```
# Disable the ACT LED.
dtparam=act_led_trigger=none
dtparam=act_led_activelow=off

# Disable the PWR LED.
dtparam=pwr_led_trigger=none
dtparam=pwr_led_activelow=off
```
* Minimize Accessories	50+ mA	Every active device you plug into the Raspberry Pi will consume some energy; even a mouse or a simple keyboard will eat up 50-100 mA! If you don't need it, don't plug it in.
* Be Discerning with Software	100+ mA	If you're running five or six daemons on your Raspberry Pi, those daemons can waste energy as they cause the processor (or other subsystems) to wake and use extra power frequently. Unless you absolutely need something running, don't install it. Also consider using more power-efficient applications that don't require a large stack of software (e.g. LAMP/LEMP or LEMR) to run.

## Set GPU memory lowest : 

In **config.txt** add 
```
# Set GPU memory very low
gpu_mem=16
```

## Enable 64bit kernel :
*Arm Architecture to use full power of new BROADCOM Arm-v8 CPU*
> from https://www.raspberrypi.org/forums/viewtopic.php?t=250730

Update Config : 
```bash
sudo rpi-update
```
If you want to switch to 64-bit kernel add to **config.txt**
`arm_64bit=1`

## Increase swap size
> from https://wpitchoune.net/tricks/raspberry_pi3_increase_swap_size.html

* STOP THE SWAP

`sudo dphys-swapfile swapoff`

* MODIFY THE SIZE OF THE SWAP

As root, edit the file `/etc/dphys-swapfile` and modify the variable **CONF_SWAPSIZE** :
> CONF_SWAPSIZE=1024

and run `sudo dphys-swapfile setup` which will create and initialize the file.

* START THE SWAP
`sudo dphys-swapfile swapon`

## Set Timezone : 

```bash
sudo timedatectl set-timezone Europe/Paris
```

## Enable container features

We need to enable container features in the kernel, edit ``/boot/cmdline.txt`` and add the following to the end of the line:

```
 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
```

# 3. Net Config
## Set Static IP from your Router

I personaly use an Ubiquity Edge Router X for routing my internal cluster.
This router is setup to give static IP for my differents Raspberry Pi :

In a subnet : 192.168.2.0/24
I have : 
-	192.168.2.39
-	192.168.2.40
-	192.168.2.41
- 	192.168.2.42

## Set a Bastion as a passthrough for getting to your machines

I use my edge router as a Firewall to monitor in & out bound traffic and setup firewall Rules, i also use it as a bastion to SSH to my cluster. I have disabled port 22 from outside the LAN of the router. 

It's is impossible from the outside to reach my machines with the ssh port.

## Connect with SSH keys : 
> from https://www.linode.com/docs/security/authentication/use-public-key-authentication-with-ssh/

Generate key on the desktop :

`ssh-keygen -b 4096`

Copy the public key on the servers or remote machine :

`ssh-copy-id pi@192.168.2.xx`

## Protect : 
> from https://www.linuxnorth.org/five_minute_firewall/

I am using a physical router/firewall to isolate my raspberry cluster from my local network. I have configured port forwarding from my ISP router to my custom router ip.

> from https://blog.laslabs.com/2013/04/change-webui-port-ubiquiti-edge-router-lite/

Changing default webui port for Edge Router

## Set Hostname : 

Edit the file ``/etc/host``
```bash
sudo nano /etc/hostname
sudo nano /etc/hosts
sudo reboot
```

-	192.168.2.39 -> pi1
-	192.168.2.40 -> pi2
-	192.168.2.41 -> pi3
- 192.168.2.42 -> pi4

## Change password :

> from https://www.cyberciti.biz/faq/linux-set-change-password-how-to/

Change the password for the **pi** user

# 4. Install Cluster Orchestrator environment


## Enabling legacy iptables on Raspbian Buster

Raspbian Buster defaults to using nftables instead of iptables. K3S networking features require iptables and do not work with nftables. Follow the steps below to switch configure Buster to use legacy iptables:

```
sudo iptables -F
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo reboot
```

## K3S Install
> from https://rancher.com/docs/k3s/latest/en/installation/
> from https://k3s.io/

SSH to your master node pi and run :
Server install command:
```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=abc123 sh -s - server --cluster-init
```

Then SSH to you worker nodes pi and run :
Agent install command:
```bash
curl -sfL https://get.k3s.io | K3S_TOKEN=abc123 K3S_URL=https://server:6443/ sh -s -
```

## Helm Install

SSH to your master node pi and run :

> from https://helm.sh/docs/intro/install/#helm
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

Export k3s kubeconfig file as ENV var to override helm default get config path :
> from https://helm.sh/docs/helm/helm/

```bash
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bash_aliases
```

## Set user rights on master node : 

```bash
sudo chown -R pi:pi /etc/rancher/
```

## Generate traefik dashboard user password :

> from https://www.digitalocean.com/community/tutorials/how-to-use-traefik-as-a-reverse-proxy-for-docker-containers-on-ubuntu-16-04

We’ll use the htpasswd utility to create this encrypted password. First, install the utility, which is included in the apache2-utils package:

```bash
sudo apt-get install apache2-utils
```
Then generate the password with htpasswd. Substitute `secure_password` with the password you’d like to use for the Traefik admin user:

```bash
htpasswd -nb admin secure_password
```
The output from the program will look like this:

```
admin: xxxxxxxxxxxxxx
```

## Edit traefik manifest 

> from https://github.com/helm/charts/tree/master/stable/traefik#configuration

At `/var/lib/rancher/k3s/server/manifests/traefik.yaml`
And add the following lines at the end :
```yaml
    serviceType: NodePort
    service:
      nodePorts:
        http: xxxxx # custom nodeport
        https: xxxxx # custom nodeport
    dashboard:
      enabled: true
      domain: "traefik.mydomain.com"
      auth:
        basic:
          admin: xxxxxxxxxxxxxx # the admin htpasswd you just generated
    acme:
      enabled: true
      logging: true
      staging: false
      caServer: "https://acme-v02.api.letsencrypt.org/directory"
      email: xxxxxxxxxxxxxx  # your email
      challengeType: "dns-01"
      dnsProvider:
        name: gcloud
        gcloud:
          GCE_PROJECT: "xxxxxxxxxxxxxx" # your Google Cloud Project
          GCE_SERVICE_ACCOUNT_FILE: "/secrets/gcloud-credentials.json"
      domains:
        enabled: true
        domainsList:
          - main: "*.mydomain.com"
          - sans:
            - "mydomain.com"
    secretFiles:
      gcloud-credentials.json: '{xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}'
```

Then go to : `https://traefik.mydomain.com/dashboard/` to check if you succeed resolving the host, get correctly routed & get a response from a container on your cluster. If so, then you have a fully functionnal cluster !

> Nice tips for recreating a kube job :
> You can simulate a rerun by replacing the job with itself:
>
> `kubectl get job "your-job" -o json | kubectl replace --force -f -`

# 5. Install Rancher

> from https://rancher.com/docs/rancher/v2.x/en/installation/k8s-install/helm-rancher/#1-install-the-required-cli-tools

```
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
kubectl create namespace cattle-system
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher.mydomain.com --set tls=external
```

Wait a little bit, then go to : https://rancher.mydomain.com/

# 6. Install Prometheus 

> from https://github.com/helm/charts/tree/master/stable/prometheus

```
helm install prometheus stable/prometheus -f prometheus.yaml --namespace prometheus
```

# 7. Install Grafana

> from https://github.com/helm/charts/tree/master/stable/grafana

```
helm install grafana stable/grafana -f grafana.yaml --namespace prometheus
```

Settings : https://grafana.com/docs/grafana/latest/installation/configuration/#admin-user

## Sources : 
* http://www.pidramble.com/wiki
* https://blog.alexellis.io/serverless-kubernetes-on-raspberry-pi/
* https://gitlab.com/xavki/raspberry-tricks
* https://github.com/likamrat/ARMadillo
* https://github.com/Raspbernetes
