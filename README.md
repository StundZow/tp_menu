# tp_menu

Ressource FiveM permettant de :
- Se téléporter vers n'importe quel joueur connecté
- Téléporter un joueur vers soi
- Voir tous les joueurs sur la mini-map, chacun avec une couleur de blip différente

## Installation

1. Copier le dossier `tp_menu` dans le dossier `resources` de votre serveur.
2. Ajouter dans `server.cfg` :
   ```
   ensure tp_menu
   ```
3. (Optionnel) Restreindre l'usage aux admins via une permission ACE. Dans `config.lua`,
   mettre :
   ```lua
   Config.AcePermission = 'tpmenu.use'
   ```
   puis dans `server.cfg` :
   ```
   add_ace group.admin tpmenu.use allow
   add_principal identifier.license:VOTRE_LICENSE group.admin
   ```

## Utilisation

- En jeu, ouvrir la console (F8) et taper `tp`, taper `/tp` dans le chat, **ou** appuyer sur `F9`.
- Un menu s'ouvre avec la liste des joueurs connectés (recherche disponible).
- Pour chaque joueur : bouton **Aller vers** (vous vous téléportez à lui) ou
  **Faire venir** (il est téléporté à vous).
- L'icône boussole grise à gauche du nom permet d'afficher/masquer le blip de ce joueur
  (icône grisée = masqué). **C'est synchronisé pour tout le monde** : si vous masquez
  un joueur, plus personne ne le voit sur sa carte (le serveur n'envoie même plus sa
  position). Le menu de chaque joueur se met à jour en direct.
- `ESC` ou le bouton ✕ ferme le menu.

Tous les joueurs apparaissent en permanence sur la mini-map sous forme de blips,
chacun avec une couleur fixe attribuée à la connexion (voir `Config.BlipColors`
dans `config.lua` pour personnaliser la palette).

## Configuration (`config.lua`)

| Option | Description |
|---|---|
| `Config.Command` | Nom de la commande console/chat (`tp` par défaut) |
| `Config.MenuKey` | Touche par défaut pour ouvrir le menu (`F9` par défaut, remappable en jeu) |
| `Config.AcePermission` | Permission ACE requise pour téléporter (false = tout le monde autorisé) |
| `Config.BlipTogglePermission` | Permission ACE requise pour masquer/afficher un blip (false = tout le monde) |
| `Config.UpdateInterval` | Fréquence (ms) de mise à jour des positions/blips |
| `Config.BlipSprite`, `Config.BlipScale` | Apparence des blips |
| `Config.ShowBlipName` | Affiche le nom du joueur sur son blip |
| `Config.BlipColors` | Palette de couleurs attribuées aux joueurs |
