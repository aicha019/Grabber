#!/bin/bash
# ============================================================
# Script : grabber.sh
# Auteur : Aicha FOFANA
# Date   : 2025-12-13
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
export LC_ALL=C
export LANG=C

# Vérification des droits root

if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Le script s'éxécute qu'avec sudo "
    echo " Utilise : sudo ./grabber.sh"
    exit 1
fi


DATE_FORMAT=$(date +"%Y-%m-%d_%H-%M-%S")

BASE_DIR="/opt/grabber"
LOG_DIR="/var/log/grabber"
SUCCESS_LOG="$LOG_DIR/grabber-success-$DATE_FORMAT.log"
ERROR_LOG="$LOG_DIR/grabber-error-$DATE_FORMAT.log"
SUM="$BASE_DIR/summary.txt"

# Crée les dossiers si nécessaire
sudo mkdir -p "$BASE_DIR" "$LOG_DIR"
: > "$SUCCESS_LOG"
: > "$ERROR_LOG"

echo "====================== DÉBUT GRABBER =========================="

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
    grep -v '^#' "$2" | grep -v '^$' > "$BASE_DIR/$1" 2>>"$ERROR_LOG"
}

treat_cmd() {
    eval "$2" > "$BASE_DIR/$1" 2>>"$ERROR_LOG"
}

for f in "${!FILES[@]}"; do
    treat_file "$f" "${FILES[$f]}"
done

for c in "${!CMD[@]}"; do
    treat_cmd "$c" "${CMD[$c]}"
done

# ====================== HARDWARE ==========================
CPU=$(lscpu | grep "Model name" | head -n1 | cut -d':' -f2 | sed 's/^ *//;s/ *$//')
CPU_CORES_NUMBER=$(lscpu | grep "Core(s) per socket" | head -n1 | awk '{print $4}')
CPU_THREADS_NUMBER=$(nproc)
CPU_FREQUENCY_MIN=$(lscpu | grep "CPU min MHz" | head -n1 | awk '{print $4}')
CPU_FREQUENCY_MAX=$(lscpu | grep "CPU max MHz" | head -n1 | awk '{print $4}')
CPU_FREQUENCY_CUR=$(awk -F: '/cpu MHz/ {print $2; exit}' /proc/cpuinfo | sed 's/^ *//;s/ *$//')

GPU_MODEL=$(lspci | grep -i 'vga\|3d' | cut -d':' -f3- | head -n1 | sed 's/^ //')
GPU_MEMORY=$(free -h | awk '/Mem:/ {print $2}') 

MB_SERIAL=$(cat /sys/class/dmi/id/board_serial 2>/dev/null)
[[ -z "$MB_SERIAL" ]] && MB_SERIAL="Not provided"

RAM=$(free -h | awk '/Mem:/ {print $2}')
RAM_NUMBER=$(sudo dmidecode -t memory 2>/dev/null | grep "Size:" | grep -v "No Module Installed" | wc -l)
RAM_SLOTS_NUMBER=$(sudo dmidecode -t memory 2>/dev/null | grep -c "Memory Device")
RAM_O_SIZE=$(sudo dmidecode -t memory 2>/dev/null | grep "Size:" | grep -v "No Module Installed" | awk -F': ' '{print $2}' | tr '\n' ',' | sed 's/,$//')
RAM_O_FREQUENCE=$(sudo dmidecode -t memory 2>/dev/null | grep "Speed:" | grep -v "Unknown" | awk -F': ' '{print $2}' | tr '\n' ',' | sed 's/,$//')
RAM_O_SLOTS=$(sudo dmidecode -t memory 2>/dev/null | grep "Locator:" | awk -F': ' '{print $2}' | tr '\n' ',' | sed 's/,$//')



DISK=$(lsblk -dn -o SIZE /dev/sda)
DISK_NUMBER=$(lsblk -dn -o NAME | wc -l)
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_AVAILABLE=$(df -h / | awk 'NR==2 {print $4}')


# ====================== SOFTWARE ==========================

OS=$(lsb_release -d 2>/dev/null | cut -f2)
KERNEL=$(uname -r)
DNS=$(grep -E "nameserver" /etc/resolv.conf | tr '\n' ';')

# ====================== SUMMARY ==========================

echo "[HARDWARE]" > "$SUM"

echo "CPU=$(echo $CPU | sed 's/^[ \t]*//')" >> "$SUM"
echo "CPU_CORES_NUMBER=$CPU_CORES_NUMBER" >> "$SUM"
echo "CPU_THREADS_NUMBER=$CPU_THREADS_NUMBER" >> "$SUM"
echo "CPU_FREQUENCY_MIN=$(echo $CPU_FREQUENCY_MIN | sed 's/^ *//;s/ *$//')" >> "$SUM"
echo "CPU_FREQUENCY_MAX=$(echo $CPU_FREQUENCY_MAX | sed 's/^ *//;s/ *$//')" >> "$SUM"
echo "CPU_FREQUENCY_CUR=$(echo $CPU_FREQUENCY_CUR | sed 's/^ *//;s/ *$//')" >> "$SUM"

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
echo "DISK1_USED=$DISK_USED" >> "$SUM"
echo "DISK1_AVAILABLE=$DISK_AVAILABLE" >> "$SUM"

i=1
for disk in $(lsblk -dn -o NAME); do
    disk_size=$(lsblk -dn -o SIZE "/dev/$disk")
    echo "DISK${i}_SIZE=$disk_size" >> "$SUM"

    parts=$(lsblk -ln -o NAME "/dev/$disk" | tail -n +2)
    parts_count=$(echo "$parts" | wc -l)
    echo "DISK${i}_PARTS=$parts_count" >> "$SUM"

    j=1
    for part in $parts; do
        part_type=$(lsblk -no FSTYPE "/dev/$part")
        part_size=$(lsblk -no SIZE "/dev/$part")

        echo "DISK${i}_PART${j}_TYPE=$part_type" >> "$SUM"
        echo "DISK${i}_PART${j}_SIZE=$part_size" >> "$SUM"
        ((j++))
    done

    ((i++))
done

echo "" >> "$SUM"
echo "[SOFTWARE]" >> "$SUM"
echo "OS=$OS" >> "$SUM"
echo "KERNEL=$KERNEL" >> "$SUM"
echo "DNS=$DNS" >> "$SUM"


echo "" >> "$SUM"

echo "====================== The end, byeee ====================== " | tee -a "$SUCCESS_LOG"
