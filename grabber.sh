#!/bin/bash

dir='/home/aichac/workspace/grabber'

echo $(date +\%d/\%m/\%Y) >> $dir/output/global.log

echo "---HOSTNAME---" >> $dir/output/global.log
hostnamectl | grep "Static hostname" | cut -d: -f2 | xargs>> $dir/output/global.log

echo "---BIOS VERSION---" >> $dir/output/global.log
sudo dmidecode -t bios | head -n 5 >> $dir/output/global.log


echo "---INFOS CPU---" >> $dir/output/global.log
inxi -C | head -n 1 >>$dir/output/global.log

echo "---KERNEL INFO---" >> $dir/output/global.log
uname -mrs >> $dir/output/global.log

echo "---MEMOIRE---" >> $dir/output/global.log
free -h >> $dir/output/global.log

echo "---DISKS---" >> $dir/output/global.log
lsblk | head -n 10 >> $dir/output/global.log
df -h | grep  "dev/sda1" >> $dir/output/global.log

echo "--- CPU temp---" >> $dir/output/global.log
sensors | grep Package | head -n 3 >> $dir/output/global.log


echo "--- END---" >> $dir/output/global.log
