#!/bin/bash

dir="/home/aichac/workspace/grabber"
log="$dir/output/global.log"

ecrire() {
    echo "$1" >> "$log"
}

if [ $EUID -ne 1000 ]; then
    echo "Erreur : UID != 1000"
    exit 1
fi

echo $(date +%d.%m.%Y) > "$log"
echo "" >> "$log"

echo "---- HOSTNAME ----" >> "$log"
hostname | cut -d'.' -f1 >> "$log"
echo "" >> "$log"

echo "---- BIOS VERSION ----" >> "$log"
sudo dmidecode -t bios | grep Version | head -n3 >> "$log"

echo "---- INFO CPU ----" >> "$log"
inxi -c | grep CPU >> "$log"

echo "---- KERNEL INFOS ----" >> "$log"
uname -mr >> "$log"
echo "" >> "$log"

echo "---- INFOS ----" >> "$log"
free -h >> "$log"
lsblk | grep -v loop >> "$log"
df -h | grep /dev/sda1/ >> "$log"
echo "" >> "$log"

echo "---- CPU Temp ----" >> "$log"
sensors | grep Package >> "$log"
echo "" >> "$log"

declare -a DEVICES 
mapfile -t DEVICES < <(lsblk -dn -o NAME | grep -v loop)

echo "--- LISTE DEVICES ---" >> "$log"
for d in "${DEVICES[@]}"; do
    echo "$d" >> "$log"
done
echo "" >> "$log"


declare -A FILES
FILES=(
	["sources_list.file"]="/etc/apt/sources.list*"
	["passwd.file"]="/etc/passwd"
	["group.file"]="/etc/group"
)

echo "---- CONTENU DES FICHIERS ----" >> "$log"
for key in "${!FILES[@]}"; do
    echo "---- FICHIER : ${FILES[$key]} ----" >> "$log"
    cat ${FILES[$key]} >> "$log"
    echo "" >> "$log"
done

echo "---- END ----" >> >> "$log"

