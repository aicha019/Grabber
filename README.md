# Grabber – Script de collecte d’informations système

**Auteur :** Aïcha Fofana  
**Contact :** aichafofana019@gmil.com 
**Étudiante en DSP DevOps – CNAM**

---

## Description

`Grabber` est un script Bash permettant de collecter et de consigner des informations détaillées sur le poste de travail.  
Il récupère les informations matérielles (CPU, RAM, disque), le système et les logiciels installés, les configurations système et les tâches cron, puis les enregistre dans un fichier journal daté.

Le script génère automatiquement un fichier journal nommé `journalDDMMYYYY.log` à chaque exécution, contenant une mise en forme claire et lisible.

---

## Objectifs

- Consolider les compétences en administration systèmes et réseaux.  
- Suivre l’état et la configuration du poste de travail de manière automatisée.  
- Fournir un outil simple pour documenter les informations système.

---

## Prérequis

- Linux (Ubuntu, Debian ou distribution compatible)  
- Bash  
- Commandes système : `lscpu`, `free`, `df`, `ip`, `hostname`, `dmidecode`  
- Accès avec permissions suffisantes pour récupérer certaines informations (`sudo` pour CPU_SERIAL)  

---

## Installation et exécution

1. Cloner le dépôt :

```bash
git clone <URL_DU_DEPOT>
cd grabber

Rendre le script exécutable :

chmod +x grabber.sh


Lancer le script :

./grabber.sh


⚠️ Le script créera automatiquement un fichier journal dans le dossier output/ nommé selon la date, par exemple : journal07122025.log.

Exemple de sortie

Ci-dessous, un exemple du contenu généré par le script :

2025-12-07 21:33:01

[HOSTNAME]
HOSTNAME=aicha-20b7s0jc0v

[HARDWARE]
CPU_MODEL=Intel(R) Core(TM) i5-4300U CPU @ 1.90GHz
CPU_CORES=2
CPU_THREADS=2
CPU_SERIAL=

RAM_TOTAL=7,6Gi
RAM_USED=2,5Gi

SWAP_TOTAL=
SWAP_USED=

DISK_TOTAL=108G
DISK_USED=15G

TEMPERATURE=45,0°C

INTERFACES=
lo
enp0s25
wlp3s0
docker0

IPV4=192.168.1.97/24
ROUTING=default via 192.168.1.254 dev wlp3s0 proto dhcp src 192.168.1.97 metric 600 

[SOFTWARE]
OS=Debian GNU/Linux 13 (trixie)
KERNEL=6.12.43+deb13-amd64
PACKAGES_INSTALLED=
<liste complète des packages installés>

SNAP_PACKAGES=0
FLATPAK_PACKAGES=0

[CONFIG]
SOURCES.LIST=
<contenu de /etc/apt/sources.list sans commentaires>
FSTAB=
<contenu de /etc/fstab sans commentaires>
CRONTAB=
<crontab de l’utilisateur>

[END]


💡 Remarque : le fichier journal réel sera généré à chaque exécution, donc les valeurs refléteront ton système actuel.

