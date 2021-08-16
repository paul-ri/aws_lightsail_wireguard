# Raspberry Pi
Used as a pi-hole and Wireguard peer to the Wireguard server and provide access to internal network from other peers.

## Installation - OpenWRT
1. Follow https://openwrt.org/toh/raspberry_pi_foundation/raspberry_pi with some following extra details
2. Download the "Firmware OpenWrt Install" file from https://firmware-selector.openwrt.org/
3. Use `dd` to install it on the SD card
4. Plug raspberrypi it to your network
   1. On your laptop, first `ip a add 192.168.1.3/24 dev eth0`
   2. Open pi's UI on http://192.168.1.1
5. In Network->Interfaces, change the lan interface to be a DHCP client instead of a static IP. Apply and find the IP of
   the pi from your router.
6. Remove the temporary IP on your laptop `sudo ip a del 192.168.1.3/24 dev eth0`
7. SSH to the pi and
   1. Update: `opkg update`
   2. USB to ethernet:
```
opkg install kmod-usb-net-rtl8152 kmod-usb-net-asix-ax88179
? kmod-usb-net
```
   2. Modemmanager: https://openwrt.org/docs/guide-user/network/wan/wwan/modemmanager
```
opkg install modemmanager usb-modeswitch luci-proto-modemmanager
# Try the next ones one by one
mbim-utils qmi-utils
luci-proto-qmi kmod-usb-net-qmi-wwan libqmi uqmi
kmod-usb-core kmod-usb-serial-wwan kmod-usb-wdm
libqrtr-glib wwan
```
### Wireguard
1. `opkg install luci-app-wireguard wireguard-tools kmod-wireguard`


## Installation - Arch Linux ARM
### Default setup
1. https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
2. Place Wi-Fi config in `/etc/netctl/<friendly_connection_name>`
```
Description=""
Interface=wlan0
Connection=wireless
Security=wpa-configsection
IP=dhcp
WPAConfigSection=(
	'ssid="<SSID>"'
	'key_mgmt=WPA-PSK'``
	'psk="<passphrase>"'
	'# Potential settings for some WPA2 connections like a Freebox (France)'
	'#key_mgmt=WPA-PSK'
	'#proto=RSN'
	'#pairwise=CCMP'
	'#group=CCMP'
	'#auth_alg=OPEN'
)
```
3. Boot and login with `alarm:alarm` and escalate to root with `root:root`
4. `loadkeys uk`
5. Create user `useradd -m -g users -G wheel,sys paul`
6. Create password for new user `passwd paul`
7. `pacman -Syu; pacman -S sudo`
8. Add sudoers `visudo /etc/sudoers.d/paul`
```
%wheel ALL=(ALL) ALL
Defaults passwd_timeout=0
```
9. Run as root:
```bash
echo "KEYMAP=uk" | sudo tee /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/Europe/London "/etc/localtime"
echo "LANG=en_GB.UTF-8" > /etc/locale.conf
sed 's/#en_GB/en_GB/' -i /etc/locale.gen
locale-gen
```
10. Login as `paul`
11. Install yay https://github.com/Jguer/yay
12. Install common packages: `sudo pacman -S vim fish fzf wget`
13. Default to fish `chsh -s /usr/bin/fish`

### Extra
1. `sudo pacman -S rsync exa rofi sway kitty bat ranger`

### pi-hole
1. `yay pi-hole-server`
2. https://wiki.archlinux.org/title/Pi-hole#Pi-hole_server
3. https://wiki.archlinux.org/title/Pi-hole#Failed_to_start_Pi-hole_FTLDNS_engine
4. Set a static IP to the eth0 interface
5. `vim /etc/pihole/setupVars.conf` and set the right IPs 
6. Open http://localhost/admin and enable DHCP in the settings

### Wireguard
1. `pacman -S wireguard-tools`
2. `scp ../wg_client_configs/wg0-raspberrypi.conf <pi>:/etc/wireguard/wg0.conf`
3. `systemctl enable --now wg-quick@wg0`

### wwan
1. `sudo pacman -S networkmanager`
2. Follow steps from vimwiki

## Firewall
1. `echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf`
### Firewalld
1. `pacman -S firewalld`
2. `systemctl enable --now firewalld`
```bash
firewall-cmd --zone external --change-interface wwan0
firewall-cmd --zone trusted --change-interface eth0
firewall-cmd --zone trusted --change-interface wlan0
firewall-cmd --zone trusted --add-masquerade
firewall-cmd --set-default-zone trusted
firewall-cmd --runtime-to-permanent
```
4. OR?
```bash
firewall-cmd --zone external --change-interface wwan0
firewall-cmd --zone home --change-interface eth0
firewall-cmd --zone home --add-masquerade
firewall-cmd --runtime-to-permanent
```
5. With?
```bash
firewall-cmd --add-service=http --add-service=https --add-service=dns --add-service=dhcp --add-service=dhcpv6 --add-service=ssh --zone trusted
firewall-cmd --runtime-to-permanent
firewall-cmd --zone trusted --set-target ACCEPT --permanent
firewall-cmd --reload
```
#### Attempt again
From https://forums.centos.org/viewtopic.php?f=56&t=74241&sid=ae9dc6228930a0a2ce2aa7e15e702119&start=10
they state the following are outdated
https://linuxize.com/post/how-to-configure-and-manage-firewall-on-centos-8/
https://www.cyberciti.biz/faq/how-to-set-up-a-firewall-using-firewalld-on-centos-8/
due to CentOS 8.1 out and firewalld using nftables

```bash
firewall-cmd --zone external --change-interface wwan0
firewall-cmd --zone external --add-masquerade
firewall-cmd --zone trusted --change-interface eth0
firewall-cmd --set-default-zone trusted
firewall-cmd --runtime-to-permanent

firewall-cmd --zone trusted --set-target ACCEPT --permanent
firewall-cmd --reload
```

### nftables
### script

```bash
touch /etc/nftables/example_firewall.nft
chown root /etc/nftables/example_firewall.nft
chmod u+x /etc/nftables/example_firewall.nft
```

```nft
#!/usr/sbin/nft -f
define INET_DEV = etho0
```
1. Add our script in `/etc/sysconfig/nftables.conf` and comment out the others
2. `systemctl enable --now nftables`

### Resources
* https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/getting-started-with-nftables_configuring-and-managing-networking

## Installation - Ubuntu
**On a host PC with the SD card plugged in**
1. Download [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit)
2. Copy image on SD card  
  `sudo dd if=<raspios-buster-armhf-lite.img> of=<dest> bs=4M status=progress conv=sync`
3. Enable SSH by mounting boot and drop a file called `ssh`
4. Enable Wi-Fi by editing the `/etc/wpa_supplicant/wpa_supplicant.conf` file in the system partition:
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=GB

network={
	ssid="<SSID>"
	psk="<passphrase>"
    # Potential settings for some WPA2 connections like a Freebox (France)
	#key_mgmt=WPA-PSK
	#proto=RSN
	#pairwise=CCMP
	#group=CCMP
	#auth_alg=OPEN
}
```
5. Copy the Raspberry Pi Wireguard config file to `/etc/wireguard/wg0.conf`

