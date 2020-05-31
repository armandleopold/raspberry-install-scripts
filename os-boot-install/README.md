# 1. Download and install Operating System
> from https://www.raspberrypi.org/downloads/

1. Select Raspbian lite for arm64 architectures.
2. Select SD Card
3. Write

# 2. Boot Config

## Enable SSH 
> from https://www.raspberrypi.org/documentation/remote-access/ssh/

Add a file named `ssh` at the root path of the boot partition of the SDCARD before running it

## Enable 64bit kernel :
*Arm Architecture to use full power of new BROADCOM Arm-v8 CPU*
> from https://www.raspberrypi.org/forums/viewtopic.php?t=250730

Update Config : 
```bash
sudo rpi-update
```
If you want to switch to 64-bit kernel add to **config.txt**
`arm_64bit=1`

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

## Overclocking CPU (Optional depends on your cooling) :

In **config.txt** add  to overclock the CPU to 2.0 GHz
```
# Set CPU Voltage & Frequency
over_voltage=6
arm_freq=2000
```

## Remove swap :

```
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
```

## Increase swap size (not recommended for k3s) :

### [1st Method] (FOR HDD/SSD SWAPING)
> from https://wpitchoune.net/tricks/raspberry_pi3_increase_swap_size.html

* STOP THE SWAP

`sudo dphys-swapfile swapoff`

* MODIFY THE SIZE OF THE SWAP

As root, edit the file `/etc/dphys-swapfile` and modify the variable **CONF_SWAPSIZE** :
> CONF_SWAPSIZE=1024

and run `sudo dphys-swapfile setup` which will create and initialize the file.

* START THE SWAP

`sudo dphys-swapfile swapon`

### [2nd Method] (FOR ZRAM SWAPING)

> from https://www.reddit.com/r/pihole/comments/ek67lr/psa_zram_in_buster_literally_download_more_ram/

* STOP THE SWAP

`sudo dphys-swapfile swapoff`

* Install ZRAM 

`sudo apt-get install -y zram-tools`

* Edit config file

By default this package will create a **256MB swap drive** : Edit `/etc/default/zramswap`

`sudo nano /etc/default/zramswap`

Uncomment line : **PERCENTAGE** and set to 

`PERCENTAGE=50`

```
sudo systemctl enable zramswap
sudo systemctl restart zramswap
```

**REBOOT**

* Check : 

`grep zram /proc/swaps`

## Set Timezone : 

```bash
sudo timedatectl set-timezone Europe/Paris
```

## Enable container features

We need to enable container features in the kernel, edit ``/boot/cmdline.txt`` and add the following to the end of the line:

```
 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
```

## Update Kernel :

```
sudo rpi-update
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
- 192.168.2.42

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

`passwd`


## (Bonus) External storage configuration :

> from https://www.raspberrypi.org/documentation/configuration/external-storage.md