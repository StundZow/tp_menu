Config = {}

-- Commande pour ouvrir le menu. Fonctionne à la fois :
--  - dans la console F8 en tapant simplement "tp"
--  - dans le chat en tapant "/tp"
Config.Command = 'tp'

-- Touche par défaut pour ouvrir le menu (en plus de la commande).
-- Le joueur peut la remapper dans FiveM > Paramètres > Touches > tp_menu.
Config.MenuKey = 'F9'

-- Nom de la permission ACE requise pour UTILISER la téléportation
-- (le menu peut s'ouvrir pour tout le monde, mais si cette permission
-- est définie, seuls les joueurs autorisés pourront réellement se
-- téléporter ou téléporter quelqu'un).
-- Mettre `false` pour désactiver la vérification et autoriser tout le monde.
-- Exemple pour restreindre aux admins, dans server.cfg :
--   add_ace group.admin tpmenu.use allow
--   add_principal identifier.license:XXXX group.admin
Config.AcePermission = false

-- Synchronisation du bouton boussole (masquer/afficher le blip d'un joueur) :
--   true  = synchro : masquer un joueur le masque pour TOUT LE MONDE
--   false = local   : chacun masque les blips uniquement pour soi
Config.SyncBlipToggle = true

-- Permission ACE requise pour masquer/afficher un blip (uniquement si
-- Config.SyncBlipToggle = true, car c'est alors global).
-- Sur un serveur public, il est conseillé de la restreindre :
--   Config.BlipTogglePermission = 'tpmenu.blips'
--   add_ace group.admin tpmenu.blips allow
-- Mettre `false` pour autoriser tout le monde.
Config.BlipTogglePermission = false

-- Intervalle (ms) de rafraîchissement des positions des joueurs
-- (utilisé pour la liste du menu et pour les blips sur la carte)
Config.UpdateInterval = 1000

-- Apparence des blips joueurs sur la mini-map
Config.BlipSprite = 1        -- 1 = simple rond
Config.BlipScale = 0.85
Config.ShowBlipName = true   -- affiche le nom du joueur sur le blip

-- Palette de couleurs (natives GTA) utilisée pour distinguer les joueurs
-- sur la mini-map. Chaque joueur reçoit une couleur fixe pour sa session.
Config.BlipColors = {
    1,  -- rouge
    2,  -- vert
    3,  -- bleu clair
    5,  -- jaune
    6,  -- rose/rouge clair
    7,  -- violet
    17, -- orange
    27, -- bleu ciel
    38, -- vert citron
    47, -- jaune foncé
    49, -- bleu
    64, -- violet foncé
    66, -- vert foncé
    68, -- rose
    83, -- rouge foncé
    2,  -- (rebouclage si + de 15 joueurs)
}
