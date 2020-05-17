# Raspberry Install Scripts
Scripts and configuration tunning i use to setup my raspberry cluster.

## Sources : 
* http://www.pidramble.com/wiki
* https://gitlab.com/xavki/raspberry-tricks
* https://thewalkingdevs.io/project_armadillo/

# Download and install operating system :
> from https://www.raspberrypi.org/downloads/raspbian/

1. Download rapsbian lite version.
2. Donwload Etcher balena : https://www.balena.io/etcher/
3. Copy raspbian iso onto sdcard with etcher.

# Enable x64 Arm Architecture to use full power of new BROADCOM Arm-v8 CPU
> from https://www.raspberrypi.org/forums/viewtopic.php?t=250730
`sudo rpi-update`

If you want to switch to 64-bit kernel add to **config.txt**
`arm_64bit=1`

# Enable SSH 
> from https://www.raspberrypi.org/documentation/remote-access/ssh/

Add a file named `ssh` at the root path of the boot partition of the SDCARD before running it

# Set Static IP from your Router

I personaly use an Ubiquity Edge Router X for routing my internal cluster.
This router is setup to give static IP for my differents Raspberry Pi :

In a subnet : 192.168.2.0/24
I have : 
-	192.168.2.39
-	192.168.2.40
-	192.168.2.41
- 	192.168.2.42

# Set a Bastion as a passthrough for getting to your machines

I use my edge router as a Firewall to monitor in & out bound traffic and setup firewall Rules, i also use it as a bastion to SSH to my cluster. I have disabled port 22 from outside the LAN of the router. It's is impossible from the outside to reach my machines with the ssh port.

# Connect with SSH keys : 
> from https://www.linode.com/docs/security/authentication/use-public-key-authentication-with-ssh/

Generate key on the desktop :

`ssh-keygen -b 4096`

Copy the public key on the servers or remote machine :

`ssh-copy-id your_username@192.0.2.0`

# Increase swap size
> from https://wpitchoune.net/tricks/raspberry_pi3_increase_swap_size.html

* STOP THE SWAP

`sudo dphys-swapfile swapoff`
* MODIFY THE SIZE OF THE SWAP

As root, edit the file `/etc/dphys-swapfile` and modify the variable **CONF_SWAPSIZE** :
> CONF_SWAPSIZE=1024

and run `sudo dphys-swapfile setup` which will create and initialize the file.

* START THE SWAP
`sudo dphys-swapfile swapon`

# Optimize Power Consumption
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

# Protect : 
> from https://www.linuxnorth.org/five_minute_firewall/

I am using a physical router/firewall to isolate my raspberry cluster from my local network. I have configured port forwarding from my ISP router to my custom router ip.

> from https://blog.laslabs.com/2013/04/change-webui-port-ubiquiti-edge-router-lite/

Changing default webui port for Edge Router
