#!/bin/bash
sudo -i
parted /dev/sdb mklabel msdos
parted /dev/sdb mkpart primary 512 100%
mkfs.xfs /dev/sdb1
mkdir /data
echo `blkid /dev/sdb1 | awk '{print$2}' | sed -e 's/"//g'` /data   xfs   noatime,nobarrier   0   0 >> /etc/fstab
mount /data
yum install -y net-tools ntp git
systemctl enable ntpd.service
systemctl start ntpd.service