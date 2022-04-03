³# Raspberry Pi
Used as a pi-hole and Wireguard peer to the Wireguard server and provide access to internal network from other peers.

* **CPU:** Broadcom BCM2836
* **target:** bcm27xx
* **subtarget:** bcm2709
* **package download:** [arm_cortex-a7_neon-vfpv4](https://openwrt.org/docs/techref/instructionset/arm_cortex-a7_neon-vfpv4)

## Installation - OpenWRT
1. Follow https://openwrt.org/toh/raspberry_pi_foundation/raspberry_pi with some following extra details
2. Download the "Firmware OpenWrt Install" file from https://firmware-selector.openwrt.org/
3. Use `dd` to install it on the SD card
4. Connect to the pi and install these packages: `usb-modeswitch luci-proto-modemmanager wwan kmod-usb-net-qmi-wwan`
  1. Share the internet from another device to allow OpenWRT to download the packages.
6. Reboot

### DNS
1. In OpenWRT: Network > interfaces > lan > dhcp server > advanced settings > dhcp-options
2. Type `6,<IP address of pihole>`

### Wireguard
1. `opkg install luci-app-wireguard wireguard-tools kmod-wireguard`
