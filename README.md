# Grabber – Outil de collecte et gestion d'informations système

**Auteur :** Aïcha Fofana  
**Contact :** aichafofana019@gmail.com  
**Étudiante en DSP DevOps – CNAM**

---

## Description

`Grabber` est un projet composé de deux parties :

- **`grabber.sh`** : un script Bash qui collecte les informations matérielles et logicielles d'un poste de travail (CPU, RAM, GPU, disques, OS, réseau...) et les envoie automatiquement à un serveur central via une requête HTTP.
- **Serveur FastAPI** : une application web Python qui reçoit les données envoyées par le script, les stocke dans une base de données PostgreSQL, et propose une interface web pour consulter et gérer les machines et les employés.

Le tout est conteneurisé avec Docker et servi derrière un reverse proxy Caddy.

---

## Fonctionnalités

- Collecte automatisée des informations système (matériel + logiciel)
- Envoi des données vers un serveur central en JSON
- Stockage en base de données PostgreSQL via SQLModel
- Interface web pour :
  - Consulter les machines enregistrées avec leurs partitions
  - Créer, modifier et gérer les employés
  - Associer des machines à des employés (relation many-to-many)
- Reverse proxy Caddy avec TLS pour `grabber.local` et `wp.local`
- Instance WordPress disponible sur `wp.local`

---

## Structure du projet
```
grabber/
├── grabber.sh          #Script de collecte côté client
├── README.md
├── compose.yml         # Compose principal 
├── caddy/
│   └── Caddyfile       # Config reverse proxy
├── gbapp/
│   ├── app.py          # Serveur FastAPI
│   ├── models.py       # Modèles de base de données
│   ├── forms.py        # Formulaires Pydantic
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── templates/      #Templates HTML Jinja2
│   └── static/    
└── wp/
    └── compose.yml     # Compose WordPress + MariaDB (référence)
```

---

## Prérequis

**Pour le script `grabber.sh` (côté client) :**
- Linux (Debian/Ubuntu ou distribution compatible)
- Bash
- Commandes : `lscpu`, `dmidecode`, `lspci`, `lsblk`, `ip`, `jq`, `curl`
- Droits `sudo`

**Pour le serveur :**
- Docker et Docker Compose

---

## Installation et déploiement

### 1. Configurer `/etc/hosts`

Ajouter ces lignes dans `/etc/hosts` pour accéder aux applications via leur nom de domaine local :
```bash
echo "127.0.0.1 grabber.local" | sudo tee -a /etc/hosts
echo "127.0.0.1 wp.local" | sudo tee -a /etc/hosts
```

### 2. Lancer les services

Depuis la racine du projet :
```bash
sudo docker compose up -d --build
```

Les applications sont accessibles sur :

| URL | Application |
|-----|-------------|
| http://grabber.local | Interface web Grabber |
| http://wp.local | WordPress |

---

## Utilisation du script grabber.sh

Depuis un poste client, lancer le script en lui passant l'adresse IP du serveur :
```bash
sudo ./grabber.sh 127.0.0.1
```

Le script collecte les infos du poste et les envoie au serveur. La machine apparaît ensuite dans l'interface web sur `http://grabber.local/employees`.

---

## Arrêter les services
```bash
sudo docker compose down
```

Pour supprimer également les données :
```bash
sudo docker compose down -v
```
