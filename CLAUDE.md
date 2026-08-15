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
- `docs/design/PetCare - Ma Vision` : maquette de référence pour le
  style visuel (couleurs, typo, composants) — voir la section
  "Design & UI" ci-dessous avant de styliser un nouvel écran.

## Design & UI — composants à réutiliser, pièges déjà réglés
Référence de style : `docs/design/PetCare - Ma Vision`. C'est une
référence de style, pas un plan de fonctionnalités — Documents,
Finances et l'export PDF qu'elle montre sont explicitement hors
scope v1 (`decisions-log.md`, 2026-08-13 et 2026-08-15).

**Ne pas redessiner un composant qui existe déjà** — avant de
styliser un nouvel écran, regarder s'il est déjà couvert par :
- `lib/app/theme.dart` (`AppTheme`) : palette, dégradé d'en-tête
  (`headerGradient`), ombre de carte (`cardShadow`), hauteur de hero
  partagée (`heroBodyHeight` — tous les heros à dégradé doivent faire
  la même hauteur, décision du 2026-08-16).
- `lib/core/widgets/surface_card.dart` : `SurfaceCard` (carte blanche
  arrondie standard), `IconChip` (pastille d'icône menthe).
- `lib/core/widgets/gradient_app_bar.dart` : `GradientAppBar`, pour
  tout écran avec AppBar + dégradé.
- `lib/core/widgets/straddling_hero.dart` : `StraddlingHero`, pour
  poser un sélecteur de chips à cheval sur le bord bas d'un hero.
- `lib/core/widgets/light_status_bar.dart` : `LightStatusBar`, pour
  tout écran à hero sombre sans AppBar.
- `lib/features/animals/presentation/animal_chip_selector.dart` :
  `AnimalChipSelector` (sélecteur d'animaux en chips, contour coloré
  si actif, contour clair sinon) — partagé entre l'accueil et le
  Carnet de santé, pas deux implémentations qui pourraient diverger.
- `lib/features/vaccinations/presentation/vaccination_card.dart` :
  `VaccinationCard` (ligne de vaccin avec statut visuel) — même
  logique à suivre pour les traitements (épic 4) le moment venu.

**Pièges Flutter/Android déjà rencontrés** (temps perdu dessus le
2026-08-16 en corrigeant le rendu du hero/de la nav — éviter de
recommencer) :
- Un hero à dégradé qui doit couvrir la barre de statut a besoin de
  DEUX choses, pas une seule : `padding: EdgeInsets.zero` explicite
  sur la `ListView`/`ScrollView` qui le contient (sinon elle s'ajoute
  toute seule un padding haut = `MediaQuery.padding.top`, invisible
  tant qu'on ne sait pas que ça existe — `ScrollView.buildSlivers`
  dans le SDK Flutter), ET le hero lui-même qui gère cet inset via
  `MediaQuery.paddingOf`.
- Un `Stack` utilisé pour faire chevaucher un élément (ex. chips à
  cheval sur un hero, `StraddlingHero`) doit passer
  `fit: StackFit.passthrough` — sinon la contrainte de largeur
  transmise à l'enfant non positionné est relâchée (`StackFit.loose`,
  le défaut), qui peut alors se réduire à la largeur de son contenu
  au lieu de remplir l'écran.
- `SafeArea(minimum: ...)` prend le MAXIMUM entre la valeur donnée et
  l'inset système, pas leur somme — pour garantir une marge visible
  *en plus* de l'inset système (ex. barre de nav du bas au-dessus de
  la zone de geste), utiliser un `Padding` qui additionne
  explicitement (`MediaQuery.paddingOf(context).bottom + marge`), pas
  `SafeArea`.
- Ce projet cible Android API 36 (`flutter.targetSdkVersion`) : à
  partir de l'API 35/36, `SystemUiOverlayStyle.statusBarColor` n'a
  plus aucun effet (edge-to-edge forcé par l'OS, aucun moyen de s'en
  exclure) — seul ce que l'app peint réellement derrière la barre de
  statut compte visuellement. `statusBarIconBrightness` reste, lui,
  fonctionnel (couleur des icônes système) — voir `LightStatusBar` et
  `GradientAppBar.systemOverlayStyle`.

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
