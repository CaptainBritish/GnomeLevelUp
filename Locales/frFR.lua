local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- frFR: Français. English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.

RegisterLocaleBuilder("frFR", function() return {
    ["%s (recommended for gamepad)"] = "%s (conseillé pour la manette)",
    ["%s hue"] = "Teinte : %s",
    ["%s rotation"] = "Rotation : %s",
    ["A to clear"] = "A : effacer",
    ["A to play"] = "A : écouter",
    ["A to preview"] = "A : aperçu",
    ["A to print"] = "A : afficher",
    ["A to reset"] = "A : réinitialiser",
    ["A trainer rescan is required."] = "Les données doivent être relevées à nouveau auprès d’un maître.",
    ["Abilities"] = "Techniques",
    ["Abilities header"] = "En-tête des techniques",
    ["Ability icon border"] = "Bordure des icônes de techniques",
    ["Adjust"] = "Ajuster",
    ["Alarm Clock"] = "Réveil",
    ["Alliance"] = "Alliance",
    ["Alliance ring"] = "Anneau de l’Alliance",
    ["Allow click-through"] = "Laisser passer les clics",
    ["Alternate"] = "En alternance",
    ["Ambience"] = "Ambiance",
    ["Animation"] = "Animation",
    ["Animation speed"] = "Vitesse d’animation",
    ["Appearance"] = "Apparence",
    ["Auction Window Open"] = "Ouverture de l’hôtel des ventes",
    ["Auto (below preview)"] = "Auto (sous l’aperçu)",
    ["Auto Detect"] = "Détection automatique",
    ["Automatically save trainer data"] = "Enregistrer automatiquement les données",
    ["Background"] = "Arrière-plan",
    ["Background hue"] = "Teinte de l’arrière-plan",
    ["Background opacity"] = "Opacité de l’arrière-plan",
    ["Background texture"] = "Texture d’arrière-plan",
    ["Black Metal"] = "Métal noir",
    ["Bloodlord Mandokir"] = "Seigneur sanglant Mandokir",
    ["Bottom edge"] = "bord inférieur",
    ["Bottom-left corner"] = "coin inférieur gauche",
    ["Bottom-right corner"] = "coin inférieur droit",
    ["by %s"] = "par %s",
    ["Cache Status"] = "État du cache",
    ["Cache status unavailable."] = "État du cache indisponible.",
    ["Center"] = "centre",
    ["Changes apply after reloading the UI."] = "Les changements s’appliquent après rechargement de l’interface.",
    ["Class icon"] = "Icône de classe",
    ["Clear trainer cache"] = "Vider le cache des maîtres",
    ["Click to open options"] = "Cliquez pour ouvrir les options",
    ["Close"] = "Fermer",
    ["Colors"] = "Couleurs",
    ["Compact Layout"] = "Mode compact",
    ["Controller glyphs"] = "Icônes des boutons de la manette",
    ["Controller menu frame strata"] = "Couche d’affichage du menu manette",
    ["Copper ring"] = "Anneau de cuivre",
    ["Custom"] = "Personnalisé",
    ["Custom sound"] = "Son personnalisé",
    ["Custom sound file"] = "Fichier audio personnalisé",
    ["Debug"] = "Débogage",
    ["Default font"] = "Police par défaut",
    ["Dialog"] = "Dialogue",
    ["Display duration"] = "Durée d’affichage",
    ["Don't show until combat ends"] = "Afficher après la fin du combat",
    ["Drag to move"] = "Faites glisser pour déplacer",
    ["Enable addon"] = "Activer l’addon",
    ["Enable debug commands"] = "Activer les commandes de débogage",
    ["Equal-width stat text"] = "Uniformiser la largeur des caractéristiques",
    ["Fill"] = "Remplir",
    ["Filter grimoires by active pet"] = "Grimoires du familier invoqué",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "Version du jeu : %s\nClasse : %s\nTechniques en cache : %d\nDernier maître : %s\nDernier relevé : %s\nSchéma : %d%s",
    ["Flip H"] = "Miroir H",
    ["Flip V"] = "Miroir V",
    ["Font"] = "Police",
    ["Frame"] = "Cadre",
    ["Frame hue"] = "Teinte du cadre",
    ["Frame strata"] = "Couche d’affichage du cadre",
    ["Fullscreen"] = "Plein écran",
    ["Fullscreen Dialog"] = "Dialogue plein écran",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - Options de manette",
    ["Gnomeregan"] = "Gnomeregan",
    ["Hide Blizzard level-up toast"] = "Masquer l’alerte de niveau de Blizzard",
    ["High"] = "Haute",
    ["Horde"] = "Horde",
    ["Horde ring"] = "Anneau de la Horde",
    ["Ignore mouseover delay"] = "Ne pas prolonger au survol",
    ["Improved value"] = "Valeur après montée de niveau",
    ["Include profession trainers"] = "Inclure les maîtres de métier",
    ["Language"] = "Langue",
    ["Left"] = "Gauche",
    ["Left edge"] = "bord gauche",
    ["Level %d"] = "Niveau %d",
    ["Level Up (default)"] = "Montée de niveau (par défaut)",
    ["Level number"] = "Numéro de niveau",
    ["Lock Location"] = "Verrouiller la position",
    ["Low"] = "Basse",
    ["Master"] = "Volume général",
    ["Medium"] = "Moyenne",
    ["Mode"] = "Mode",
    ["Modern"] = "Moderne",
    ["Move"] = "Déplacer",
    ["Music"] = "Musique",
    ["Mute Blizzard level-up sound"] = "Couper le son de niveau de Blizzard",
    ["Never"] = "Jamais",
    ["New trainer entries saved: %d (%s)."] = "Nouvelles entrées enregistrées : %d (maître : %s).",
    ["No new skills this level"] = "Aucune nouvelle technique à ce niveau",
    ["No portrait ring"] = "Sans anneau",
    ["No registered custom sounds"] = "Aucun son personnalisé disponible",
    ["No stat changes"] = "Aucun gain de caractéristiques",
    ["No trainer data for this class.\nVisit your class trainer."] = "Aucune donnée pour cette classe.\nConsultez votre maître de classe.",
    ["No unlearned skills available"] = "Aucune technique à apprendre",
    ["None"] = "Aucun",
    ["Off"] = "Désactivé",
    ["On"] = "Activé",
    ["Only display new skills"] = "Nouvelles techniques, sans les rangs supérieurs",
    ["Only skills unlocked at this level"] = "Techniques débloquées à ce niveau",
    ["Open Controller Options"] = "Options de manette",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "Facultatif. Remplace le son ci-dessus. Exemple : Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "Écouter",
    ["Play sound on level up"] = "Jouer un son à la montée de niveau",
    ["Player portrait"] = "Portrait du joueur",
    ["Popup scale"] = "Échelle de l’alerte de niveau",
    ["Portrait"] = "Portrait",
    ["Portrait border"] = "Bordure du portrait",
    ["Portrait ring"] = "Anneau du portrait",
    ["Portrait ring hue"] = "Teinte de l’anneau",
    ["Portrait ring offset X"] = "Décalage X de l’anneau",
    ["Portrait ring offset Y"] = "Décalage Y de l’anneau",
    ["Portrait ring scale"] = "Échelle de l’anneau",
    ["Preview Level-Up"] = "Aperçu de l’alerte",
    ["Print performance report"] = "Rapport de performances",
    ["Quest Complete"] = "Quête terminée",
    ["Ready Check"] = "Appel",
    ["Reduced motion"] = "Réduire les animations",
    ["Refresh Cache Status"] = "Actualiser le cache",
    ["Registered custom sound"] = "Son personnalisé disponible",
    ["Reload UI"] = "Recharger l’interface",
    ["Reset Appearance"] = "Réinitialiser l’apparence",
    ["Reset all options"] = "Réinitialiser toutes les options",
    ["Reset performance data"] = "Effacer les mesures",
    ["Reset to Defaults"] = "Valeurs par défaut",
    ["Right"] = "Droite",
    ["Right edge"] = "bord droit",
    ["Right-click to close"] = "Clic droit pour fermer",
    ["Right-click to toggle the addon"] = "Clic droit pour activer ou désactiver",
    ["Section divider"] = "Séparateur de sections",
    ["Section padding"] = "Espacement des sections",
    ["Select"] = "Sélectionner",
    ["Show Hunter pet abilities"] = "Techniques des familiers de chasseur",
    ["Show Warlock pet abilities"] = "Techniques des familiers de démoniste",
    ["Show all available grimoires"] = "Afficher tous les grimoires disponibles",
    ["Show learning costs"] = "Afficher les coûts d’apprentissage",
    ["Show minimap button"] = "Afficher le bouton de la minicarte",
    ["Show text shadows"] = "Ombre du texte",
    ["Show time played this level"] = "Afficher le temps de montée de niveau",
    ["Show unlearned weapon skills"] = "Compétences d’armes à apprendre",
    ["Skipped %d future skills without a readable required level."] = "%d techniques de niveaux supérieurs ignorées : niveau requis illisible.",
    ["Slide direction"] = "Sens de l’animation",
    ["Some options are not available in the controller menu."] = "Certaines options ne sont pas disponibles dans le menu de la manette.",
    ["Sound"] = "Son",
    ["Sound Effects"] = "Effets sonores",
    ["Sound channel"] = "Canal audio",
    ["Sound volume"] = "Volume du son",
    ["Stat name / old value"] = "Caractéristique / ancienne valeur",
    ["Stats Gained"] = "Gains de caractéristiques",
    ["Stats header"] = "En-tête des caractéristiques",
    ["Steel ring"] = "Anneau d’acier",
    ["Stretch"] = "Étirer",
    ["Suspend Preview"] = "Garder l’aperçu affiché",
    ["Tabs"] = "Onglets",
    ["Text"] = "Texte",
    ["Textures"] = "Textures",
    ["The level-up screen failed to display (see above). Please report this error."] = "Impossible d’afficher l’alerte de niveau (voir ci-dessus). Signalez cette erreur.",
    ["Theme"] = "Thème",
    ["Tile"] = "Répéter",
    ["Time to level: %dh %02dm"] = "Montée de niveau : %d h %02d min",
    ["Time to level: %dm %02ds"] = "Montée de niveau : %d min %02d s",
    ["Time to level: %ds"] = "Montée de niveau : %d s",
    ["Title"] = "Titre",
    ["Tooltip (highest)"] = "Infobulles (premier plan)",
    ["Top edge"] = "bord supérieur",
    ["Top-left corner"] = "coin supérieur gauche",
    ["Top-right corner"] = "coin supérieur droit",
    ["Trainer Data"] = "Données des maîtres",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "Les données des maîtres ont été mises à jour. Rendez visite à votre maître de classe pour relever les techniques et leurs coûts d’apprentissage.",
    ["Use class colors"] = "Utiliser les couleurs de classe",
    ["Use horizontal scrolling"] = "Activer le défilement horizontal",
    ["Version %s"] = "Version %s",
    ["Warlock Grimoires"] = "Grimoires de démoniste",
    ["Weapon skills: %s"] = "Compétences d’armes : %s",
    ["Wood Panel"] = "Panneau en bois",
    ["addon %s"] = "addon %s",
    ["error:"] = "erreur :",
    ["this trainer"] = "ce maître",
    ["unknown"] = "inconnu",
} end)

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("frFR", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Bienvenue dans GnomeLevelUp ! Depuis la version 1.4.0, vous n’avez plus besoin d’analyser les maîtres de classe manuellement : la liste est déjà remplie ! Merci de me signaler tout problème sur GitHub ou Curseforge !",
} end)

-- Trainer-change monitoring and report export.
RegisterLocaleBuilder("frFR", function() return {
    ["Check trainer lists for catalogue changes"] = "Vérifier les modifications des listes des maîtres de classe",
    ["Export trainer report"] = "Exporter le rapport des maîtres de classe",
    ["No trainer catalogue differences have been recorded."] = "Aucune différence avec le catalogue des maîtres de classe n’a été enregistrée.",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "Après /reload ou une déconnexion, envoyez le fichier enregistré à l’auteur de l’addon sur GitHub ou Curseforge. Il contient vos réglages GnomeLevelUp. Vous pouvez aussi copier ci-dessous le rapport seul au format JSON.",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "Une modification des données des maîtres de classe a été détectée. Veuillez saisir /glu trainerreport et m’envoyer le fichier !",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "Options du rapport : saisissez %s pour ouvrir la fenêtre d’exportation et copier le rapport seul au format JSON.",
    ["Trainer reports cleared."] = "Rapports des maîtres de classe effacés.",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "Fichier du rapport enregistré après /reload ou une déconnexion (dans le dossier du client WoW actuel) : %s",
    ["Report file: %s"] = "Fichier du rapport : %s",
} end)

-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("frFR", function() return {
    ["Portrait pulse and starburst"] = "Pulsation et éclat du portrait",
    ["Highlight new abilities"] = "Mettre en évidence les nouvelles techniques",
    ["Emphasize stat gains"] = "Mettre en valeur les gains de caractéristiques",
    ["New ability"] = "Nouvelle technique",
    ["Rank upgrade"] = "Amélioration de rang",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("frFR", function() return {
    ["Portrait sparks"] = "Étincelles du portrait",
    ["New ability sparkles"] = "Étincelles des nouvelles techniques",
    ["Background embers"] = "Braises en arrière-plan",
    ["Frame edge glow"] = "Lueur du cadre",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
RegisterLocaleBuilder("frFR", function() return {
    ["Portrait mote count"] = "Particules du portrait : nombre",
    ["Portrait mote size (%)"] = "Particules du portrait : taille (%)",
    ["Portrait mote opacity (%)"] = "Particules du portrait : opacité (%)",
    ["Starburst mote count"] = "Particules du rayonnement : nombre",
    ["Starburst mote size (%)"] = "Particules du rayonnement : taille (%)",
    ["Starburst mote opacity (%)"] = "Particules du rayonnement : opacité (%)",
    ["Background ember count"] = "Braises d’arrière-plan : nombre",
    ["Background ember size (%)"] = "Braises d’arrière-plan : taille (%)",
    ["Background ember opacity (%)"] = "Braises d’arrière-plan : opacité (%)",
    ["Ability sparkle count"] = "Étincelles des techniques : nombre",
    ["Ability sparkle size (%)"] = "Étincelles des techniques : taille (%)",
    ["Ability sparkle opacity (%)"] = "Étincelles des techniques : opacité (%)",
} end)

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("frFR", function() return {
    ["Portrait and ring settle"] = "Stabilisation du portrait et de l’anneau",
    ["Reveal dividers"] = "Révéler les séparateurs",
} end)
RegisterLocaleBuilder("frFR", function() return { ["Animated Elements"] = "Éléments animés" } end)
RegisterLocaleBuilder("frFR", function() return {
    ["Starburst opacity (%)"] = "Opacité du halo rayonnant (%)",
    ["Portrait pulse opacity (%)"] = "Opacité de l’impulsion du portrait (%)",
    ["Frame edge glow opacity (%)"] = "Opacité de la lueur du cadre (%)",
} end)
RegisterLocaleBuilder("frFR", function() return {
    ["Copy"] = "Copier",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Appuyez sur Ctrl+C pour copier. Le champ sera ensuite vidé.",
} end)

-- Profile controls and sharing messages.
RegisterLocaleBuilder("frFR", function() return {
    ["Profile"] = "Profil",
    ["Save per Character"] = "Enregistrer par personnage",
    ["Profile name"] = "Nom du profil",
    ["Create profile"] = "Créer un profil",
    ["Import / export"] = "Importer / exporter",
    ["Import profile"] = "Importer un profil",
    ["Export profile"] = "Exporter le profil",
    ["Changes are saved automatically."] = "Les changements sont enregistrés automatiquement.",
    ["Profile created."] = "Profil créé.",
    ["Profile imported."] = "Profil importé.",
    ["Invalid profile string or profile name."] = "Chaîne de profil ou nom de profil invalide.",
    ["Enter a unique profile name (up to 80 characters)."] = "Saisissez un nom de profil unique (80 caractères maximum).",
    ["Imported profile"] = "Profil importé",
    ["Press Ctrl+C to copy."] = "Appuyez sur Ctrl+C pour copier.",
} end)

-- Profile-sharing window.
RegisterLocaleBuilder("frFR", function() return {
    ["Profile name (optional)"] = "Nom du profil (facultatif)",
    ["Invalid profile string."] = "Chaîne de profil invalide.",
    ["Invalid profile settings."] = "Paramètres de profil invalides.",
} end)

-- Profile management.
RegisterLocaleBuilder("frFR", function() return {
    ["Rename profile"] = "Renommer le profil",
    ["Delete profile"] = "Supprimer le profil",
    ["Profile renamed."] = "Profil renommé.",
    ["Profile deleted."] = "Profil supprimé.",
    ["Default profile cannot be renamed or deleted."] = "Le profil Default ne peut pas être renommé ni supprimé.",
    ["Profile not found."] = "Profil introuvable.",
    ["Profile limit reached (50)."] = "Limite de profils atteinte (50).",
    ["Delete profile \"%s\"?"] = "Supprimer le profil « %s » ?",
    ["Cancel"] = "Annuler",
    ["Manage profiles"] = "Gérer les profils",
} end)

-- First-run setup.
RegisterLocaleBuilder("frFR", function() return {
    ["GLU First Time Setup"] = "GLU — Première configuration",
    ["Finish setup"] = "Terminer la configuration",
    ["Change these choices anytime in Options."] = "Vous pouvez modifier ces choix à tout moment dans les options.",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("frFR", function() return {
    ["Show pet skills"] = "Afficher les compétences des familiers",
    ["Enable animations"] = "Activer les animations",
} end)

-- Setup heading.
RegisterLocaleBuilder("frFR", function() return { ["Welcome to GnomeLevelUp!"] = "Bienvenue dans GnomeLevelUp !" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("frFR", function() return { ["Background animations"] = "Animations de fond" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("frFR", function() return { ["Horizontal layout"] = "Disposition horizontale" } end)
RegisterLocaleBuilder("frFR", function() return { ["Player 3D portrait"] = "Portrait 3D du joueur" } end)
RegisterLocaleBuilder("frFR", function() return { ["3D model rotation (degrees)"] = "Rotation du modèle 3D (degrés)", ["3D model depth"] = "Profondeur du modèle 3D", ["3D model horizontal position"] = "Position horizontale du modèle 3D", ["3D model vertical position"] = "Position verticale du modèle 3D", ["3D model scale (%)"] = "Échelle du modèle 3D (%)" } end)
RegisterLocaleBuilder("frFR", function() return { ["3D mask size (%)"] = "Taille du masque 3D (%)" } end)
RegisterLocaleBuilder("frFR", function() return { ["3D viewport size (%)"] = "Taille de la fenêtre 3D (%)" } end)
RegisterLocaleBuilder("frFR", function() return { ["Milestone Animations"] = "Animations de palier" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("frFR", function() return { ["Firework size (%)"] = "Taille des feux d’artifice (%)", ["Firework opacity (%)"] = "Opacité des feux d’artifice (%)" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("frFR", function() return { ["Frame inset (px)"] = "Marge du cadre (px)" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("frFR", function() return { ["Portrait ring glint"] = "Éclat de l’anneau du portrait", ["Ability reveal shine"] = "Reflet à l’apparition des capacités", ["Milestone anticipation"] = "Anticipation des niveaux jalons", ["Stat impact sparks"] = "Étincelles des gains de statistiques", ["Background depth"] = "Profondeur de l’arrière-plan", ["Closing animation"] = "Animation de fermeture", ["Milestone color transition"] = "Transition de couleur des niveaux jalons" } end)
RegisterLocaleBuilder("frFR", function() return { ["Screenshot milestones"] = "Capturer les niveaux de palier" } end)
RegisterLocaleBuilder("frFR", function() return { ["Portrait motes"] = "Particules du portrait", ["Background motes"] = "Particules d’arrière-plan" } end)
RegisterLocaleBuilder("frFR", function() return { ["3D Portraits may consume more memory."] = "Les portraits 3D peuvent utiliser davantage de mémoire." } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("frFR", function() return {
    ["Shorten stat totals"] = "Abréger les totaux des caractéristiques",
    ["Relevant stats only"] = "Caractéristiques pertinentes uniquement",
    ["%sk"] = "%sk", ["%sm"] = "%sM", ["%sb"] = "%sMd",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("frFR", function() return { ["Uses game volume"] = "Utilise le volume du jeu" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("frFR", function() return {
    ["Show faster leveling times"] = "Afficher les nouveaux records de montée en niveau",
    ["Fastest level: %s"] = "Nouveau record : %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("frFR", function() return {
    ["Max Level Celebration"] = "Célébration du niveau maximum",
    ["Time to max level: %s"] = "Temps jusqu’au niveau maximum : %s",
    ["%dd %02dh %02dm %02ds"] = "%dj %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Son de l’impact du portrait",
    ["Starburst sound"] = "Son de l’éclat du portrait",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("frFR", function() return {
    ["Time to Level: %s"] = "Temps pour monter de niveau : %s",
    ["New fastest time!:"] = "Nouveau meilleur temps ! :",
    ["New fastest time!: %s"] = "Nouveau meilleur temps ! : %s",
} end)
RegisterLocaleBuilder("frFR", function() return {
    ["Glint finishing spark"] = "Étincelle finale du reflet",
    ["Portrait shine"] = "Reflet du portrait",
    ["Ring surges"] = "Décharges de l’anneau",
    ["Max-level portrait sparks"] = "Étincelles du portrait au niveau maximum",
} end)
RegisterLocaleBuilder("frFR", function() return {
    ["New Best Time!"] = "Nouveau meilleur temps !",
    ["Fastest Time: %s"] = "Meilleur temps : %s",
} end)
RegisterLocaleBuilder("frFR", function() return {
    ["Abbreviate stat names"] = "Abréger les noms des caractéristiques",
} end)
RegisterLocaleBuilder("frFR", function() return {
    ["%sM %sk"] = "%sM %sk",
    ["Recorded level timers and best times reset for this character."] = "Minuteurs de niveau et meilleurs temps enregistrés réinitialisés pour ce personnage.",
} end)

-- Classic Mode and first-time setup descriptions.
RegisterLocaleBuilder("frFR", function() return {
    ["Classic Mode"] = "Mode classique",
    ["Choose the language used by GLU."] = "Choisissez la langue utilisée par GLU.",
    ["Choose the popup background and frame style."] = "Choisissez le fond et le cadre de la fenêtre.",
    ["Arrange portrait, stats and abilities side by side."] = "Disposez portrait, caractéristiques et capacités côte à côte.",
    ["Choose the artwork shown in the portrait ring."] = "Choisissez l’image du portrait.",
    ["Show the level timer and celebrate new best times."] = "Affichez le temps du niveau et célébrez les nouveaux records.",
    ["Use a smaller vertical popup with less empty space."] = "Utilisez une fenêtre verticale plus compacte.",
    ["Show Hunter pet skills and Warlock pet training."] = "Affichez les compétences des familiers du chasseur et du démoniste.",
    ["No decorative animations, similar to earlier GLU releases."] = "Aucune animation décorative, comme dans les anciennes versions de GLU.",
    ["Close the popup by right-clicking it."] = "Fermez la fenêtre avec un clic droit.",
    ["Allow the popup to close while the pointer is over it."] = "Autorisez la fermeture lorsque le pointeur survole la fenêtre.",
    ["Use your class colour for popup accents and text."] = "Utilisez la couleur de classe pour le texte et les ornements.",
    ["Choose the controller button symbols shown in hints."] = "Choisissez les symboles de boutons de manette.",
    ["Show weapon training available to your character."] = "Affichez les entraînements aux armes disponibles.",
    ["Show the money required to learn abilities."] = "Affichez le coût d’apprentissage des capacités.",
    ["Abbreviate large stat totals without changing gain counters."] = "Abrégez les grands totaux sans modifier les gains.",
    ["Show only stats relevant to your current class and specialization."] = "Affichez uniquement les caractéristiques utiles à votre classe et spécialisation.",
} end)

-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("frFR", function() return {
    ["Stat text size"] = "Taille du texte des caractéristiques",
    ["Heading text size"] = "Taille des titres",
    ["Time to Level text size"] = "Taille du texte du temps de niveau",
    ["Level %d - %d"] = "Niveaux %d - %d",
    ["Time for %d levels: %s"] = "Temps pour %d niveaux : %s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
RegisterLocaleBuilder("frFR", function() return {
    ["Show secondary stats"] = "Afficher les statistiques secondaires",
    ["Secondary Stats"] = "Statistiques secondaires",
    ["Replace primary stats with secondary stats halfway through the popup."] = "Remplace les statistiques principales par les statistiques secondaires à mi-parcours de la fenêtre.",
    ["Crit. Strike"] = "Coup critique",
    ["Haste"] = "Hâte",
    ["Mastery"] = "Maîtrise",
    ["Versatility"] = "Polyvalence",
    ["Hit Chance"] = "Chances de toucher",
    ["Expertise"] = "Expertise",
    ["Attack Power"] = "Puissance d’attaque",
    ["Ranged Attack Power"] = "Puissance d’attaque à distance",
    ["Spell Power"] = "Puissance des sorts",
    ["Healing Power"] = "Puissance des soins",
    ["Armor"] = "Armure",
    ["Defense"] = "Défense",
    ["Dodge"] = "Esquive",
    ["Parry"] = "Parade",
    ["Block"] = "Blocage",
    ["Armor Penetration"] = "Pénétration d’armure",
    ["Mana per 5 sec"] = "Mana toutes les 5 s",
} end)

-- Shared descriptions for controller and standard Options.
RegisterLocaleBuilder("frFR", function() return {
    ["Choose the artwork around the portrait."] = "Choisissez le décor autour du portrait.",
    ["Choose artwork for textured themes."] = "Choisissez le décor des thèmes texturés.",
    ["Stretch or tile the background artwork."] = "Étirez ou répétez la texture de fond.",
    ["Adjust how dark the background appears."] = "Réglez l’obscurité du fond.",
    ["Seconds the popup stays visible after its entrance."] = "Durée d’affichage après l’animation d’ouverture, en secondes.",
    ["Resize the whole popup in the current layout."] = "Redimensionnez toute la fenêtre dans la disposition actuelle.",
    ["Resize this text while keeping long lines inside the frame."] = "Redimensionnez ce texte en gardant les longues lignes dans le cadre.",
    ["Prevent dragging the popup to a new position."] = "Empêchez le déplacement de la fenêtre.",
    ["Show a test popup without changing level history."] = "Affichez un aperçu sans modifier l’historique des niveaux.",
    ["Restore default appearance settings."] = "Rétablissez les réglages d’apparence par défaut.",
    ["Enable or disable the GLU level-up popup."] = "Activez ou désactivez la fenêtre de montée de niveau de GLU.",
    ["Hide Blizzard's visual level-up notification."] = "Masquez la notification visuelle de montée de niveau de Blizzard.",
    ["Delay the popup until combat ends."] = "Attendez la fin du combat avant d’afficher la fenêtre.",
    ["Show the GLU shortcut on the minimap."] = "Affichez le raccourci GLU sur la minicarte.",
    ["Let clicks pass through the popup to the game."] = "Laissez les clics traverser la fenêtre vers le jeu.",
    ["Choose how high this window sits above other interface elements."] = "Choisissez la priorité d’affichage de cette fenêtre.",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "Alignez noms, totaux, flèches et gains dans des colonnes communes.",
    ["Use short stat labels, including secondary stats."] = "Utilisez des noms courts, y compris pour les statistiques secondaires.",
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "Prenez une capture d’écran lorsqu’un gain de niveau réel correspond à l’intervalle de jalon sélectionné.",
    ["Save available training information when visiting trainers."] = "Enregistrez les formations disponibles lors des visites aux maîtres.",
    ["Include profession training in trainer scans."] = "Incluez les formations de métiers dans les analyses.",
    ["Show unlocks from the gained level instead of earlier levels."] = "Affichez les techniques du niveau atteint plutôt que des niveaux précédents.",
    ["Hide rank upgrades and show only new abilities."] = "Masquez les améliorations de rang et gardez les nouvelles techniques.",
    ["Include training abilities for your character's pet."] = "Incluez les techniques d’entraînement du familier.",
    ["Show grimoires for your currently summoned pet."] = "Affichez les grimoires du familier actuellement invoqué.",
    ["Scroll long ability lists sideways instead of adding more rows."] = "Faites défiler les longues listes latéralement plutôt que d’ajouter des rangées.",
    ["Play the selected replacement sound on level-up."] = "Jouez le son de remplacement choisi à la montée de niveau.",
    ["Silence Blizzard's ding when using a replacement sound."] = "Coupez le son de Blizzard lors de l’utilisation d’un autre son.",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "Choisissez un son ; Par défaut conserve le son normal de Blizzard.",
    ["Choose which game audio channel plays GLU sounds."] = "Choisissez le canal audio utilisé par GLU.",
    ["Adjust GLU sound volume where the client supports it."] = "Réglez le volume GLU si le client le permet.",
    ["Preview the selected sound."] = "Écoutez le son sélectionné.",
    ["Add celebration effects when crossing a ten-level milestone."] = "Ajoutez des effets aux paliers de dix niveaux.",
    ["Add celebration effects when reaching the level cap."] = "Ajoutez des effets lorsque le niveau maximal est atteint.",
    ["Play the portrait pulse and starburst during the entrance."] = "Animez le portrait et son éclat pendant l’ouverture.",
    ["Make newly learned ability icons shine."] = "Faites briller les icônes des nouvelles techniques.",
    ["Animate stat totals and highlight their changes."] = "Animez les totaux et soulignez leurs variations.",
    ["Show decorative particles around the portrait."] = "Affichez des particules décoratives autour du portrait.",
    ["Show drifting particles behind the popup content."] = "Affichez des particules flottantes derrière le contenu.",
    ["Animate a glow around textured frame edges."] = "Animez une lueur sur les bords des cadres texturés.",
    ["Let the portrait ring settle into place during the entrance."] = "Laissez l’anneau se stabiliser pendant l’ouverture.",
    ["Animate the section divider lines."] = "Animez les séparateurs de sections.",
    ["Sweep a bright glint around the portrait ring."] = "Faites parcourir l’anneau par un reflet lumineux.",
    ["Choose the direction stat rows slide in from."] = "Choisissez la direction d’entrée des lignes de statistiques.",
    ["Change animation speed without changing display duration."] = "Changez la vitesse des animations sans modifier la durée d’affichage.",
    ["Add shadows and glow behind popup text."] = "Ajoutez des ombres et une lueur derrière le texte.",
    ["Use a separate selected profile for this character."] = "Utilisez un profil sélectionné distinct pour ce personnage.",
    ["Choose the settings profile to use."] = "Choisissez le profil de réglages à utiliser.",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "Supprimez les données analysées ; les listes intégrées sont conservées.",
    ["Restore default addon settings."] = "Rétablissez les réglages par défaut de l’addon.",
    ["Open controls to create, rename or delete profiles."] = "Ouvrez les commandes de création, renommage et suppression des profils.",
    ["Reload the interface to apply pending changes."] = "Rechargez l’interface pour appliquer les changements en attente.",
    ["Share settings by copying a profile code."] = "Partagez les réglages en copiant un code de profil.",
    ["Choose the font used by popup text."] = "Choisissez la police du texte de la fenêtre.",
    ["Pause a test popup's timeout only while Options is open."] = "Suspendez le délai d’un aperçu uniquement pendant l’ouverture des options.",
} end)

-- Minimap preview shortcut.
RegisterLocaleBuilder("frFR", function() return { ["Middle-click: Preview Level-Up"] = "Clic du milieu : aperçu de l’alerte" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("frFR", function() return {
    ["Switch to secondary stats at"] = "Passer aux statistiques secondaires à",
    ["Choose the percentage of display time spent on primary stats."] = "Choisissez la part du temps d’affichage consacrée aux statistiques principales.",
    ["Replace primary stats with secondary stats during the popup."] = "Remplace les statistiques principales par les statistiques secondaires pendant l’alerte.",
    ["Right-click: Replay last level-up"] = "Clic droit : revoir le dernier gain de niveau",
    ["No recorded level-up to replay yet."] = "Aucun gain de niveau enregistré à revoir.",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("frFR", function() return {
    ["Adjust the space between popup sections."] = "Ajuste l’espace entre les sections de l’alerte.",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "Compare les services des maîtres au catalogue inclus et propose un rapport en cas de différence.",
    ["Open saved trainer differences and instructions for exporting a report."] = "Ouvre les différences enregistrées et les instructions d’export du rapport.",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "Inclut les grimoires disponibles pour tous les démons du démoniste, pas seulement le familier actif.",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "Saisissez le chemin d’un fichier OGG relatif à l’addon pour le son personnalisé.",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "Choisissez un son personnalisé enregistré par cet addon ou SharedMedia.",
    ["Show advanced tuning controls, test commands and performance counters."] = "Affiche les réglages avancés, commandes de test et compteurs de performances.",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "Affiche les durées mesurées dans la discussion. Activez le débogage pour les collecter.",
    ["Clear performance counters before measuring another popup."] = "Efface les compteurs avant de mesurer une autre alerte.",
    ["Choose automatic client detection or force Retail or Forever rules."] = "Choisissez la détection automatique du client ou forcez les règles Retail ou Forever.",
    ["Update the displayed trainer-cache information."] = "Actualise les informations affichées sur le cache des maîtres.",
    ["Enter a name to create a profile or rename the current one."] = "Saisissez un nom pour créer un profil ou renommer le profil actuel.",
    ["Save the current options as a new profile with the entered name."] = "Enregistre les options actuelles dans un nouveau profil portant le nom saisi.",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "Renomme le profil sélectionné. Le profil par défaut ne peut pas être renommé.",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "Supprime le profil sélectionné après confirmation. Le profil par défaut ne peut pas être supprimé.",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "Rétablit les options par défaut ; conserve les temps de niveau et rapports enregistrés.",
    ["Move the 3D portrait closer to or farther from the camera."] = "Rapproche ou éloigne le portrait 3D de la caméra.",
    ["Move the 3D portrait left or right inside its viewport."] = "Déplace le portrait 3D à gauche ou à droite dans sa zone d’affichage.",
    ["Move the 3D portrait up or down inside its viewport."] = "Déplace le portrait 3D vers le haut ou le bas dans sa zone d’affichage.",
    ["Turn the 3D portrait around its vertical axis."] = "Fait tourner le portrait 3D autour de son axe vertical.",
    ["Change the size of the 3D character model."] = "Modifie la taille du modèle 3D du personnage.",
    ["Change the circular mask that clips the 3D portrait."] = "Modifie le masque circulaire qui découpe le portrait 3D.",
    ["Change the 3D rendering area around the portrait."] = "Modifie la zone de rendu 3D autour du portrait.",
    ["Resize the ring artwork without resizing the portrait."] = "Redimensionne l’illustration de l’anneau sans redimensionner le portrait.",
    ["Move the ring artwork left or right."] = "Déplace l’anneau à gauche ou à droite.",
    ["Move the ring artwork up or down."] = "Déplace l’anneau vers le haut ou le bas.",
    ["Adjust the empty inset between textured borders and popup content."] = "Ajuste la marge vide entre les bordures texturées et le contenu de l’alerte.",
    ["Mirror this frame piece horizontally."] = "Retourne ce morceau du cadre horizontalement.",
    ["Mirror this frame piece vertically."] = "Retourne ce morceau du cadre verticalement.",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "Modifie la couleur de l’élément indiqué. Les couleurs de classe peuvent remplacer les couleurs d’accent.",
    ["Tint this individual frame piece."] = "Teinte uniquement ce morceau du cadre.",
    ["Rotate this individual frame piece."] = "Fait tourner uniquement ce morceau du cadre.",
    ["Set the number of particles for this effect. Zero hides them."] = "Définit le nombre de particules de cet effet. Zéro les masque.",
    ["Resize this effect's particles as a percentage of their normal size."] = "Redimensionne les particules de cet effet en pourcentage de leur taille normale.",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "Définit l’opacité des particules de cet effet. Zéro les rend invisibles.",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "Définit l’opacité de l’animation indiquée. Zéro la rend invisible.",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "Joue un son au déclenchement de cette animation. Saisissez un identifiant de fichier sonore WoW ; 0 désactive ce son.",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Célèbre chaque palier de dix niveaux avec une anticipation du portrait, des accents plus brillants et des effets de statistiques. Le mode classique désactive ces ornements.",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "Au niveau maximum, ajoute des feux d’artifice courbes aux couleurs de classe, des étincelles sur l’anneau et davantage de particules de fond. Le mode classique les désactive.",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "Fait pulser l’anneau, puis révèle une étoile grandissante derrière le portrait. Les paliers et le niveau maximum ajoutent aussi un reflet répété sur le portrait.",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "Ajoute un reflet d’apparition, une lueur et des étincelles aux nouvelles capacités. Les améliorations de rang restent sans surbrillance.",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "Fait progresser les totaux depuis leurs anciennes valeurs, puis illumine les nombres modifiés. Aux paliers, ajoute aussi des étincelles à la fin du compteur.",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "Libère de petites lumières flottantes autour du portrait après l’étoile. Nécessite le pouls et l’étoile du portrait.",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "Affiche des particules montantes derrière l’alerte. Les paliers et le niveau maximum augmentent leur densité ; le niveau maximum les accélère aussi.",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "Fait passer une lueur déclinante sur les bordures texturées à l’ouverture. Indisponible avec le thème moderne.",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "Commence avec un portrait légèrement agrandi, puis revient doucement à sa taille normale. Les paliers ajoutent un bref éclat d’anticipation.",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "Étend les lignes de séparation à l’apparition de chaque section. Le mode classique garde les transitions du texte mais désactive ce décor.",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "Fait parcourir l’anneau par une étincelle brillante, terminant par un éclat plus grand qui s’estompe. Au niveau maximum, cet éclat grandit et scintille.",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("frFR", function() return { ["Trellis"] = "Treillis" } end)

-- Flat background selector.
RegisterLocaleBuilder("frFR", function() return { ["Solid Colour"] = "Couleur unie" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("frFR", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "Choisissez la couleur et la transparence du fond. Couleur unie utilise directement cette couleur." } end)

-- Marine background selector.
RegisterLocaleBuilder("frFR", function() return { ["Coral"] = "Corail" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("frFR", function() return { ["Scratched Stone"] = "Pierre rayée" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("frFR", function() return { ["Reset Theme Hues"] = "Réinitialiser les teintes du thème", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "Rétablit les teintes par défaut du fond, du cadre et du cercle de portrait sélectionnés. Les autres teintes enregistrées sont conservées." } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("frFR", function() return { ["Background Fill Mode"] = "Mode de remplissage du fond" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("frFR", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "Remplir conserve les proportions et rogne le surplus, Étirer adapte au cadre et Répéter répète le motif." } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("frFR", function() return { ["Alliance Brick"] = "Briques de l’Alliance" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("frFR", function() return { ["Memory: %s"] = "Mémoire : %s", ["Memory: unavailable"] = "Mémoire : indisponible" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("frFR", function() return { ["Performance profiling enabled."] = "Profilage des performances activé.", ["Performance profiling disabled."] = "Profilage des performances désactivé.", ["Profiling is off. Use /glu perf on to record measurements."] = "Le profilage est désactivé. Utilisez /glu perf on pour enregistrer des mesures." } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("frFR", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - démarrer/arrêter le profilage (arrêté après rechargement)", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - afficher les diagnostics de performance enregistrés" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("frFR", function() return { ["Level History"] = "Historique des niveaux", ["Compare account-wide bests"] = "Comparer les records du compte", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "Comparer les nouveaux temps au meilleur niveau enregistré parmi vos personnages du même mode de jeu.", ["Character"] = "Personnage", ["Choose a character whose recorded level times you want to view."] = "Choisir le personnage dont vous souhaitez consulter les temps.", ["History mode"] = "Mode de l’historique", ["View Retail or Forever history. Records are kept separate."] = "Consulter l’historique Retail ou Forever. Les données restent séparées.", ["Reset this character's times"] = "Réinitialiser les temps de ce personnage", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "Effacer les temps et records de ce personnage dans les deux modes. Les autres personnages sont conservés.", ["Fill sample times (20h)"] = "Temps de test (20 h)", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "Remplir chaque niveau avec un temps temporaire de 20 heures. Les nouveaux records remplacent les exemples sans modifier les données existantes.", ["Clear sample history"] = "Effacer les temps de test", ["Remove the temporary sample times and show real records again."] = "Supprimer les temps temporaires et afficher les vrais enregistrements.", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "Seuls les personnages avec des temps de niveau enregistrés sont affichés. Les niveaux manquants affichent un tiret.", ["Sample history (not saved)"] = "Historique de test (non enregistré)", ["Recorded: %d / %d"] = "Enregistrés : %d / %d", ["Total: %s"] = "Total : %s", ["Recorded time"] = "Temps enregistré", ["Personal best"] = "Record personnel", ["Account best"] = "Record du compte", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "Consulter les temps enregistrés et vos meilleurs temps parmi vos personnages. Survoler une ligne pour voir quel personnage a établi le record personnel." } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("frFR", function() return { ["Milestone interval"] = "Intervalle des paliers", ["Every 5 levels"] = "Tous les 5 niveaux", ["Every 10 levels"] = "Tous les 10 niveaux", ["Every 20 levels"] = "Tous les 20 niveaux", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "Choisissez la fréquence des animations et des captures d’écran de jalon. Les animations de niveau maximum ont leur propre option.", ["Add celebration effects at the selected milestone interval."] = "Ajouter des effets aux paliers sélectionnés.", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Célébrer les paliers sélectionnés avec anticipation du portrait, accents lumineux et effets de statistiques. Le mode classique désactive ces effets.", ["Choose a level up to 1000 that is a multiple of %d."] = "Choisissez un niveau jusqu’à 1000 qui soit un multiple de %d." } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("frFR", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "Impossible de préparer la fenêtre de niveau. Essayez /reload. Si cela se reproduit, signalez cette erreur : %s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "Impossible de jouer le son choisi. Choisissez-en un autre dans Options > Son. Détails : %s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "La fenêtre de niveau n’a pas pu s’afficher. Essayez /reload. Si cela se reproduit, signalez l’erreur ci-dessus.", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "Le niveau maximum est indisponible. Attendez la fin du chargement, puis réessayez /glu maxlevel.", ["Paste the complete GLU profile export, then try again."] = "Collez l’exportation complète du profil GLU, puis réessayez.", ["Export the profile again from an up-to-date GLU installation."] = "Exportez à nouveau le profil depuis une installation GLU à jour." } end)
RegisterLocaleBuilder("frFR", function() return { ["Ability Cost Size"] = "Taille du coût des techniques", ["Adjust the size of ability prices for the current layout."] = "Ajuste la taille du prix des techniques dans la disposition actuelle." } end)
RegisterLocaleBuilder("frFR", function() return { ["Learning cost: %s"] = "Coût d’apprentissage : %s", ["%d abilities"] = "%d techniques", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "Affiche une alerte de test sans modifier l’historique. Faites un clic droit pour choisir le nombre de techniques." } end)
RegisterLocaleBuilder("frFR", function() return { ["Show prices in tooltips"] = "Afficher les prix dans les infobulles", ["Show full learning costs when hovering over abilities."] = "Affiche le prix complet au survol des techniques." } end)
RegisterLocaleBuilder("frFR", function() return { ["Contributors"] = "Contributeurs" } end)
RegisterLocaleBuilder("frFR", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "Échec de la capture des caractéristiques : Les changements attendus manquaient encore après plusieurs tentatives.",
    ["3D Portrait render failed: The player model did not load in time."] = "Échec de l’affichage du portrait 3D : Le modèle du personnage ne s’est pas chargé à temps.",
    ["3D Portrait render failed: Could not assign the player model."] = "Échec de l’affichage du portrait 3D : Impossible d’assigner le modèle du personnage.",
} end)
RegisterLocaleBuilder("frFR", function() return { ["Theme sound"] = "Son du thème" } end)
RegisterLocaleBuilder("frFR", function() return {
    ["Idle motes sound"] = "Son des particules ambiantes",
    ["Fireworks sound"] = "Son des feux d’artifice",
    ["Fade-in sound"] = "Son du fondu d’ouverture",
    ["Fade-out sound"] = "Son du fondu de fermeture",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "Saisissez un identifiant de fichier audio de WoW pour remplacer ce son. Saisissez 0 pour annuler le remplacement.",
} end)
RegisterLocaleBuilder("frFR", function() return {
    ["Use Theme Sounds"] = "Utiliser les sons du thème",
    ["Play the theme's animation sounds without changing your level-up sound."] = "Joue les sons d’animation du thème sans modifier le son de montée de niveau.",
    ["Class-coloured portrait background"] = "Fond du portrait aux couleurs de classe",
    ["Fill the background behind the 3D player portrait with your class colour."] = "Colore le fond derrière le portrait 3D du personnage avec la couleur de votre classe.",
} end)
RegisterLocaleBuilder("frFR", function() return { ["Stat glint sound"] = "Son d’éclat des caractéristiques" } end)
RegisterLocaleBuilder("frFR", function() return { ["Screenshot every level"] = "Capture d’écran à chaque niveau", ["Take a screenshot after every real level-up."] = "Prenez une capture d’écran à chaque gain de niveau réel.", ["Could not save the level-up screenshot."] = "Impossible d’enregistrer la capture d’écran de la montée de niveau." } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("frFR", function() return {
    ["Strength"] = "Force", ["Agility"] = "Agilité", ["Stamina"] = "Endurance", ["Intellect"] = "Intelligence", ["Spirit"] = "Esprit",
    ["Level"] = "Niveau",
    ["Health"] = "Points de vie", ["Mana"] = "Mana", ["Default"] = "Par défaut", ["%d pt"] = "%d pt",
    ["Rage"] = "Rage", ["Energy"] = "Énergie", ["Focus"] = "Focalisation", ["Runic Power"] = "Puissance runique", ["Power"] = "Ressource",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("frFR", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "Erreur (%s). Saisissez /glu debugreport et envoyez-moi le rapport !",
    ["Debug report"] = "Rapport de débogage",
    ["No GnomeLevelUp errors have been recorded."] = "Aucune erreur de GnomeLevelUp n’a été enregistrée.",
    ["Stat capture"] = "Capture des caractéristiques",
    ["3D portrait rendering"] = "Rendu du portrait 3D",
    ["Level-up popup"] = "Fenêtre de montée de niveau",
    ["Screenshot"] = "Capture d’écran",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("frFR", function() return {
    ["Complete trainer reporting"] = "Rapports complets des maîtres de classe",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "Enregistre tous les prix lisibles des maîtres de classe en mode débogage. Exportez les prix proposés avec /glu trainerreport.",
    ["Clear all"] = "Tout effacer",
} end)
