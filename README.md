# Raspberry Install Scripts
Scripts and configuration tunning i use to setup my raspberry cluster.

## Sources : 
* http://www.pidramble.com/wiki
* https://gitlab.com/xavki/raspberry-tricks

# Enable SSH 
> from https://www.raspberrypi.org/documentation/remote-access/ssh/

Add a file named `ssh` at the root path of the boot partition of the SDCARD before running it

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
