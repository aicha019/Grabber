#!/bin/bash

echo "Bonjour $USER"

lsblk > output/disks.cmd
df -h > output/space.cmd
