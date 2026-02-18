# Grabber – Outil de collecte et gestion d'informations système

**Auteur :** Aïcha Fofana  
**Contact :** aichafofana019@gmail.com  
**Étudiante en DSP DevOps – CNAM**

---

## Description

`Grabber` est un projet composé de deux parties :

- **`grabber.sh`** : un script Bash qui collecte les informations matérielles et logicielles d'un poste de travail (CPU, RAM, GPU, disque, OS, réseau...) et les envoie automatiquement à un serveur central via une requête HTTP.

- **Serveur FastAPI** : une application web Python qui reçoit les données envoyées par le script, les stocke dans une base de données SQLite, et propose une interface web pour consulter et gérer les machines et les employés.

---

## Fonctionnalités

- Collecte automatisée des informations système (matériel + logiciel)
- Envoi des données vers un serveur central en JSON
- Stockage en base de données SQLite via SQLModel
- Interface web pour :
  - Consulter les machines enregistrées
  - Créer, modifier et gérer les employés
  - Associer des machines à des employés (relation many-to-many)

---

## Prérequis

**Pour le script `grabber.sh` (côté client) :**
- Linux (Debian/Ubuntu ou distribution compatible)
- Bash
- Commandes : `lscpu`, `dmidecode`, `lspci`, `lsblk`, `ip`, `jq`, `curl`
- Droits `sudo` (nécessaires pour `dmidecode`)

**Pour le serveur (côté serveur) :**
- Python 3.10+
- Les dépendances listées dans `requirements.txt`

---

## Installation

### Serveur

```bash
git clone <URL_DU_DEPOT>
cd grabber
python3 -m venv gbvenv
source gbvenv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload
```

### Script client

```bash
chmod +x grabber.sh
sudo ./grabber.sh <IP_DU_SERVEUR>
```

---

## Utilisation

Une fois le serveur lancé, l'interface web est accessible sur `http://localhost:8000`.

Depuis un poste client, lance le script en lui passant l'adresse IP du serveur :

```bash
sudo ./grabber.sh 192.168.1.10
```

Le script collecte les infos du poste et les envoie automatiquement au serveur. La machine apparaît alors dans l'interface web.

---

## Structure du projet

```
grabber/
├── app.py            # Serveur FastAPI (routes et logique)
├── models.py         # Modèles de base de données (SQLModel)
├── forms.py          # Formulaires Pydantic
├── grabber.sh        # Script de collecte côté client
├── database.db       # Base de données SQLite (générée automatiquement)
├── templates/        # Templates HTML Jinja2
│   ├── employees.html
│   ├── employee_form.html
│   ├── employee_edit.html
│   └── ordi.html
└── static/           # Fichiers statiques CSS/JS
```

---

## Objectifs pédagogiques

- Consolider les compétences en administration systèmes et réseaux
- Découvrir le développement d'une API REST avec FastAPI
- Mettre en pratique la gestion d'une base de données avec SQLModel
- Automatiser la collecte d'informations système via Bash
