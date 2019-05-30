#!/usr/bin/env bash

if [ $(mount | grep mmcblk0p2 | grep -o 'rw' || echo ro) = "ro" ]; then
        echo "Please make file system read-write and rerun"
        exit;
fi

# Given a filename, a regex pattern to match and a replacement string:
# Replace string if found, else no change.
# (# $1 = filename, $2 = pattern to match, $3 = replacement)
replace() {
	grep $2 $1 >/dev/null
	if [ $? -eq 0 ]; then
		# Pattern found; replace in file
		sed -i "s/$2/$3/g" $1 >/dev/null
	fi
}

if grep -q "10.0.0.10" /boot/appliance/etc/network/interfaces; then
        read -p 'Current IP: 10.0.0.10 Please change IP to: 10.0.0.' new_ip
	replace /boot/appliance/etc/network/interfaces "10.0.0.10" "10.0.0.$new_ip"
	echo "Please update the CS System spreadsheet with this new IP"
fi

if [ $(hostname) = "raspberrypi" ]; then
        read -p 'Current hostname: raspberrypi. Please change hostname to: ' new_hostname
        [ ! -z "$new_hostname" ] && echo "$new_hostname" | sudo tee -a /etc/hostname
        [ ! -z "$new_hostname" ] && echo "127.0.1.1       $new_hostname" | sudo tee -a /etc/hosts
        [ ! -z "$new_hostname" ] && sudo hostnamectl set-hostname "$new_hostname"
	echo "Please update the CS System spreadsheet with this new hostname"
fi

read -p 'Enter the current date [YYYY-MM-DD HH:MM] or hit enter to skip: ' datetime
[ ! -z "$datetime" ] && sudo date -s "$datetime"

sudo apt update
sudo apt install -y git vim screen python3-pip python-pip

#### UDPCOMMS
git clone https://github.com/stanfordroboticsclub/UDPComms.git
sudo bash UDPComms/install.sh

#### COMMAND
git clone https://github.com/stanfordroboticsclub/RoverCam.git
sudo bash RoverCam/install.sh

