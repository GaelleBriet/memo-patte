# MémoPatte

Le carnet de santé qui ne vous laisse jamais rien oublier — même
avec plusieurs animaux, même hors-ligne.

## Statut

🚧 En développement — pas encore publié sur le Play Store.

## Le projet

MémoPatte est une application mobile de suivi de santé pour animaux
de compagnie (poids, vaccins, vermifuges), pensée autour de trois
principes :

- **Rappels fiables, y compris hors-ligne** — les notifications ne
  dépendent d'aucun serveur ni d'une connexion internet.
- **Vue consolidée multi-animaux** — un seul écran d'accueil pour
  tous vos animaux et leurs prochaines échéances.
- **Prix transparent** — achat unique annoncé dès l'installation,
  jamais d'abonnement ni de palier qui change après coup.

## Stack technique

- [Flutter](https://flutter.dev) (Dart) — Android + iOS
- [Riverpod](https://riverpod.dev) — gestion d'état / injection de dépendances
- [Drift](https://drift.simonbinder.eu) — persistance locale (SQLite)
- [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) — rappels hors-ligne
- [`go_router`](https://pub.dev/packages/go_router) — navigation
- Firebase (Auth + Firestore) — sauvegarde optionnelle du carnet

## Développement

Le projet utilise [FVM](https://fvm.app/) pour figer la version de
Flutter :

```bash
fvm flutter pub get
fvm flutter run
```

## À propos

Projet portfolio développé en solo, de la recherche produit à la
publication sur le Google Play Store.
