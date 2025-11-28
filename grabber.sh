#!/bin/bash

dir='/home/aichac/workspace/grabber'

echo $(date +%d.%m.%Y) > $dir/output/global.log

echo "---- HOSTNAME ----" >> $dir/output/global.log
hostname | cut -d"." -f1 >> $dir/output/global.log

echo "---- BIOS VERSION ----" >> $dir/output/global.log
sudo dmidecode -t bios | grep Version | head -n3 >> $dir/output/global.log

echo "---- INFO CPU ----" >> $dir/output/global.log
inxi -c | grep CPU >> $dir/output/global.log

echo "---- KERNEL INFOS ----" >> $dir/output/global.log
uname -mr >> $dir/output/global.log

echo "---- INFOS ----" >> $dir/output/global.log
free -h >> $dir/output/global.log
lsblk >> $dir/output/global.log
df -h | grep /dev/sda1/ >> $dir/output/global.log

echo "---- CPU Temp ----" >> $dir/output/global.log
sensors | grep Package >> $dir/output/global.log

declare -a DEVICES 
mapfile -t DEVICES < <(lsblk -dn -o NAME |grep -v loop)

declare -A FILES
FILES=(
	["sources_list.file"]="/etc/apt/sources.list*"
	["passwd.file"]="/etc/passwd"
	["group.file"]="/etc/group"
)


for i in ${!DEVICES[@]}; do
   echo "${DEVICES[$i]}" >> $dir/output/global.log 
done 

echo "---- END ----" >> $dir/output/global.log
