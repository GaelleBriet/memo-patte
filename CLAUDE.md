# Projet : Carnet de santé animaux (nom provisoire)

## Statut actuel
Phase de développement actif, ticket par ticket. Le gate initial ("pas
de stack/code avant scope validé") est levé : `06-mvp-scope.md` est
validé depuis le 2026-08-11, l'architecture technique
(`docs/technical/01-architecture.md`) depuis le 2026-08-14.

Découpage en tickets détaillé dans `docs/technical/02-tickets-v1.md`.
Pour savoir précisément ce qui est fait/en cours, se fier aux
issues/PRs/Project du repo GitHub (`GaelleBriet/memo-patte`) plutôt
qu'à une liste figée ici, qui deviendrait vite fausse.

> `docs/` est volontairement gitignoré (repo public, contient des
> notes d'entretiens avec de vraies personnes) — il n'existe que sur
> les machines où il a été créé localement, pas sur un clone frais.
> Les fichiers `docs/product/*.md` référencés dans ce document (ci-
> dessous) peuvent donc être absents selon la machine ; les
> issues/PRs GitHub, elles, sont toujours accessibles.

## Contexte
Projet portfolio pour appuyer une transition vers le freelance.
Objectif : publier une application de suivi santé animaux (poids,
vaccins, vermifuges etc.) sur le Google Play Store.

Le marché est saturé (voir docs/product/01-competitors/), donc
l'exécution propre et un différenciant ciblé priment sur la
quantité de fonctionnalités.

## Où trouver quoi
- `docs/product/00-vision.md` : pourquoi ce projet, pour qui, quel
  objectif (portfolio pur / produit à monétiser / les deux)
- `docs/product/01-competitors/` : audit détaillé des apps
  concurrentes, une fiche par app
- `docs/product/02-customer-discovery/` : grille d'entretien et
  notes des entretiens avec de vrais propriétaires d'animaux
- `docs/product/03-pain-points.md` : synthèse priorisée des
  frustrations identifiées, avec leurs sources
- `docs/product/04-differenciation.md` : différenciants retenus et
  rejetés, avec justification
- `docs/product/05-monetisation.md` : options de monétisation
  étudiées et décision finale
- `docs/product/06-mvp-scope.md` : périmètre du MVP, et ce qui est
  explicitement hors scope
- `docs/product/decisions-log.md` : journal chronologique des
  décisions produit importantes

## Règles pour Claude
- Ne pas proposer de stack technique, d'architecture ou de code
  avant que `06-mvp-scope.md` soit rempli et marqué comme validé.
- Si une demande contredit une décision déjà actée dans
  `decisions-log.md`, le signaler avant d'exécuter quoi que ce soit.
- Ne pas halluciner de contenu dans les fiches concurrents : si une
  info n'est pas dans la fiche, dire qu'elle manque plutôt que de
  l'inventer.

## Garde-fous — interdictions strictes pour Claude
Valables quel que soit le mode de permission actif (y compris
`bypassPermissions`, aucune confirmation demandée). Certaines sont
bloquées techniquement, le reste est une discipline sans exception —
pas de garde-fou automatique fiable possible pour ces cas-là.

**Bloqué techniquement** (`.claude/settings.json` +
`.claude/hooks/guard.py`, hook `PreToolUse` sur `Bash`) :
- `git commit`, `git push`, `git reset --hard`, `git clean`
- `rm -rf` (ou équivalent) en dehors du dossier du projet, du cache
  Gradle (`~/.gradle/caches`) et de `/tmp`

**Discipline stricte, sans exception** :
- **Git** : jamais de commit ni de push, sous quelque forme — Gaelle
  gère seule le dépôt de bout en bout. Toujours une branche dédiée,
  jamais de travail direct sur `main` (depuis le commit initial du
  2026-08-13).
- **GitHub** : proposer et attendre l'accord avant toute action qui
  change un état visible (fermer une issue, éditer un label, etc.).
  Interdit sans exception, même avec accord implicite : supprimer le
  repo, changer sa visibilité, supprimer une issue/PR, modifier la
  protection de branche.
- **Téléphone physique** (tests) : jamais de reset usine,
  d'effacement de données d'une autre app que MémoPatte, ou de
  désinstallation d'une app qui n'est pas MémoPatte.
- **Argent / publication** : jamais d'achat réel, de saisie de moyen
  de paiement, ou de soumission Play Store — y compris le premier
  upload en test interne — sans feu vert explicite de Gaelle pour
  cette action précise.
- **Secrets** : jamais afficher, logger ou committer une clé de
  service Firebase, un keystore de signature, un `.env`, ou tout
  fichier ressemblant à un secret.
