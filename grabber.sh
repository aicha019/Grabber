#!/bin/bash

dir='/home/aichac/workspace/grabber'

echo $(date) > $dir/output/global.log

echo "---INFOS---" >> $dir/output/gobal.log

free -h >> $dir/output/global.log
lsblk > $dir/output/gloal.log
df -h | grep /dev/sda1 >> $dir/output/global.log
echo "--- CPU temp---" >> $dir/output/global.log
sensors | grep Package >> $dir/outputt/global.log


echo "--- END---" >> $dir/output/global.log
