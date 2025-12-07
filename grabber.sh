#!/bin/bash

# ====================================================================
# CONFIGURATION
# ====================================================================
DIR="/home/aichac/workspace/grabber"

# Réinitialisation du log
DATE=$(date '+%d%m%Y')
JOURNAL="$DIR/output/journal$DATE.log" 

echo "$(date '+%Y-%m-%d %H:%M:%S')" > "$JOURNAL"
echo "" >> "$JOURNAL"

# Fonction helper pour écrire dans le log
ecrire() {
    echo "$1" >> "$JOURNAL"
}

# ======================================
# HOSTNAME
# ======================================
ecrire "[HOSTNAME]"
HOSTNAME=$(hostname)
ecrire "HOSTNAME=$HOSTNAME"
ecrire ""


# ======================================
# HARDWARE
# ======================================
ecrire "[HARDWARE]"

# CPU Info
CPU_MODEL=$(lscpu | grep -i 'Model name\|Nom de modèle' | cut -d: -f2 | xargs)
CPU_CORES=$(lscpu | grep -i 'Core(s) per socket\|Cœur(s) par socket' | awk '{print $4}')
CPU_THREADS=$(lscpu | grep -i 'Thread(s) per core\|Thread(s) par cœur' | awk '{print $4}')
CPU_SERIAL=$(sudo dmidecode -t processor 2>/dev/null | grep -i ID | head -n1 | awk '{print $3}')

ecrire "CPU_MODEL=$CPU_MODEL"
ecrire "CPU_CORES=$CPU_CORES"
ecrire "CPU_THREADS=$CPU_THREADS"
ecrire "CPU_SERIAL=${CPU_SERIAL:-}"
ecrire ""

# RAM
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/^Mem:/ {print $3}')
ecrire "RAM_TOTAL=$RAM_TOTAL"
ecrire "RAM_USED=$RAM_USED"
ecrire ""

# SWAP
SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')
SWAP_USED=$(free -h | awk '/^Swap:/ {print $3}')
ecrire "SWAP_TOTAL=$SWAP_TOTAL"
ecrire "SWAP_USED=$SWAP_USED"
ecrire ""

# Disk
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
ecrire "DISK_TOTAL=$DISK_TOTAL"
ecrire "DISK_USED=$DISK_USED"
ecrire ""

# Temperature
TEMP_FILE="/sys/class/thermal/thermal_zone0/temp"
if [ -f "$TEMP_FILE" ]; then
    TEMPERATURE=$(awk '{printf "%.1f°C\n", $1/1000}' "$TEMP_FILE")
else
    TEMPERATURE="Unavailable on virtual machines"
fi
ecrire "TEMPERATURE=$TEMPERATURE"
ecrire ""

# Network Interfaces
ecrire "INTERFACES="
ip -o link show | awk -F': ' '{print $2}' >> "$JOURNAL"
ecrire ""

IPV4=$(ip -4 addr show | grep inet | grep -v '127.0.0.1' | awk '{print $2}' | head -n1)
ROUTING=$(ip route show | head -n1)
ecrire "IPV4=$IPV4"
ecrire "ROUTING=$ROUTING"
ecrire ""

# ======================================
# SOFTWARE
# ======================================
ecrire ""
ecrire "[SOFTWARE]"

OS=$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d '=' -f2 | tr -d '"')
KERNEL=$(uname -r)
ecrire "OS=$OS"
ecrire "KERNEL=$KERNEL"

# Packages
ecrire "PACKAGES_INSTALLED="
apt list --installed 2>/dev/null >> "$JOURNAL"
ecrire ""

SNAP_COUNT=$(snap list 2>/dev/null | wc -l)
FLATPAK_COUNT=$(flatpak list 2>/dev/null | wc -l)
ecrire "SNAP_PACKAGES=$SNAP_COUNT"
ecrire "FLATPAK_PACKAGES=$FLATPAK_COUNT"
ecrire ""

# ======================================
# CONFIG
# ======================================
ecrire "[CONFIG]"

ecrire "SOURCES.LIST="
grep -v '^#' /etc/apt/sources.list* 2>/dev/null >> "$JOURNAL"
ecrire ""

ecrire "FSTAB="
grep -v '^#' /etc/fstab 2>/dev/null >> "$JOURNAL"
ecrire ""

ecrire "CRONTAB="
crontab -l 2>/dev/null | grep grabber.sh >> "$JOURNAL"
ecrire ""

# ======================================
# END
# ======================================
ecrire ""
ecrire "[END]"

