# 📝 PROJET_FINAL_APPS_DE_PRISE_NOTE

Application Flutter développée dans le cadre du programme **D-CLIC niveau Intermédiaire**. Elle permet à un utilisateur de gérer ses notes personnelles avec un système d’authentification sécurisé.

---

## 🚀 Fonctionnalités

- Connexion et inscription avec validation des champs
- Système de question secrète pour récupération de mot de passe
- Ajout, modification, suppression et validation des notes
- Affichage des notes en tête de liste dès leur création
- Filtrage dynamique : Toutes / En cours / Terminées
- Interface responsive avec composants réutilisables
- Stockage local via SQLite
## 📦 Installation

### Prérequis
- Flutter SDK (≥ 3.0)
- Dart ≥ 2.17
- Un émulateur Android ou un appareil physique

### Étapes

```bash
git clone https://github.com/NAMBO-ADJI-M/PROJET_FINAL_APPS_DE_PRISE_NOTE.git
cd PROJET_FINAL_APPS_DE_PRISE_NOTE
flutter pub get
flutter run
```

---

## 🧩 Structure du projet

```plaintext
lib/
├── database/           # Gestion SQLite
├── screens/            # Écrans Login, Register, Main
├── user/               # Modèles utilisateur et note
├── widgets/            # Composants réutilisables
└── main.dart           # Point d’entrée
```

---

## 📐 Wireframes

Les wireframes du projet sont disponibles dans le dossier `/assets/wireframes/`

---

## 📚 Documentation

Chaque fichier est commenté pour faciliter la compréhension et la maintenance.  
Les widgets sont modulaires et conçus pour être réutilisables.

---

## 🔐 Sécurité

Validation stricte des champs (email, mot de passe, question secrète)

Neutralité assurée : les mots de passe ne sont pas hashés par défaut

Navigation sécurisée entre les écrans

## 👨‍💻 Auteur

**Adji Nambo**  
Développeur Flutter passionné par la pédagogie, la modularité et la sécurité des applications mobiles.

---

## 📄 Licence

Ce projet est open-source sous licence MIT.
```bash

