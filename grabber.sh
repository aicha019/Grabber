#!/bin/bash

dir='/home/aichac/workspace/grabber'

echo $(date +%d.%m.%Y) >> $dir/output/global.log

echo "---HOSTNAME---" >> $dir/output/global.log
hostname | cut -d"." -f1 >> $dir/output/global.log

echo "---BIOS VERSION---" >> $dir/output/global.log
sudo dmidecode -t bios | grep -E "Vendor|Version|Release" | head -n3 >> $dir/output/global.log


echo "---INFO CPU---" >> $dir/output/global.log
inxi -C | head -n1 | cut -d: -f2 | xargs >> $dir/output/global.log

echo "---KERNEL INFOS---" >> $dir/output/global.log
uname -mr >> $dir/output/global.log

echo "---MEMOIRE---" >> $dir/output/global.log
free -h | grep "Mem:" >> $dir/output/global.log

echo "---DISK---" >> $dir/output/global.log
df -h | grep "/dev/sda1" >> $dir/output/global.log

echo "---END---" >> $dir/output/global.log

