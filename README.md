# 🗑️ Trashbox Manager – Scripts Bash de suppression et restauration sécurisées

## 📌 Description

Ce projet est une implémentation en Bash d’un système de corbeille sécurisé sous Linux.
Il permet de supprimer et restaurer des fichiers ou dossiers sans les effacer définitivement, en les déplaçant vers un répertoire dédié nommé `.sh-trashbox`.

Le projet inclut :

* une gestion de l’historique des suppressions via un fichier `INDEX`
* une restauration vers différents emplacements
* une protection par mot de passe pour sécuriser les opérations

Projet réalisé dans le cadre d’une SAE par **Hocine Abdelaziz** et **Melissa Hikem**.

---

## ⚙️ Fonctionnalités

* Suppression sécurisée de fichiers et dossiers
* Déplacement des éléments supprimés dans `.sh-trashbox`
* Conservation d’un historique des suppressions
* Restauration :

  * à l’emplacement d’origine
  * dans un dossier spécifique
  * dans le dossier courant
* Affichage des éléments supprimés
* Protection par mot de passe

---

## 🛠️ Technologies utilisées

* Bash
* Linux
* Commandes système Unix

---

## 📂 Fichiers principaux

* `init-trashbox.sh` : initialisation de la corbeille
* `sae_delete.sh` : suppression sécurisée
* `sae_restore.sh` : restauration
* `sae_trashbox_ls.sh` : affichage de la corbeille

---

## 🚀 Initialisation

Donner les droits d’exécution aux scripts :

```bash
chmod u+x *
```

---

## ▶️ Utilisation

### Supprimer un fichier ou dossier

```bash
./sae_delete.sh chemin_du_fichier
```

### Restaurer un élément

* À l’emplacement d’origine :

```bash
./sae_restore.sh -r nom_element
```

* Dans un dossier spécifique :

```bash
./sae_restore.sh -d dossier nom_element
```

* Dans le dossier courant :

```bash
./sae_restore.sh nom_element
```

### Afficher la corbeille

```bash
./sae_trashbox_ls.sh
```

---

## ⚠️ Remarque

Les scripts doivent être exécutés dans le dossier contenant `.sh-trashbox`.

---

## 🎯 Objectifs

* Manipulation de fichiers sous Linux
* Automatisation avec Bash
* Gestion de scripts interactifs
* Sécurisation des opérations

---

## 👩‍💻 Auteurs

Melissa Hikem
