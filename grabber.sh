#!/bin/bash
# ============================================================
# Script : grabber.sh
# Auteur : Aicha FOFANA
# Date   : 2025-12-13
# Version: 0.0.3
#
# Description :
#   Script permettant de collecter différentes informations
#   système (hardware et software) et les envoyer à un serveur
#
# Usage :
#   sudo ./grabber.sh [IP_SERVEUR]
# ============================================================

export LC_ALL=C
export LANG=C

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
    echo "[ERREUR] Le script s'éxécute qu'avec sudo "
    echo " Utilise : sudo ./grabber.sh [IP_SERVEUR]"
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
HOSTNAME=$(hostname)
CPU=$(lscpu | grep "Model name" | head -n1 | cut -d':' -f2 | sed 's/^ *//;s/ *$//')
CPU_ID=$(lscpu | grep "CPU family" | head -n1 | awk '{print $3}')
CPU_CORES_NUMBER=$(lscpu | grep "Core(s) per socket" | head -n1 | awk '{print $4}')
CPU_THREADS_NUMBER=$(nproc)
CPU_FREQUENCY_MIN=$(lscpu | grep "CPU min MHz" | head -n1 | awk '{print $4}')
CPU_FREQUENCY_MAX=$(lscpu | grep "CPU max MHz" | head -n1 | awk '{print $4}')
CPU_FREQUENCY_CUR=$(awk -F: '/cpu MHz/ {print $2; exit}' /proc/cpuinfo | sed 's/^ *//;s/ *$//')

GPU_MODEL=$(lspci | grep -i 'vga\|3d' | cut -d':' -f3- | head -n1 | sed 's/^ //')
GPU_MEMORY=$(lspci -v -s $(lspci | grep VGA | cut -d' ' -f1) 2>/dev/null | grep "Memory" | head -n1 | awk '{print $5$6}')
[[ -z "$GPU_MEMORY" ]] && GPU_MEMORY="N/A"

MB_SERIAL=$(cat /sys/class/dmi/id/board_serial 2>/dev/null)
[[ -z "$MB_SERIAL" ]] && MB_SERIAL="0"

CHASSIS_SERIAL=$(cat /sys/class/dmi/id/chassis_serial 2>/dev/null)
[[ -z "$CHASSIS_SERIAL" ]] && CHASSIS_SERIAL="Not Specified"

RAM_SIZE=$(free -h | awk '/Mem:/ {print $2}')
RAM_NUMBER=$(sudo dmidecode -t memory 2>/dev/null | grep "Size:" | grep -v "No Module Installed" | wc -l)
RAM_SLOTS_NUMBER=$(sudo dmidecode -t memory 2>/dev/null | grep -c "Memory Device")
RAM_GEN=$(sudo dmidecode -t memory 2>/dev/null | grep "Type:" | grep -v "Error" | grep -v "Detail" | head -n1 | awk '{print $2}')
RAM_O_SIZE=$(sudo dmidecode -t memory 2>/dev/null | grep "Size:" | grep -v "No Module Installed" | awk -F': ' '{print $2}' | tr '\n' ',' | sed 's/,$//')
RAM_O_FREQUENCE=$(sudo dmidecode -t memory 2>/dev/null | grep "Speed:" | grep -v "Unknown" | awk -F': ' '{print $2}' | tr '\n' ',' | sed 's/,$//')
RAM_O_SLOTS=$(sudo dmidecode -t memory 2>/dev/null | grep "Locator:" | awk -F': ' '{print $2}' | tr '\n' ',' | sed 's/,$//')

MAC_ADRESS=$(ip link | grep "link/ether" | head -n1 | awk '{print $2}')
IPV4=$(ip -4 addr show | grep inet | grep -v 127.0.0.1 | head -n1 | awk '{print $2}' | cut -d'/' -f1)
ROUTING=$(ip route | head -n1)

# ====================== PARTITIONS ======================
partitions_json="[]"

for part in $(lsblk -ln -o NAME | grep -E 'sd|nvme'); do
    fstype=$(lsblk -no FSTYPE "/dev/$part")
    total_size=$(lsblk -no SIZE "/dev/$part")
    used_space=$(df -h "/dev/$part" 2>/dev/null | awk 'NR==2 {print $3}')

    if [ ! -z "$fstype" ]; then
        partitions_json=$(echo "$partitions_json" | jq --arg nom "$part" \
                                                     --arg fstype "$fstype" \
                                                     --arg total_size "$total_size" \
                                                     --arg used_space "$used_space" \
                                                     '. + [{nom: $nom, fstype: $fstype, total_size: $total_size, used_space: $used_space}]')
    fi
done

# ====================== SOFTWARE ==========================
OS=$(lsb_release -d 2>/dev/null | cut -f2)
[[ -z "$OS" ]] && OS=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2)
ARCH=$(uname -m)
DESKTOP=$(echo $XDG_CURRENT_DESKTOP)
[[ -z "$DESKTOP" ]] && DESKTOP="N/A"
WM=$(echo $XDG_SESSION_TYPE)
[[ -z "$WM" ]] && WM="N/A"
KERNEL=$(uname -r)
DNS=$(grep -E "nameserver" /etc/resolv.conf | tr '\n' ';')

# ====================== SUMMARY ==========================
echo "[HARDWARE]" > "$SUM"
echo "HOSTNAME=$HOSTNAME" >> "$SUM"
echo "CPU=$CPU" >> "$SUM"
echo "CPU_ID=$CPU_ID" >> "$SUM"
echo "CPU_CORES_NUMBER=$CPU_CORES_NUMBER" >> "$SUM"
echo "CPU_THREADS_NUMBER=$CPU_THREADS_NUMBER" >> "$SUM"
echo "CPU_FREQUENCY_MIN=$CPU_FREQUENCY_MIN" >> "$SUM"
echo "CPU_FREQUENCY_MAX=$CPU_FREQUENCY_MAX" >> "$SUM"
echo "CPU_FREQUENCY_CUR=$CPU_FREQUENCY_CUR" >> "$SUM"
echo "MB_SERIAL=$MB_SERIAL" >> "$SUM"
echo "CHASSIS_SERIAL=$CHASSIS_SERIAL" >> "$SUM"
echo "GPU_MODEL=$GPU_MODEL" >> "$SUM"
echo "GPU_MEMORY=$GPU_MEMORY" >> "$SUM"
echo "RAM_SIZE=$RAM_SIZE" >> "$SUM"
echo "RAM_NUMBER=$RAM_NUMBER" >> "$SUM"
echo "RAM_SLOTS_NUMBER=$RAM_SLOTS_NUMBER" >> "$SUM"
echo "RAM_GEN=$RAM_GEN" >> "$SUM"
echo "RAM_O_SIZE=$RAM_O_SIZE" >> "$SUM"
echo "RAM_O_FREQUENCE=$RAM_O_FREQUENCE" >> "$SUM"
echo "RAM_O_SLOTS=$RAM_O_SLOTS" >> "$SUM"
echo "MAC_ADRESS=$MAC_ADRESS" >> "$SUM"
echo "IPV4=$IPV4" >> "$SUM"
echo "ROUTING=$ROUTING" >> "$SUM"
echo "" >> "$SUM"

echo "PARTITIONS=$partitions_json" >> "$SUM"
echo "" >> "$SUM"
echo "[SOFTWARE]" >> "$SUM"
echo "OS=$OS" >> "$SUM"
echo "ARCH=$ARCH" >> "$SUM"
echo "DESKTOP=$DESKTOP" >> "$SUM"
echo "WM=$WM" >> "$SUM"
echo "KERNEL=$KERNEL" >> "$SUM"
echo "DNS=$DNS" >> "$SUM"

# ====================== ENVOI JSON ==========================
json_data=$(jq -n \
  --arg hostname "$HOSTNAME" \
  --arg mb_serial "$MB_SERIAL" \
  --arg chassis_serial "$CHASSIS_SERIAL" \
  --arg cpu "$CPU" \
  --arg cpu_id "$CPU_ID" \
  --arg cpu_cores_number "$CPU_CORES_NUMBER" \
  --arg cpu_threads_number "$CPU_THREADS_NUMBER" \
  --arg cpu_frequency_min "$CPU_FREQUENCY_MIN" \
  --arg cpu_frequency_max "$CPU_FREQUENCY_MAX" \
  --arg cpu_frequency_cur "$CPU_FREQUENCY_CUR" \
  --arg gpu_model "$GPU_MODEL" \
  --arg ram_slots_number "$RAM_SLOTS_NUMBER" \
  --arg mac_adress "$MAC_ADRESS" \
  --arg ram_number "$RAM_NUMBER" \
  --arg ram_size "$RAM_SIZE" \
  --arg ram_gen "$RAM_GEN" \
  --arg ipv4 "$IPV4" \
  --arg routing "$ROUTING" \
  --arg os "$OS" \
  --arg arch "$ARCH" \
  --arg desktop "$DESKTOP" \
  --arg wm "$WM" \
  --arg kernel "$KERNEL" \
  --argjson partitions "$partitions_json" \
'{
  "HARDWARE": {
    "hostname": $hostname,
    "mb_serial": $mb_serial,
    "chassis_serial": $chassis_serial,
    "cpu": $cpu,
    "cpu_id": $cpu_id,
    "cpu_cores_number": $cpu_cores_number,
    "cpu_threads_number": $cpu_threads_number,
    "cpu_frequency_min": $cpu_frequency_min,
    "cpu_frequency_cur": $cpu_frequency_cur,
    "cpu_frequency_max": $cpu_frequency_max,
    "gpu_model": $gpu_model,
    "ram_slots_number": $ram_slots_number,
    "mac_adress": $mac_adress,
    "ram_number": $ram_number,
    "ram_size": $ram_size,
    "ram_gen": $ram_gen,
    "ipv4": $ipv4,
    "routing": $routing,
    "partitions": $partitions
  },
  "SOFTWARE": {
    "os": $os,
    "arch": $arch,
    "desktop": $desktop,
    "wm": $wm,
    "kernel": $kernel
  }
}')

echo "$json_data"

if [ -z "$1" ]; then
    echo "[ERREUR] Aucune adresse IP fournie"
    echo "Usage: sudo ./grabber.sh [IP_SERVEUR]"
    exit 1
fi

curl -X POST http://$1:8000/endpoint \
    -H "Content-Type: application/json" \
    -d "$json_data"

echo ""
echo "====================== The end, byeee ======================" | tee -a "$SUCCESS_LOG"
