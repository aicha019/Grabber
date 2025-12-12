#!/bin/bash
# ============================================================
# Script : grabber.sh
# Auteur : Aicha FOFANA
# Date   : 2025-12-10
# Version: 0.0.1
#
# Description :
#   Script permettant de collecter différentes informations
#   système (hardware et software) :
#   - informations CPU, RAM, disques, périphériques
#   - services systemd
#   - configuration réseau et DNS
#   - sources APT et paquets installés
#
#   Le script génère plusieurs fichiers de sortie ainsi qu’un
#   résumé dans summary.txt.
#
# Usage :
#   ./grabber.sh
#
# Dépendances :
#   - inxi (optionnel)
#   - droits d’écriture dans le dossier /opt/grabber
#   - droits d’écriture dans /var/log/grabber
#
# ============================================================

DIR="/home/aichac/workspace/grabber"
SUCCESS_LOG="$DIR/grabber-success.log"
ERROR_LOG="$DIR/grabber-error.log"
SUM="$DIR/summary.txt"

mkdir -p "$DIR"

tee $SUCCESS_LOG $ERROR_LOG <<EOF1
++++++++++++++ Début de grabber ++++++++++++++++
================ Récupération des informations sur les paquets ================
EOF1

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF2
================ Copie du fichier de configuration /etc/apt/sources.list ================
EOF2

cat /etc/apt/sources.list 2>>$ERROR_LOG > $DIR/sources-list.file

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF3
================ Récupération de la liste des paquets installés ================
EOF3

apt list --installed 2>>$ERROR_LOG > $DIR/apt-installed.cmd \
    && echo "[OK]: Fichier apt-installed.cmd généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de apt-installed.cmd" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF4
================ Liste des périphériques USB ================
EOF4

lsusb 2>>$ERROR_LOG > $DIR/lsusb.cmd \
    && echo "[OK]: Fichier lsusb.cmd généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de lsusb.cmd" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF5
================ Informations sur le processeur ================
EOF5

lscpu 2>>$ERROR_LOG > $DIR/lscpu.cmd \
    && echo "[OK]: Fichier lscpu.cmd généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de lscpu.cmd" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF6
================ Liste des groupes ================
EOF6

cat /etc/group 2>>$ERROR_LOG > $DIR/group.file \
    && echo "[OK]: Fichier group.file généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de group.file" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF7
================ Liste des utilisateurs ================
EOF7

cat /etc/passwd 2>>$ERROR_LOG > $DIR/passwd.file \
    && echo "[OK]: Fichier passwd.file généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de passwd.file" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF8
================ Informations mémoire ================
EOF8

lsmem 2>>$ERROR_LOG > $DIR/lsmem.cmd \
    && echo "[OK]: Fichier lsmem.cmd généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de lsmem.cmd" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF9
================ Liste du matériel ================
EOF9

lspci 2>>$ERROR_LOG > $DIR/lspci.cmd \
    && echo "[OK]: Fichier lspci.cmd généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de lspci.cmd" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF10
================ Information démarrage services ================
EOF10

systemd-analyze 2>>$ERROR_LOG > $DIR/systemd-analyze.cmd \
    && echo "[OK]: Fichier systemd-analyze.cmd généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de systemd-analyze.cmd" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF11
================ Performances démarrage services ================
EOF11

systemd-analyze blame 2>>$ERROR_LOG > $DIR/systemd-blame.cmd \
    && echo "[OK]: Fichier systemd-blame.cmd généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de systemd-blame.cmd" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF12
================ Liste des réseaux ================
EOF12

cat /etc/network/interfaces 2>>$ERROR_LOG > $DIR/etc-network-interfaces.file \
    && echo "[OK]: Fichier etc-network-interfaces.file généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de etc-network-interfaces.file" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF13
================ Disques et Partitions ================
EOF13

lsblk 2>>$ERROR_LOG > $DIR/lsblk.cmd \
    && echo "[OK]: Fichier lsblk.cmd généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de lsblk.cmd" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF14
================ Configuration DNS ================
EOF14

cat /etc/resolv.conf 2>>$ERROR_LOG > $DIR/etc-resolv-conf.file \
    && echo "[OK]: Fichier etc-resolv-conf.file généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de etc-resolv-conf.file" | tee -a $ERROR_LOG

tee -a $SUCCESS_LOG $ERROR_LOG <<EOF15
================ SSH Config ================
EOF15

cat /etc/ssh/ssh_config 2>>$ERROR_LOG > $DIR/ssh_config.file \
    && echo "[OK]: Fichier ssh_config.file généré" | tee -a $SUCCESS_LOG \
    || echo "[ECHEC]: Erreur à la génération de ssh_config.file" | tee -a $ERROR_LOG

declare -A FILES=(
    ["sources-list.file"]="/etc/apt/sources.list"
    ["passwd.file"]="/etc/passwd"
    ["group.file"]="/etc/group"
    ["etc-resolv-conf.file"]="/etc/resolv.conf"
    ["etc-network-interfaces.file"]="/etc/network/interfaces"
    ["ssh_config.file"]="/etc/ssh/ssh_config"
)

declare -A CMD=(
    ["systemd-analyze.cmd"]="systemd-analyze"
    ["systemd-blame.cmd"]="systemd-analyze blame"
    ["lspci.cmd"]="lspci"
    ["lsmem.cmd"]="lsmem"
    ["lscpu.cmd"]="lscpu"
    ["lsusb.cmd"]="lsusb"
    ["apt-installed.cmd"]="apt list --installed"
)

treat_file() {
    grep -v '^#' "$2" | grep -v '^$' > "$DIR/$1"
}

for f in "${!FILES[@]}"; do
    treat_file "$f" "${FILES[$f]}"
done

treat_cmd() {
    eval "$2" > "$DIR/$1" 2>>$ERROR_LOG
}

for file in "${!FILES[@]}"; do
    treat_file "$file" "${FILES[$file]}"
done

for f in "${!CMD[@]}"; do
    treat_cmd "$f" "${CMD[$f]}"
done

# ====================== HARDWARE ==========================

CPU=$(lscpu | grep "Model name" | awk -F': ' '{print $2}')
RAM=$(free -h | awk '/Mem:/ {print $2}')
DISK=$(lsblk -dn -o SIZE | head -n1)
OS=$(lsb_release -d | cut -f2)
KERNEL=$(uname -r)

CPU_CORES_NUMBER=$(lscpu | awk -F': ' '/Core\(s\)/ {print $2}')
CPU_THREADS_NUMBER=$(lscpu | awk -F': ' '/CPU\(s\):/ {print $2}')

CPU_FREQUENCY_CUR=$(awk -F': ' '/cpu MHz/ {print $2; exit}' /proc/cpuinfo)
CPU_FREQUENCY_MIN=$CPU_FREQUENCY_CUR
CPU_FREQUENCY_MAX=$CPU_FREQUENCY_CUR

GPU_MODEL=$(lspci | grep -E "VGA|3D" | sed 's/.*controller: //')
[[ -z "$GPU_MODEL" ]] && GPU_MODEL="Unknown GPU"

GPU_MEMORY="N/A (VMWARE)"


MB_SERIAL=$(sudo dmidecode -s baseboard-serial-number)
[[ -z "$MB_SERIAL" ]] && MB_SERIAL="Unknown (VM)"

RAM_SLOTS_NUMBER=$(sudo dmidecode -t memory | grep -c "Memory Device")
RAM_NUMBER=$(sudo dmidecode -t memory | grep "Size:" | grep -v "No Module Installed" | wc -l)
RAM_O_SIZE=$(sudo dmidecode -t memory | grep "Size:" | grep -v "No Module Installed" | awk -F': ' '{print $2}' | tr '\n' ',')
RAM_O_FREQUENCE=$(sudo dmidecode -t memory | grep "Speed:" | grep -v "Unknown" | awk -F': ' '{print $2}' | tr '\n' ',')
RAM_O_SLOTS=$(sudo dmidecode -t memory | grep "Locator:" | awk -F': ' '{print $2}' | tr '\n' ',')

i=0
while read -r size; do
    RAM_i_SIZE=$(echo "$size" | awk '{print $2$3}')
    RAM_i_SLOT=$(sudo dmidecode -t memory | grep -A5 "Memory Device" | grep "Locator:" | sed -n "$((i+1))p" | awk '{print $2}')
    RAM_i_FREQ=$(sudo dmidecode -t memory | grep -A5 "Memory Device" | grep "Speed:" | sed -n "$((i+1))p" | awk '{print $2$3}')

    ((i++))
done < <(sudo dmidecode -t memory | grep "Size:" | grep -v "No Module Installed")

DISK_NUMBER=$(lsblk -dn -o NAME | wc -l)

i=0
for disk in $(lsblk -dn -o NAME); do
    disk_size=$(lsblk -dn -o SIZE "/dev/$disk")

    disk_used=$(df --output=used -B1 /dev/${disk}* 2>/dev/null | tail -n +2 | awk '{sum+=$1} END {print sum}')
    disk_avail=$(df --output=avail -B1 /dev/${disk}* 2>/dev/null | tail -n +2 | awk '{sum+=$1} END {print sum}')

    disk_used_h=$(numfmt --to=iec --suffix=B "$disk_used")
    disk_avail_h=$(numfmt --to=iec --suffix=B "$disk_avail")

    parts=$(lsblk -ln -o NAME "/dev/$disk" | tail -n +2)
    parts_count=$(echo "$parts" | wc -l)

    j=0
    for part in $parts; do
        part_type=$(lsblk -no FSTYPE "/dev/$part")
        [[ -z "$part_type" ]] && part_type="unknown"
        
        part_size=$(lsblk -no SIZE "/dev/$part")

        ((j++))
    done

    ((i++))
done

echo "[HARDWARE]" > "$SUM"

echo "CPU=$CPU" >> "$SUM"
echo "CPU_CORES_NUMBER=$CPU_CORES_NUMBER" >> "$SUM"
echo "CPU_THREADS_NUMBER=$CPU_THREADS_NUMBER" >> "$SUM"
echo "CPU_FREQUENCY_MIN=$CPU_FREQUENCY_MIN" >> "$SUM"
echo "CPU_FREQUENCY_MAX=$CPU_FREQUENCY_MAX" >> "$SUM"
echo "CPU_FREQUENCY_CUR=$CPU_FREQUENCY_CUR" >> "$SUM"

echo "MB_SERIAL=$MB_SERIAL" >> "$SUM"
echo "GPU_MODEL=$GPU_MODEL" >> "$SUM"
echo "GPU_MEMORY=$GPU_MEMORY" >> "$SUM"

echo "RAM=$RAM" >> "$SUM"
echo "RAM_NUMBER=$RAM_NUMBER" >> "$SUM"
echo "RAM_SLOTS_NUMBER=$RAM_SLOTS_NUMBER" >> "$SUM"
echo "RAM_O_SIZE=$RAM_O_SIZE" >> "$SUM"
echo "RAM_O_FREQUENCE=$RAM_O_FREQUENCE" >> "$SUM"
echo "RAM_O_SLOTS=$RAM_O_SLOTS" >> "$SUM"

echo "" >> "$SUM"

echo "DISK=$DISK" >> "$SUM"
echo "DISK_NUMBER=$DISK_NUMBER" >> "$SUM"


echo "DISK${i}_SIZE=$disk_size" >> "$SUM"
    echo "DISK${i}_USED=$disk_used_h" >> "$SUM"
    echo "DISK${i}_AVAILABLE=$disk_avail_h" >> "$SUM"

echo "DISK${i}_PARTS=$parts_count" >> "$SUM"


echo "DISK${i}_PART${j}_TYPE=$part_type" >> "$SUM"
        echo "DISK${i}_PART${j}_SIZE=$part_size" >> "$SUM"


echo "" >> "$SUM"
echo "[SOFTWARE]" >> "$SUM"
echo "OS=$OS" >> "$SUM"
echo "KERNEL=$KERNEL" >> "$SUM"

echo "" >> "$SUM"
echo "Résumé généré avec succès." >> "$SUM"
