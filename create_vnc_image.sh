#!/bin/bash

DEBIAN_FRONTEND=noninteractive
  
cp data/sources.list /etc/apt/sources.list
apt-get update
apt-get -y --allow-unauthenticated install software-properties-common

#
#cp data/sources.list /etc/apt/sources.list
add-apt-repository -y ppa:mozillateam/ppa
add-apt-repository -y ppa:ondrej/php
apt-get update --fix-missing
apt-get -y --allow-unauthenticated upgrade

apt-get -y --allow-unauthenticated install lxde-core xorg lxde-common firefox iftop htop iotop sudo iptables monit unzip

#users
useradd -m -s /bin/bash -p '$1$hLwznRBR$bhQnFoTppZXh4Tdj/G0Q8/' adam
useradd -m -s /bin/bash -p '$1$dhLdotAc$xQvo00ZNcuU5SGbxdtyN60' long
#echo "root:aaaaaa" | chpasswd
cp data/sudoers /etc/sudoers
passwd root -l

#edit ssh
cp data/sshd_config /etc/ssh/sshd_config
mkdir /home/adam/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCq6ahDmE4VRxP+0NMIkbnY98QvQb7YsrE8qlu1GEgc1DhzzLJWYv7SYxcpup/hCHvoCkn8RgmxiqJ/eHAwWKMsDmRmMuJYT24kKXCCiw3Emw3plfS16Bf+xyKWEQyrNYiiwRx92yY7cHzCyWUUDzL+DttA3g5RMsJ1d2KD+mABAxbZKM56iE/KZdf2f9uUlyJ2+CWFYSOoWBI0ODO7Vi4suDMo5FMTdx9SYTlWNVS00W72SXieDfdZtYEYZSv1cZIk9iZ2UEUkP/TN3DsT2DQnmVvBIOXFYKW8oH/p486DnDox018xClSoycS/xe0Iu8U9M5UtqPmp9l0m4+E8J1kRdbMnolU7xjHeX5lNaMRkQODx1bqRvr8hBD1O1bDdmAd/NJO5oKeO9x3ebEI1AuZCHq2EoUTBRgWsJcpc1nacnaAmEH8Z4JdqsGiANQM0csEaPMKe/C5+ny/O/0PK9fDrxWOAkkzxqM39dRMXxS9xg01hGm/JJbcbI+B9M33Vg+hWKN1+OPR+i9Oi7u8zL6SvOoA9V+mXilwy1H6GajPxUBl0785oMR3EoLfu+KZEcHvaLBMryBjfbIpwYgOn/TEPsaXLuw6rJw7MgVMdJEddyUq4TUk4nAoBFo4QtlTg9MAfEYyvVC1sW21rch0HiSbEDvfRq/C6hIv6jBZvS6cx+w== root@mysql1" > /home/adam/.ssh/authorized_keys

chmod 700 /home/adam/.ssh
chmod 640 /home/adam/.ssh/authorized_keys
chown -R adam:adam /home/adam

#monit
cp data/monitrc /etc/monit/monitrc

#swap
sed -i '/^swap/d' /etc/fstab
touch /var/swap.img
chmod 600 /var/swap.img
dd if=/dev/zero of=/var/swap.img bs=512k count=1000
mkswap /var/swap.img
swapon /var/swap.img
echo "/var/swap.img    none    swap    sw    0    0" >> /etc/fstab

#install GUI
apt-get install -y --allow-unauthenticated lubuntu-desktop
#vnc
apt-get -y --allow-unauthenticated install autocutsel tightvncserver
mkdir /home/adam/.vnc
cp data/passwd /home/adam/.vnc/passwd
cp data/xstartup /home/adam/.vnc/xstartup
cp data/vncserver-init /etc/init.d/vncserver
cp data/vncserver /usr/bin/vncserver
update-rc.d vncserver defaults
chmod 600 /home/adam/.vnc/passwd
chown -R adam:adam /home/adam

su adam -c '
vncserver :1
exit
'
sleep 2

#webserver
apt-get -y --allow-unauthenticated install apache2 php5.6 php5.6-curl libapache2-mod-php5.6 php5.6-mcrypt php5.6-mysql
rm -r /var/www/*
cp -r ./sites_html/ /root/
cp -r ./sites /var/www/
rm -r /etc/apache2/*
cp -r apache2/* /etc/apache2/
sed -i 's/libphp5.so/libphp5.6.so/g' /etc/apache2/mods-enabled/php5.load

a2enmod rewrite

# Create desktop environment in some LXDE
cp -r data/.config /home/adam/
chmod 600 /home/adam/.config/lxterminal/lxterminal.conf
chmod 600 /home/adam/.config/pulse/cookie
chmod 600 /home/adam/.config/user-dirs.dirs
chown -R adam:adam /home/adam
pkill xstartup
pkill Xtightvnc
su adam -c '
vncserver :1
exit
'
sleep 2

# This need to be executed before FF application running
# otherwise it will be overwritten
su adam -c '
cp data/firefox.desktop /home/adam/Desktop/
firefox &
pkill firefox
mkdir -p /home/adam/.mozilla
cp -r data/mozilla/firefox-esr /home/adam/.mozilla/firefox
firefox &
sleep 2
exit
'
echo "You can reboot server now. Good-bye!"

