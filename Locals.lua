local ADDON_NAME, ns = ...

-- All languages are available in the options menu. English is the fallback
-- for missing translations. Set a flag to false to hide a language.
local ENABLED_LOCALES = {
    enUS = true,  -- English (also enGB); keep enabled
    frFR = true,  -- Français
    esES = true,  -- Español (España)
    esMX = true,  -- Español (Latinoamérica)
    deDE = true,  -- Deutsch
    itIT = true,  -- Italiano
    ptBR = true,  -- Português (Brasil)
    ruRU = true,  -- Русский
    koKR = true,  -- 한국어
    zhCN = true,  -- 简体中文
    zhTW = true,  -- 繁體中文
}

local LANGUAGE_NAMES = {
    { "enUS", "English" }, { "frFR", "Français" },
    { "esES", "Español (España)" }, { "esMX", "Español (Latinoamérica)" },
    { "deDE", "Deutsch" }, { "itIT", "Italiano" },
    { "ptBR", "Português (Brasil)" }, { "ruRU", "Русский" },
    { "koKR", "한국어" }, { "zhCN", "简体中文" }, { "zhTW", "繁體中文" },
}

-- Add new UI strings to all ten non-English dictionaries.
-- English UI strings are the canonical keys. Never translate saved-variable
-- keys, API identifiers, slash commands, spell IDs or asset paths.
local locales = { enUS = {} }
local localeBuilders = {}

-- Keep the constructors, not ten populated dictionaries. Switching language
-- releases the previous dictionary while keeping every language available.
local function RegisterLocaleBuilder(locale, build)
    if not ENABLED_LOCALES[locale] then return end
    local builders = localeBuilders[locale]
    if not builders then builders = {}; localeBuilders[locale] = builders end
    builders[#builders + 1] = build
end
local clientLocale = type(GetLocale) == "function" and GetLocale() or "enUS"
local activeLocale = "enUS"
local function CanonicalLocale(locale)
    return locale == "enGB" and "enUS" or locale
end

function ns.IsLocaleEnabled(locale)
    locale = CanonicalLocale(locale)
    return locale == "enUS" or ENABLED_LOCALES[locale] == true
end

function ns.GetLanguageChoices()
    local choices = { { value = "auto", label = "Auto Detect" } }
    for _, language in ipairs(LANGUAGE_NAMES) do
        if ns.IsLocaleEnabled(language[1]) then
            choices[#choices + 1] = { value = language[1], label = language[2] }
        end
    end
    return choices
end

-- Show the actual English fallback if a stored manual selection was disabled.
-- Preserve the stored choice so re-enabling that locale restores it on reload.
function ns.GetLanguageSelection(selection)
    if selection == nil or selection == "auto" then return "auto" end
    selection = CanonicalLocale(selection)
    return ns.IsLocaleEnabled(selection) and selection or "enUS"
end

function ns.RegisterLocale(locale, translations)
    if type(locale) ~= "string" or type(translations) ~= "table" then return end
    if not ns.IsLocaleEnabled(locale) then return end
    locales[locale] = locales[locale] or {}
    for source, translated in pairs(translations) do
        if type(source) == "string" and type(translated) == "string" then
            locales[locale][source] = translated
        end
    end
end

function ns.SetLocale(locale)
    if locale == nil or locale == "auto" then locale = clientLocale end
    locale = CanonicalLocale(locale)
    locale = ns.IsLocaleEnabled(locale) and (locale == "enUS" or localeBuilders[locale] or locales[locale]) and locale or "enUS"
    if activeLocale == locale and locales[locale] then return end
    if activeLocale ~= "enUS" then locales[activeLocale] = nil end
    if not locales[locale] then
        local entries
        for _, build in ipairs(localeBuilders[locale] or {}) do
            local translations = build()
            if not entries then
                entries = translations
            else
                for source, translated in pairs(translations) do entries[source] = translated end
            end
        end
        locales[locale] = entries or {}
    end
    activeLocale = locale
end

function ns.GetLocale()
    return activeLocale
end

function ns.L(source, ...)
    if type(source) ~= "string" then return source end
    local translated = locales[activeLocale][source] or source
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, translated, ...)
        if ok then return formatted end
        -- A malformed translation must not leave unexpanded format tokens.
        ok, formatted = pcall(string.format, source, ...)
        if ok then return formatted end
    end
    return translated
end

function ns.LocalizeChoiceLabel(choice)
    if type(choice) ~= "table" then return ns.L(choice) end
    if choice.literal then return choice.label or choice.value or "" end
    return ns.L(choice.label or choice.value or "")
end

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

local function BuildSpanish() return {
    ["%s (recommended for gamepad)"] = "%s (recomendado para mando)",
    ["%s hue"] = "Tono: %s",
    ["%s rotation"] = "Rotación: %s",
    ["A to clear"] = "A para borrar",
    ["A to play"] = "A para reproducir",
    ["A to preview"] = "A para vista previa",
    ["A to print"] = "A para mostrar",
    ["A to reset"] = "A para restablecer",
    ["A trainer rescan is required."] = "Es necesario volver a registrar los datos de un instructor.",
    ["Abilities"] = "Facultades",
    ["Abilities header"] = "Encabezado de facultades",
    ["Ability icon border"] = "Borde de iconos de facultades",
    ["Adjust"] = "Ajustar",
    ["Alarm Clock"] = "Despertador",
    ["Alliance"] = "Alianza",
    ["Alliance ring"] = "Aro de la Alianza",
    ["Allow click-through"] = "Dejar pasar los clics",
    ["Alternate"] = "Alternar",
    ["Ambience"] = "Ambiente",
    ["Animation"] = "Animación",
    ["Animation speed"] = "Velocidad de animación",
    ["Appearance"] = "Apariencia",
    ["Auction Window Open"] = "Abrir casa de subastas",
    ["Auto (below preview)"] = "Auto (debajo de la vista previa)",
    ["Auto Detect"] = "Detección automática",
    ["Automatically save trainer data"] = "Guardar datos automáticamente",
    ["Background"] = "Fondo",
    ["Background hue"] = "Tono del fondo",
    ["Background opacity"] = "Opacidad del fondo",
    ["Background texture"] = "Textura del fondo",
    ["Black Metal"] = "Metal negro",
    ["Bloodlord Mandokir"] = "Señor sangriento Mandokir",
    ["Bottom edge"] = "borde inferior",
    ["Bottom-left corner"] = "esquina inferior izquierda",
    ["Bottom-right corner"] = "esquina inferior derecha",
    ["by %s"] = "por %s",
    ["Cache Status"] = "Estado de la caché",
    ["Cache status unavailable."] = "Estado de la caché no disponible.",
    ["Center"] = "centro",
    ["Changes apply after reloading the UI."] = "Los cambios se aplican al recargar la interfaz.",
    ["Class icon"] = "Icono de clase",
    ["Clear trainer cache"] = "Borrar caché de instructores",
    ["Click to open options"] = "Haz clic para abrir opciones",
    ["Close"] = "Cerrar",
    ["Colors"] = "Colores",
    ["Compact Layout"] = "Diseño compacto",
    ["Controller glyphs"] = "Iconos de botones del mando",
    ["Controller menu frame strata"] = "Capa de visualización del menú del mando",
    ["Copper ring"] = "Aro de cobre",
    ["Custom"] = "Personalizado",
    ["Custom sound"] = "Sonido personalizado",
    ["Custom sound file"] = "Archivo de sonido personalizado",
    ["Debug"] = "Depuración",
    ["Default font"] = "Fuente predeterminada",
    ["Dialog"] = "Diálogo",
    ["Display duration"] = "Duración en pantalla",
    ["Don't show until combat ends"] = "Mostrar al terminar el combate",
    ["Drag to move"] = "Arrastra para mover",
    ["Enable addon"] = "Activar addon",
    ["Enable debug commands"] = "Activar comandos de depuración",
    ["Equal-width stat text"] = "Igualar ancho del texto de estadísticas",
    ["Fill"] = "Rellenar",
    ["Filter grimoires by active pet"] = "Grimorios de la mascota invocada",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "Versión del juego: %s\nClase: %s\nFacultades en caché: %d\nÚltimo instructor: %s\nÚltimo registro: %s\nEsquema: %d%s",
    ["Flip H"] = "Invertir H",
    ["Flip V"] = "Invertir V",
    ["Font"] = "Fuente",
    ["Frame"] = "Marco",
    ["Frame hue"] = "Tono del marco",
    ["Frame strata"] = "Capa de visualización del marco",
    ["Fullscreen"] = "Pantalla completa",
    ["Fullscreen Dialog"] = "Diálogo a pantalla completa",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - Opciones del mando",
    ["Gnomeregan"] = "Gnomeregan",
    ["Hide Blizzard level-up toast"] = "Ocultar aviso de nivel de Blizzard",
    ["High"] = "Alta",
    ["Horde"] = "Horda",
    ["Horde ring"] = "Aro de la Horda",
    ["Ignore mouseover delay"] = "No retrasar cierre al pasar el ratón",
    ["Improved value"] = "Valor tras subir de nivel",
    ["Include profession trainers"] = "Incluir instructores de profesión",
    ["Language"] = "Idioma",
    ["Left"] = "Izquierda",
    ["Left edge"] = "borde izquierdo",
    ["Level %d"] = "Nivel %d",
    ["Level Up (default)"] = "Subida de nivel (predeterminado)",
    ["Level number"] = "Número de nivel",
    ["Lock Location"] = "Bloquear posición",
    ["Low"] = "Baja",
    ["Master"] = "Volumen general",
    ["Medium"] = "Media",
    ["Mode"] = "Modo",
    ["Modern"] = "Moderno",
    ["Move"] = "Mover",
    ["Music"] = "Música",
    ["Mute Blizzard level-up sound"] = "Silenciar sonido de nivel de Blizzard",
    ["Never"] = "Nunca",
    ["New trainer entries saved: %d (%s)."] = "Entradas nuevas guardadas: %d (instructor: %s).",
    ["No new skills this level"] = "Sin facultades nuevas a este nivel",
    ["No portrait ring"] = "Sin aro",
    ["No registered custom sounds"] = "No hay sonidos personalizados disponibles",
    ["No stat changes"] = "Sin cambios en las estadísticas",
    ["No trainer data for this class.\nVisit your class trainer."] = "Sin datos para esta clase.\nVisita a tu instructor de clase.",
    ["No unlearned skills available"] = "No hay facultades sin aprender",
    ["None"] = "Ninguno",
    ["Off"] = "Desactivado",
    ["On"] = "Activado",
    ["Only display new skills"] = "Facultades nuevas, sin rangos superiores",
    ["Only skills unlocked at this level"] = "Solo facultades desbloqueadas a este nivel",
    ["Open Controller Options"] = "Opciones del mando",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "Opcional. Sustituye el sonido anterior. Ejemplo: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "Reproducir",
    ["Play sound on level up"] = "Reproducir sonido al subir de nivel",
    ["Player portrait"] = "Retrato del jugador",
    ["Popup scale"] = "Escala del aviso de nivel",
    ["Portrait"] = "Retrato",
    ["Portrait border"] = "Borde del retrato",
    ["Portrait ring"] = "Aro del retrato",
    ["Portrait ring hue"] = "Tono del aro",
    ["Portrait ring offset X"] = "Desplazamiento X del aro",
    ["Portrait ring offset Y"] = "Desplazamiento Y del aro",
    ["Portrait ring scale"] = "Escala del aro",
    ["Preview Level-Up"] = "Vista previa del aviso",
    ["Print performance report"] = "Informe de rendimiento",
    ["Quest Complete"] = "Misión completada",
    ["Ready Check"] = "Comprobación de listos",
    ["Reduced motion"] = "Reducir animaciones",
    ["Refresh Cache Status"] = "Actualizar caché",
    ["Registered custom sound"] = "Sonido personalizado disponible",
    ["Reload UI"] = "Recargar interfaz",
    ["Reset Appearance"] = "Restablecer apariencia",
    ["Reset all options"] = "Restablecer todas las opciones",
    ["Reset performance data"] = "Borrar mediciones",
    ["Reset to Defaults"] = "Valores por defecto",
    ["Right"] = "Derecha",
    ["Right edge"] = "borde derecho",
    ["Right-click to close"] = "Clic derecho para cerrar",
    ["Right-click to toggle the addon"] = "Clic derecho para activar o desactivar",
    ["Section divider"] = "Separador de secciones",
    ["Section padding"] = "Separación entre secciones",
    ["Select"] = "Seleccionar",
    ["Show Hunter pet abilities"] = "Facultades de mascotas de cazador",
    ["Show Warlock pet abilities"] = "Facultades de mascotas de brujo",
    ["Show all available grimoires"] = "Mostrar todos los grimorios disponibles",
    ["Show learning costs"] = "Mostrar costes de aprendizaje",
    ["Show minimap button"] = "Mostrar botón del minimapa",
    ["Show text shadows"] = "Sombra del texto",
    ["Show time played this level"] = "Mostrar tiempo para subir de nivel",
    ["Show unlearned weapon skills"] = "Habilidades con armas sin aprender",
    ["Skipped %d future skills without a readable required level."] = "Se han omitido %d facultades de niveles superiores cuyo nivel requerido no se pudo leer.",
    ["Slide direction"] = "Dirección del deslizamiento",
    ["Some options are not available in the controller menu."] = "Algunas opciones no están disponibles en el menú del mando.",
    ["Sound"] = "Sonido",
    ["Sound Effects"] = "Efectos de sonido",
    ["Sound channel"] = "Canal de sonido",
    ["Sound volume"] = "Volumen del sonido",
    ["Stat name / old value"] = "Estadística / valor anterior",
    ["Stats Gained"] = "Mejoras de estadísticas",
    ["Stats header"] = "Encabezado de estadísticas",
    ["Steel ring"] = "Aro de acero",
    ["Stretch"] = "Estirar",
    ["Suspend Preview"] = "Mantener vista previa",
    ["Tabs"] = "Pestañas",
    ["Text"] = "Texto",
    ["Textures"] = "Texturas",
    ["The level-up screen failed to display (see above). Please report this error."] = "No se pudo mostrar el aviso de nivel (ver arriba). Informa de este error.",
    ["Theme"] = "Tema",
    ["Tile"] = "Mosaico",
    ["Time to level: %dh %02dm"] = "Subida de nivel: %d h %02d min",
    ["Time to level: %dm %02ds"] = "Subida de nivel: %d min %02d s",
    ["Time to level: %ds"] = "Subida de nivel: %d s",
    ["Title"] = "Título",
    ["Tooltip (highest)"] = "Descripción emergente (superior)",
    ["Top edge"] = "borde superior",
    ["Top-left corner"] = "esquina superior izquierda",
    ["Top-right corner"] = "esquina superior derecha",
    ["Trainer Data"] = "Datos de instructores",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "Se han actualizado los datos de los instructores. Visita a tu instructor de clase para registrar las facultades y sus costes de aprendizaje.",
    ["Use class colors"] = "Usar colores de clase",
    ["Use horizontal scrolling"] = "Activar desplazamiento horizontal",
    ["Version %s"] = "Versión %s",
    ["Warlock Grimoires"] = "Grimorios de brujo",
    ["Weapon skills: %s"] = "Habilidades con armas: %s",
    ["Wood Panel"] = "Panel de madera",
    ["addon %s"] = "addon %s",
    ["error:"] = "error:",
    ["this trainer"] = "este instructor",
    ["unknown"] = "desconocido",
} end
RegisterLocaleBuilder("esES", BuildSpanish)

-- Reuse Spanish vocabulary while keeping independent enable/disable flags.
RegisterLocaleBuilder("esMX", BuildSpanish)
RegisterLocaleBuilder("esMX", function() return {
    ["%s (recommended for gamepad)"] = "%s (recomendado para control)",
    ["Controller glyphs"] = "Iconos de botones del control",
    ["Controller menu frame strata"] = "Capa de visualización del menú del control",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - Opciones del control",
    ["Ignore mouseover delay"] = "No retrasar cierre al pasar el mouse",
    ["Open Controller Options"] = "Opciones del control",
    ["Show learning costs"] = "Mostrar costos de aprendizaje",
    ["Some options are not available in the controller menu."] = "Algunas opciones no están disponibles en el menú del control.",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "Se han actualizado los datos de los instructores. Visita a tu instructor de clase para registrar las facultades y sus costos de aprendizaje.",
} end)

RegisterLocaleBuilder("deDE", function() return {
    ["%s (recommended for gamepad)"] = "%s (für Gamepad empfohlen)",
    ["%s hue"] = "Farbton: %s",
    ["%s rotation"] = "Drehung: %s",
    ["A to clear"] = "A: Löschen",
    ["A to play"] = "A: Abspielen",
    ["A to preview"] = "A: Vorschau",
    ["A to print"] = "A: Bericht anzeigen",
    ["A to reset"] = "A: Zurücksetzen",
    ["A trainer rescan is required."] = "Die Daten müssen erneut bei einem Lehrer erfasst werden.",
    ["Abilities"] = "Fähigkeiten",
    ["Abilities header"] = "Fähigkeitenüberschrift",
    ["Ability icon border"] = "Rand der Fähigkeitensymbole",
    ["Adjust"] = "Anpassen",
    ["Alarm Clock"] = "Wecker",
    ["Alliance"] = "Allianz",
    ["Alliance ring"] = "Allianzrahmen",
    ["Allow click-through"] = "Mausklicks durchlassen",
    ["Alternate"] = "Abwechselnd",
    ["Ambience"] = "Umgebung",
    ["Animation"] = "Animation",
    ["Animation speed"] = "Animationsgeschwindigkeit",
    ["Appearance"] = "Aussehen",
    ["Auction Window Open"] = "Auktionshaus öffnen",
    ["Auto (below preview)"] = "Automatisch (unter Vorschau)",
    ["Auto Detect"] = "Automatisch erkennen",
    ["Automatically save trainer data"] = "Lehrerdaten automatisch speichern",
    ["Background"] = "Hintergrund",
    ["Background hue"] = "Hintergrundfarbton",
    ["Background opacity"] = "Hintergrunddeckkraft",
    ["Background texture"] = "Hintergrundtextur",
    ["Black Metal"] = "Schwarzes Metall",
    ["Bloodlord Mandokir"] = "Blutfürst Mandokir",
    ["Bottom edge"] = "Unterer Rand",
    ["Bottom-left corner"] = "Untere linke Ecke",
    ["Bottom-right corner"] = "Untere rechte Ecke",
    ["by %s"] = "von %s",
    ["Cache Status"] = "Cachestatus",
    ["Cache status unavailable."] = "Cachestatus nicht verfügbar.",
    ["Center"] = "Mitte",
    ["Changes apply after reloading the UI."] = "Änderungen werden nach dem Neuladen der Oberfläche übernommen.",
    ["Class icon"] = "Klassensymbol",
    ["Clear trainer cache"] = "Lehrercache leeren",
    ["Click to open options"] = "Klicken, um die Optionen zu öffnen",
    ["Close"] = "Schließen",
    ["Colors"] = "Farben",
    ["Compact Layout"] = "Kompaktes Layout",
    ["Controller glyphs"] = "Gamepad-Tastensymbole",
    ["Controller menu frame strata"] = "Anzeigeebene des Gamepad-Menüs",
    ["Copper ring"] = "Kupferrahmen",
    ["Custom"] = "Benutzerdefiniert",
    ["Custom sound"] = "Benutzerdefinierter Sound",
    ["Custom sound file"] = "Eigene Sounddatei",
    ["Debug"] = "Fehlersuche",
    ["Default font"] = "Standardschrift",
    ["Dialog"] = "Dialog",
    ["Display duration"] = "Anzeigedauer",
    ["Don't show until combat ends"] = "Erst nach Kampfende anzeigen",
    ["Drag to move"] = "Zum Verschieben ziehen",
    ["Enable addon"] = "Addon aktivieren",
    ["Enable debug commands"] = "Debugbefehle aktivieren",
    ["Equal-width stat text"] = "Attributtexte gleich breit ausrichten",
    ["Fill"] = "Ausfüllen",
    ["Filter grimoires by active pet"] = "Grimoires nach aktivem Begleiter filtern",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "Spielversion: %s\nKlasse: %s\nGespeicherte Fähigkeiten: %d\nLetzter Lehrer: %s\nLetzte Erfassung: %s\nSchema: %d%s",
    ["Flip H"] = "Horizontal spiegeln",
    ["Flip V"] = "Vertikal spiegeln",
    ["Font"] = "Schriftart",
    ["Frame"] = "Rahmen",
    ["Frame hue"] = "Rahmenfarbton",
    ["Frame strata"] = "Anzeigeebene des Rahmens",
    ["Fullscreen"] = "Vollbild",
    ["Fullscreen Dialog"] = "Vollbilddialog",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - Gamepad-Optionen",
    ["Gnomeregan"] = "Gnomeregan",
    ["Hide Blizzard level-up toast"] = "Blizzards Stufenaufstiegsanzeige ausblenden",
    ["High"] = "Hoch",
    ["Horde"] = "Horde",
    ["Horde ring"] = "Horderahmen",
    ["Ignore mouseover delay"] = "Beim Darüberfahren nicht verlängern",
    ["Improved value"] = "Wert nach dem Stufenaufstieg",
    ["Include profession trainers"] = "Berufslehrer einbeziehen",
    ["Language"] = "Sprache",
    ["Left"] = "Links",
    ["Left edge"] = "Linker Rand",
    ["Level %d"] = "Stufe %d",
    ["Level Up (default)"] = "Stufenaufstieg (Standard)",
    ["Level number"] = "Stufenzahl",
    ["Lock Location"] = "Position sperren",
    ["Low"] = "Niedrig",
    ["Master"] = "Gesamtlautstärke",
    ["Medium"] = "Mittel",
    ["Mode"] = "Modus",
    ["Modern"] = "Modern",
    ["Move"] = "Bewegen",
    ["Music"] = "Musik",
    ["Mute Blizzard level-up sound"] = "Blizzards Stufenaufstiegssound stummschalten",
    ["Never"] = "Nie",
    ["New trainer entries saved: %d (%s)."] = "Neue Einträge gespeichert: %d (Lehrer: %s).",
    ["No new skills this level"] = "Keine neuen Fähigkeiten auf dieser Stufe",
    ["No portrait ring"] = "Kein Porträtrahmen",
    ["No registered custom sounds"] = "Keine eigenen Sounds verfügbar",
    ["No stat changes"] = "Keine Attributänderungen",
    ["No trainer data for this class.\nVisit your class trainer."] = "Keine Lehrerdaten für diese Klasse.\nBesucht euren Klassenlehrer.",
    ["No unlearned skills available"] = "Keine erlernbaren Fähigkeiten",
    ["None"] = "Keine",
    ["Off"] = "Aus",
    ["On"] = "An",
    ["Only display new skills"] = "Nur neue Fähigkeiten, keine höheren Ränge",
    ["Only skills unlocked at this level"] = "Nur auf dieser Stufe freigeschaltete Fähigkeiten",
    ["Open Controller Options"] = "Gamepad-Optionen öffnen",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "Optional. Ersetzt den obigen Sound. Beispiel: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "Sound abspielen",
    ["Play sound on level up"] = "Sound beim Stufenaufstieg abspielen",
    ["Player portrait"] = "Spielerporträt",
    ["Popup scale"] = "Skalierung der Stufenaufstiegsanzeige",
    ["Portrait"] = "Porträt",
    ["Portrait border"] = "Porträtrand",
    ["Portrait ring"] = "Porträtrahmen",
    ["Portrait ring hue"] = "Farbton des Porträtrahmens",
    ["Portrait ring offset X"] = "Porträtrahmen: X-Versatz",
    ["Portrait ring offset Y"] = "Porträtrahmen: Y-Versatz",
    ["Portrait ring scale"] = "Skalierung des Porträtrahmens",
    ["Preview Level-Up"] = "Stufenaufstieg testen",
    ["Print performance report"] = "Leistungsbericht anzeigen",
    ["Quest Complete"] = "Quest abgeschlossen",
    ["Ready Check"] = "Bereitschaftscheck",
    ["Reduced motion"] = "Animationen reduzieren",
    ["Refresh Cache Status"] = "Cachestatus aktualisieren",
    ["Registered custom sound"] = "Verfügbarer eigener Sound",
    ["Reload UI"] = "Oberfläche neu laden",
    ["Reset Appearance"] = "Aussehen zurücksetzen",
    ["Reset all options"] = "Alle Optionen zurücksetzen",
    ["Reset performance data"] = "Messdaten zurücksetzen",
    ["Reset to Defaults"] = "Standardwerte",
    ["Right"] = "Rechts",
    ["Right edge"] = "Rechter Rand",
    ["Right-click to close"] = "Rechtsklick zum Schließen",
    ["Right-click to toggle the addon"] = "Rechtsklick zum Ein-/Ausschalten",
    ["Section divider"] = "Abschnittstrenner",
    ["Section padding"] = "Abschnittsabstand",
    ["Select"] = "Auswählen",
    ["Show Hunter pet abilities"] = "Fähigkeiten von Jägerbegleitern anzeigen",
    ["Show Warlock pet abilities"] = "Fähigkeiten von Hexenmeisterbegleitern anzeigen",
    ["Show all available grimoires"] = "Alle verfügbaren Grimoires anzeigen",
    ["Show learning costs"] = "Lernkosten anzeigen",
    ["Show minimap button"] = "Minikartenbutton anzeigen",
    ["Show text shadows"] = "Textschatten anzeigen",
    ["Show time played this level"] = "Zeit bis zum Stufenaufstieg anzeigen",
    ["Show unlearned weapon skills"] = "Nicht erlernte Waffenfertigkeiten anzeigen",
    ["Skipped %d future skills without a readable required level."] = "%d Fähigkeiten höherer Stufen übersprungen: benötigte Stufe nicht lesbar.",
    ["Slide direction"] = "Animationsrichtung",
    ["Some options are not available in the controller menu."] = "Einige Optionen sind im Gamepad-Menü nicht verfügbar.",
    ["Sound"] = "Sound",
    ["Sound Effects"] = "Soundeffekte",
    ["Sound channel"] = "Soundkanal",
    ["Sound volume"] = "Lautstärke",
    ["Stat name / old value"] = "Attribut / alter Wert",
    ["Stats Gained"] = "Attributsteigerungen",
    ["Stats header"] = "Attributüberschrift",
    ["Steel ring"] = "Stahlrahmen",
    ["Stretch"] = "Strecken",
    ["Suspend Preview"] = "Vorschau eingeblendet lassen",
    ["Tabs"] = "Reiter",
    ["Text"] = "Text",
    ["Textures"] = "Texturen",
    ["The level-up screen failed to display (see above). Please report this error."] = "Die Stufenaufstiegsanzeige konnte nicht angezeigt werden (siehe oben). Bitte meldet diesen Fehler.",
    ["Theme"] = "Design",
    ["Tile"] = "Kacheln",
    ["Time to level: %dh %02dm"] = "Zeit bis zum Stufenaufstieg: %d Std. %02d Min.",
    ["Time to level: %dm %02ds"] = "Zeit bis zum Stufenaufstieg: %d Min. %02d Sek.",
    ["Time to level: %ds"] = "Zeit bis zum Stufenaufstieg: %d Sek.",
    ["Title"] = "Titel",
    ["Tooltip (highest)"] = "Tooltip (oberste Ebene)",
    ["Top edge"] = "Oberer Rand",
    ["Top-left corner"] = "Obere linke Ecke",
    ["Top-right corner"] = "Obere rechte Ecke",
    ["Trainer Data"] = "Lehrerdaten",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "Die Lehrerdaten wurden aktualisiert. Besucht euren Klassenlehrer, um Fähigkeiten und Lernkosten erneut zu erfassen.",
    ["Use class colors"] = "Klassenfarben verwenden",
    ["Use horizontal scrolling"] = "Horizontalen Bildlauf verwenden",
    ["Version %s"] = "Version %s",
    ["Warlock Grimoires"] = "Hexenmeistergrimoires",
    ["Weapon skills: %s"] = "Waffenfertigkeiten: %s",
    ["Wood Panel"] = "Holzverkleidung",
    ["addon %s"] = "Addon %s",
    ["error:"] = "Fehler:",
    ["this trainer"] = "diesem Lehrer",
    ["unknown"] = "unbekannt",
} end)

RegisterLocaleBuilder("itIT", function() return {
    ["%s (recommended for gamepad)"] = "%s (consigliato per controller)",
    ["%s hue"] = "Tonalità: %s",
    ["%s rotation"] = "Rotazione: %s",
    ["A to clear"] = "A: cancella",
    ["A to play"] = "A: riproduci",
    ["A to preview"] = "A: anteprima",
    ["A to print"] = "A: mostra rapporto",
    ["A to reset"] = "A: reimposta",
    ["A trainer rescan is required."] = "Occorre registrare di nuovo i dati di un istruttore.",
    ["Abilities"] = "Abilità",
    ["Abilities header"] = "Intestazione delle abilità",
    ["Ability icon border"] = "Bordo delle icone delle abilità",
    ["Adjust"] = "Regola",
    ["Alarm Clock"] = "Sveglia",
    ["Alliance"] = "Alleanza",
    ["Alliance ring"] = "Cornice dell’Alleanza",
    ["Allow click-through"] = "Lascia passare i clic",
    ["Alternate"] = "Alterna",
    ["Ambience"] = "Ambiente",
    ["Animation"] = "Animazione",
    ["Animation speed"] = "Velocità animazione",
    ["Appearance"] = "Aspetto",
    ["Auction Window Open"] = "Apertura della casa d’aste",
    ["Auto (below preview)"] = "Automatico (sotto l’anteprima)",
    ["Auto Detect"] = "Rilevamento automatico",
    ["Automatically save trainer data"] = "Salva automaticamente i dati degli istruttori",
    ["Background"] = "Sfondo",
    ["Background hue"] = "Tonalità dello sfondo",
    ["Background opacity"] = "Opacità dello sfondo",
    ["Background texture"] = "Texture dello sfondo",
    ["Black Metal"] = "Metallo nero",
    ["Bloodlord Mandokir"] = "Signore del Sangue Mandokir",
    ["Bottom edge"] = "Bordo inferiore",
    ["Bottom-left corner"] = "Angolo inferiore sinistro",
    ["Bottom-right corner"] = "Angolo inferiore destro",
    ["by %s"] = "di %s",
    ["Cache Status"] = "Stato della cache",
    ["Cache status unavailable."] = "Stato della cache non disponibile.",
    ["Center"] = "Centro",
    ["Changes apply after reloading the UI."] = "Le modifiche si applicano ricaricando l’interfaccia.",
    ["Class icon"] = "Icona della classe",
    ["Clear trainer cache"] = "Svuota cache degli istruttori",
    ["Click to open options"] = "Clicca per aprire le opzioni",
    ["Close"] = "Chiudi",
    ["Colors"] = "Colori",
    ["Compact Layout"] = "Layout compatto",
    ["Controller glyphs"] = "Icone dei pulsanti del controller",
    ["Controller menu frame strata"] = "Livello di visualizzazione del menu controller",
    ["Copper ring"] = "Cornice di rame",
    ["Custom"] = "Personalizzato",
    ["Custom sound"] = "Suono personalizzato",
    ["Custom sound file"] = "File audio personalizzato",
    ["Debug"] = "Debug",
    ["Default font"] = "Carattere predefinito",
    ["Dialog"] = "Dialogo",
    ["Display duration"] = "Durata visualizzazione",
    ["Don't show until combat ends"] = "Mostra al termine del combattimento",
    ["Drag to move"] = "Trascina per spostare",
    ["Enable addon"] = "Attiva addon",
    ["Enable debug commands"] = "Attiva comandi di debug",
    ["Equal-width stat text"] = "Uniforma la larghezza del testo delle statistiche",
    ["Fill"] = "Riempi",
    ["Filter grimoires by active pet"] = "Filtra i grimori per famiglio evocato",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "Versione del gioco: %s\nClasse: %s\nAbilità in cache: %d\nUltimo istruttore: %s\nUltima registrazione: %s\nSchema: %d%s",
    ["Flip H"] = "Specchia orizzontalmente",
    ["Flip V"] = "Specchia verticalmente",
    ["Font"] = "Carattere",
    ["Frame"] = "Cornice",
    ["Frame hue"] = "Tonalità della cornice",
    ["Frame strata"] = "Livello di visualizzazione della cornice",
    ["Fullscreen"] = "Schermo intero",
    ["Fullscreen Dialog"] = "Dialogo a schermo intero",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - Opzioni controller",
    ["Gnomeregan"] = "Gnomeregan",
    ["Hide Blizzard level-up toast"] = "Nascondi avviso di livello di Blizzard",
    ["High"] = "Alto",
    ["Horde"] = "Orda",
    ["Horde ring"] = "Cornice dell’Orda",
    ["Ignore mouseover delay"] = "Non ritardare la chiusura al passaggio del mouse",
    ["Improved value"] = "Valore dopo l’avanzamento di livello",
    ["Include profession trainers"] = "Includi istruttori delle professioni",
    ["Language"] = "Lingua",
    ["Left"] = "Sinistra",
    ["Left edge"] = "Bordo sinistro",
    ["Level %d"] = "Livello %d",
    ["Level Up (default)"] = "Avanzamento di livello (predefinito)",
    ["Level number"] = "Numero del livello",
    ["Lock Location"] = "Blocca posizione",
    ["Low"] = "Basso",
    ["Master"] = "Volume generale",
    ["Medium"] = "Medio",
    ["Mode"] = "Modalità",
    ["Modern"] = "Moderno",
    ["Move"] = "Sposta",
    ["Music"] = "Musica",
    ["Mute Blizzard level-up sound"] = "Disattiva suono di livello di Blizzard",
    ["Never"] = "Mai",
    ["New trainer entries saved: %d (%s)."] = "Nuove voci salvate: %d (istruttore: %s).",
    ["No new skills this level"] = "Nessuna nuova abilità a questo livello",
    ["No portrait ring"] = "Nessuna cornice",
    ["No registered custom sounds"] = "Nessun suono personalizzato disponibile",
    ["No stat changes"] = "Nessuna modifica alle statistiche",
    ["No trainer data for this class.\nVisit your class trainer."] = "Nessun dato per questa classe.\nVisita il tuo istruttore di classe.",
    ["No unlearned skills available"] = "Nessuna abilità da apprendere",
    ["None"] = "Nessuno",
    ["Off"] = "Disattivato",
    ["On"] = "Attivato",
    ["Only display new skills"] = "Solo nuove abilità, senza gradi superiori",
    ["Only skills unlocked at this level"] = "Solo abilità sbloccate a questo livello",
    ["Open Controller Options"] = "Apri opzioni controller",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "Facoltativo. Sostituisce il suono precedente. Esempio: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "Riproduci suono",
    ["Play sound on level up"] = "Riproduci suono all’avanzamento di livello",
    ["Player portrait"] = "Ritratto del personaggio",
    ["Popup scale"] = "Scala dell’avviso di livello",
    ["Portrait"] = "Ritratto",
    ["Portrait border"] = "Bordo del ritratto",
    ["Portrait ring"] = "Cornice del ritratto",
    ["Portrait ring hue"] = "Tonalità della cornice del ritratto",
    ["Portrait ring offset X"] = "Spostamento X della cornice",
    ["Portrait ring offset Y"] = "Spostamento Y della cornice",
    ["Portrait ring scale"] = "Scala della cornice del ritratto",
    ["Preview Level-Up"] = "Anteprima dell’avviso",
    ["Print performance report"] = "Mostra rapporto prestazioni",
    ["Quest Complete"] = "Missione completata",
    ["Ready Check"] = "Appello",
    ["Reduced motion"] = "Riduci animazioni",
    ["Refresh Cache Status"] = "Aggiorna stato della cache",
    ["Registered custom sound"] = "Suono personalizzato disponibile",
    ["Reload UI"] = "Ricarica interfaccia",
    ["Reset Appearance"] = "Reimposta aspetto",
    ["Reset all options"] = "Reimposta tutte le opzioni",
    ["Reset performance data"] = "Azzera dati prestazioni",
    ["Reset to Defaults"] = "Valori predefiniti",
    ["Right"] = "Destra",
    ["Right edge"] = "Bordo destro",
    ["Right-click to close"] = "Clic destro per chiudere",
    ["Right-click to toggle the addon"] = "Clic destro per attivare o disattivare l’addon",
    ["Section divider"] = "Separatore delle sezioni",
    ["Section padding"] = "Spaziatura delle sezioni",
    ["Select"] = "Seleziona",
    ["Show Hunter pet abilities"] = "Mostra abilità dei famigli del Cacciatore",
    ["Show Warlock pet abilities"] = "Mostra abilità dei famigli dello Stregone",
    ["Show all available grimoires"] = "Mostra tutti i grimori disponibili",
    ["Show learning costs"] = "Mostra costi di apprendimento",
    ["Show minimap button"] = "Mostra pulsante della minimappa",
    ["Show text shadows"] = "Mostra ombre del testo",
    ["Show time played this level"] = "Mostra tempo per salire di livello",
    ["Show unlearned weapon skills"] = "Mostra competenze nelle armi non apprese",
    ["Skipped %d future skills without a readable required level."] = "Ignorate %d abilità di livelli superiori senza un livello richiesto leggibile.",
    ["Slide direction"] = "Direzione di scorrimento",
    ["Some options are not available in the controller menu."] = "Alcune opzioni non sono disponibili nel menu del controller.",
    ["Sound"] = "Audio",
    ["Sound Effects"] = "Effetti sonori",
    ["Sound channel"] = "Canale audio",
    ["Sound volume"] = "Volume audio",
    ["Stat name / old value"] = "Statistica / valore precedente",
    ["Stats Gained"] = "Incrementi delle statistiche",
    ["Stats header"] = "Intestazione delle statistiche",
    ["Steel ring"] = "Cornice d’acciaio",
    ["Stretch"] = "Estendi",
    ["Suspend Preview"] = "Mantieni visibile l’anteprima",
    ["Tabs"] = "Schede",
    ["Text"] = "Testo",
    ["Textures"] = "Texture",
    ["The level-up screen failed to display (see above). Please report this error."] = "Impossibile mostrare l’avviso di livello (vedi sopra). Segnala questo errore.",
    ["Theme"] = "Tema",
    ["Tile"] = "Ripeti",
    ["Time to level: %dh %02dm"] = "Tempo per salire di livello: %d h %02d min",
    ["Time to level: %dm %02ds"] = "Tempo per salire di livello: %d min %02d s",
    ["Time to level: %ds"] = "Tempo per salire di livello: %d s",
    ["Title"] = "Titolo",
    ["Tooltip (highest)"] = "Tooltip (livello più alto)",
    ["Top edge"] = "Bordo superiore",
    ["Top-left corner"] = "Angolo superiore sinistro",
    ["Top-right corner"] = "Angolo superiore destro",
    ["Trainer Data"] = "Dati degli istruttori",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "I dati degli istruttori sono stati aggiornati. Visita il tuo istruttore di classe per registrare abilità e costi.",
    ["Use class colors"] = "Usa colori di classe",
    ["Use horizontal scrolling"] = "Usa scorrimento orizzontale",
    ["Version %s"] = "Versione %s",
    ["Warlock Grimoires"] = "Grimori dello Stregone",
    ["Weapon skills: %s"] = "Competenze nelle armi: %s",
    ["Wood Panel"] = "Pannello di legno",
    ["addon %s"] = "Addon %s",
    ["error:"] = "Errore:",
    ["this trainer"] = "questo istruttore",
    ["unknown"] = "sconosciuto",
} end)

RegisterLocaleBuilder("ptBR", function() return {
    ["%s (recommended for gamepad)"] = "%s (recomendado para controle)",
    ["%s hue"] = "Tonalidade: %s",
    ["%s rotation"] = "Rotação: %s",
    ["A to clear"] = "A: limpar",
    ["A to play"] = "A: reproduzir",
    ["A to preview"] = "A: prévia",
    ["A to print"] = "A: mostrar relatório",
    ["A to reset"] = "A: redefinir",
    ["A trainer rescan is required."] = "É necessário registrar novamente os dados de um instrutor.",
    ["Abilities"] = "Habilidades",
    ["Abilities header"] = "Cabeçalho de habilidades",
    ["Ability icon border"] = "Borda dos ícones de habilidades",
    ["Adjust"] = "Ajustar",
    ["Alarm Clock"] = "Despertador",
    ["Alliance"] = "Aliança",
    ["Alliance ring"] = "Aro da Aliança",
    ["Allow click-through"] = "Permitir passagem de cliques",
    ["Alternate"] = "Alternar",
    ["Ambience"] = "Ambiente",
    ["Animation"] = "Animação",
    ["Animation speed"] = "Velocidade da animação",
    ["Appearance"] = "Aparência",
    ["Auction Window Open"] = "Abrir Casa de Leilões",
    ["Auto (below preview)"] = "Automático (abaixo da prévia)",
    ["Auto Detect"] = "Detecção automática",
    ["Automatically save trainer data"] = "Salvar dados de instrutores automaticamente",
    ["Background"] = "Fundo",
    ["Background hue"] = "Tonalidade do fundo",
    ["Background opacity"] = "Opacidade do fundo",
    ["Background texture"] = "Textura do fundo",
    ["Black Metal"] = "Metal preto",
    ["Bloodlord Mandokir"] = "Sangrelorde Mandokir",
    ["Bottom edge"] = "Borda inferior",
    ["Bottom-left corner"] = "Canto inferior esquerdo",
    ["Bottom-right corner"] = "Canto inferior direito",
    ["by %s"] = "por %s",
    ["Cache Status"] = "Estado do cache",
    ["Cache status unavailable."] = "Estado do cache indisponível.",
    ["Center"] = "Centro",
    ["Changes apply after reloading the UI."] = "As alterações entram em vigor ao recarregar a interface.",
    ["Class icon"] = "Ícone da classe",
    ["Clear trainer cache"] = "Limpar cache de instrutores",
    ["Click to open options"] = "Clique para abrir as opções",
    ["Close"] = "Fechar",
    ["Colors"] = "Cores",
    ["Compact Layout"] = "Layout compacto",
    ["Controller glyphs"] = "Ícones dos botões do controle",
    ["Controller menu frame strata"] = "Camada do menu do controle",
    ["Copper ring"] = "Aro de cobre",
    ["Custom"] = "Personalizado",
    ["Custom sound"] = "Som personalizado",
    ["Custom sound file"] = "Arquivo de som personalizado",
    ["Debug"] = "Depuração",
    ["Default font"] = "Fonte padrão",
    ["Dialog"] = "Diálogo",
    ["Display duration"] = "Duração da exibição",
    ["Don't show until combat ends"] = "Mostrar após o fim do combate",
    ["Drag to move"] = "Arraste para mover",
    ["Enable addon"] = "Ativar addon",
    ["Enable debug commands"] = "Ativar comandos de depuração",
    ["Equal-width stat text"] = "Igualar largura do texto de atributos",
    ["Fill"] = "Preencher",
    ["Filter grimoires by active pet"] = "Filtrar grimórios pelo ajudante invocado",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "Versão do jogo: %s\nClasse: %s\nHabilidades no cache: %d\nÚltimo instrutor: %s\nÚltimo registro: %s\nEsquema: %d%s",
    ["Flip H"] = "Inverter horizontalmente",
    ["Flip V"] = "Inverter verticalmente",
    ["Font"] = "Fonte",
    ["Frame"] = "Moldura",
    ["Frame hue"] = "Tonalidade da moldura",
    ["Frame strata"] = "Camada de exibição da moldura",
    ["Fullscreen"] = "Tela cheia",
    ["Fullscreen Dialog"] = "Diálogo em tela cheia",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - Opções do controle",
    ["Gnomeregan"] = "Gnomeregan",
    ["Hide Blizzard level-up toast"] = "Ocultar aviso de nível da Blizzard",
    ["High"] = "Alta",
    ["Horde"] = "Horda",
    ["Horde ring"] = "Aro da Horda",
    ["Ignore mouseover delay"] = "Não adiar fechamento ao passar o mouse",
    ["Improved value"] = "Valor após subir de nível",
    ["Include profession trainers"] = "Incluir instrutores de profissão",
    ["Language"] = "Idioma",
    ["Left"] = "Esquerda",
    ["Left edge"] = "Borda esquerda",
    ["Level %d"] = "Nível %d",
    ["Level Up (default)"] = "Subida de nível (padrão)",
    ["Level number"] = "Número do nível",
    ["Lock Location"] = "Travar posição",
    ["Low"] = "Baixa",
    ["Master"] = "Volume geral",
    ["Medium"] = "Média",
    ["Mode"] = "Modo",
    ["Modern"] = "Moderno",
    ["Move"] = "Mover",
    ["Music"] = "Música",
    ["Mute Blizzard level-up sound"] = "Silenciar som de nível da Blizzard",
    ["Never"] = "Nunca",
    ["New trainer entries saved: %d (%s)."] = "Novos registros salvos: %d (instrutor: %s).",
    ["No new skills this level"] = "Nenhuma habilidade nova neste nível",
    ["No portrait ring"] = "Sem aro no retrato",
    ["No registered custom sounds"] = "Nenhum som personalizado disponível",
    ["No stat changes"] = "Nenhuma alteração de atributos",
    ["No trainer data for this class.\nVisit your class trainer."] = "Sem dados para esta classe.\nVisite seu instrutor de classe.",
    ["No unlearned skills available"] = "Nenhuma habilidade por aprender",
    ["None"] = "Nenhum",
    ["Off"] = "Desativado",
    ["On"] = "Ativado",
    ["Only display new skills"] = "Só habilidades novas, sem graus superiores",
    ["Only skills unlocked at this level"] = "Só habilidades desbloqueadas neste nível",
    ["Open Controller Options"] = "Abrir opções do controle",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "Opcional. Substitui o som acima. Exemplo: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "Reproduzir som",
    ["Play sound on level up"] = "Reproduzir som ao subir de nível",
    ["Player portrait"] = "Retrato do jogador",
    ["Popup scale"] = "Escala do aviso de nível",
    ["Portrait"] = "Retrato",
    ["Portrait border"] = "Borda do retrato",
    ["Portrait ring"] = "Aro do retrato",
    ["Portrait ring hue"] = "Tonalidade do aro do retrato",
    ["Portrait ring offset X"] = "Deslocamento X do aro",
    ["Portrait ring offset Y"] = "Deslocamento Y do aro",
    ["Portrait ring scale"] = "Escala do aro do retrato",
    ["Preview Level-Up"] = "Prévia do aviso de nível",
    ["Print performance report"] = "Mostrar relatório de desempenho",
    ["Quest Complete"] = "Missão concluída",
    ["Ready Check"] = "Verificação de prontidão",
    ["Reduced motion"] = "Reduzir animações",
    ["Refresh Cache Status"] = "Atualizar estado do cache",
    ["Registered custom sound"] = "Som personalizado disponível",
    ["Reload UI"] = "Recarregar interface",
    ["Reset Appearance"] = "Redefinir aparência",
    ["Reset all options"] = "Redefinir todas as opções",
    ["Reset performance data"] = "Limpar dados de desempenho",
    ["Reset to Defaults"] = "Restaurar padrões",
    ["Right"] = "Direita",
    ["Right edge"] = "Borda direita",
    ["Right-click to close"] = "Botão direito para fechar",
    ["Right-click to toggle the addon"] = "Botão direito para ativar ou desativar",
    ["Section divider"] = "Divisor de seções",
    ["Section padding"] = "Espaçamento entre seções",
    ["Select"] = "Selecionar",
    ["Show Hunter pet abilities"] = "Mostrar habilidades de ajudantes de Caçador",
    ["Show Warlock pet abilities"] = "Mostrar habilidades de ajudantes de Bruxo",
    ["Show all available grimoires"] = "Mostrar todos os grimórios disponíveis",
    ["Show learning costs"] = "Mostrar custos de aprendizado",
    ["Show minimap button"] = "Mostrar botão do minimapa",
    ["Show text shadows"] = "Mostrar sombras do texto",
    ["Show time played this level"] = "Mostrar tempo para subir de nível",
    ["Show unlearned weapon skills"] = "Mostrar perícias com armas não aprendidas",
    ["Skipped %d future skills without a readable required level."] = "%d habilidades de níveis superiores ignoradas: nível necessário ilegível.",
    ["Slide direction"] = "Direção do deslizamento",
    ["Some options are not available in the controller menu."] = "Algumas opções não estão disponíveis no menu do controle.",
    ["Sound"] = "Som",
    ["Sound Effects"] = "Efeitos sonoros",
    ["Sound channel"] = "Canal de áudio",
    ["Sound volume"] = "Volume do som",
    ["Stat name / old value"] = "Atributo / valor anterior",
    ["Stats Gained"] = "Aumentos de atributos",
    ["Stats header"] = "Cabeçalho de atributos",
    ["Steel ring"] = "Aro de aço",
    ["Stretch"] = "Esticar",
    ["Suspend Preview"] = "Manter prévia na tela",
    ["Tabs"] = "Abas",
    ["Text"] = "Texto",
    ["Textures"] = "Texturas",
    ["The level-up screen failed to display (see above). Please report this error."] = "Não foi possível exibir o aviso de nível (veja acima). Informe este erro.",
    ["Theme"] = "Tema",
    ["Tile"] = "Repetir",
    ["Time to level: %dh %02dm"] = "Tempo para subir de nível: %d h %02d min",
    ["Time to level: %dm %02ds"] = "Tempo para subir de nível: %d min %02d s",
    ["Time to level: %ds"] = "Tempo para subir de nível: %d s",
    ["Title"] = "Título",
    ["Tooltip (highest)"] = "Dica (camada superior)",
    ["Top edge"] = "Borda superior",
    ["Top-left corner"] = "Canto superior esquerdo",
    ["Top-right corner"] = "Canto superior direito",
    ["Trainer Data"] = "Dados de instrutores",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "Os dados de instrutores foram atualizados. Visite seu instrutor de classe para registrar habilidades e custos.",
    ["Use class colors"] = "Usar cores de classe",
    ["Use horizontal scrolling"] = "Usar rolagem horizontal",
    ["Version %s"] = "Versão %s",
    ["Warlock Grimoires"] = "Grimórios de Bruxo",
    ["Weapon skills: %s"] = "Perícias com armas: %s",
    ["Wood Panel"] = "Painel de madeira",
    ["addon %s"] = "Addon %s",
    ["error:"] = "Erro:",
    ["this trainer"] = "este instrutor",
    ["unknown"] = "desconhecido",
} end)

RegisterLocaleBuilder("ruRU", function() return {
    ["%s (recommended for gamepad)"] = "%s (рекомендуется для геймпада)",
    ["%s hue"] = "Оттенок: %s",
    ["%s rotation"] = "Поворот: %s",
    ["A to clear"] = "A: очистить",
    ["A to play"] = "A: воспроизвести",
    ["A to preview"] = "A: предпросмотр",
    ["A to print"] = "A: показать отчёт",
    ["A to reset"] = "A: сбросить",
    ["A trainer rescan is required."] = "Нужно повторно записать данные у учителя.",
    ["Abilities"] = "Способности",
    ["Abilities header"] = "Заголовок способностей",
    ["Ability icon border"] = "Рамка значков способностей",
    ["Adjust"] = "Настроить",
    ["Alarm Clock"] = "Будильник",
    ["Alliance"] = "Альянс",
    ["Alliance ring"] = "Обрамление Альянса",
    ["Allow click-through"] = "Пропускать щелчки мыши",
    ["Alternate"] = "Чередовать",
    ["Ambience"] = "Окружающий мир",
    ["Animation"] = "Анимация",
    ["Animation speed"] = "Скорость анимации",
    ["Appearance"] = "Внешний вид",
    ["Auction Window Open"] = "Открытие аукциона",
    ["Auto (below preview)"] = "Авто (под предпросмотром)",
    ["Auto Detect"] = "Автоопределение",
    ["Automatically save trainer data"] = "Автоматически сохранять данные учителей",
    ["Background"] = "Фон",
    ["Background hue"] = "Оттенок фона",
    ["Background opacity"] = "Непрозрачность фона",
    ["Background texture"] = "Текстура фона",
    ["Black Metal"] = "Чёрный металл",
    ["Bloodlord Mandokir"] = "Мандокир Повелитель Крови",
    ["Bottom edge"] = "Нижний край",
    ["Bottom-left corner"] = "Левый нижний угол",
    ["Bottom-right corner"] = "Правый нижний угол",
    ["by %s"] = "автор: %s",
    ["Cache Status"] = "Состояние кэша",
    ["Cache status unavailable."] = "Состояние кэша недоступно.",
    ["Center"] = "Центр",
    ["Changes apply after reloading the UI."] = "Изменения вступят в силу после перезагрузки интерфейса.",
    ["Class icon"] = "Значок класса",
    ["Clear trainer cache"] = "Очистить кэш учителей",
    ["Click to open options"] = "Щёлкните, чтобы открыть настройки",
    ["Close"] = "Закрыть",
    ["Colors"] = "Цвета",
    ["Compact Layout"] = "Компактный вид",
    ["Controller glyphs"] = "Значки кнопок геймпада",
    ["Controller menu frame strata"] = "Слой меню геймпада",
    ["Copper ring"] = "Медное обрамление",
    ["Custom"] = "Свой вариант",
    ["Custom sound"] = "Свой звук",
    ["Custom sound file"] = "Свой звуковой файл",
    ["Debug"] = "Отладка",
    ["Default font"] = "Шрифт по умолчанию",
    ["Dialog"] = "Диалоги",
    ["Display duration"] = "Длительность показа",
    ["Don't show until combat ends"] = "Показывать после выхода из боя",
    ["Drag to move"] = "Перетащите для перемещения",
    ["Enable addon"] = "Включить аддон",
    ["Enable debug commands"] = "Включить команды отладки",
    ["Equal-width stat text"] = "Одинаковая ширина текста характеристик",
    ["Fill"] = "Заполнить",
    ["Filter grimoires by active pet"] = "Гримуары для призванного питомца",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "Версия игры: %s\nКласс: %s\nСпособностей в кэше: %d\nПоследний учитель: %s\nПоследняя запись: %s\nСхема: %d%s",
    ["Flip H"] = "Отразить по горизонтали",
    ["Flip V"] = "Отразить по вертикали",
    ["Font"] = "Шрифт",
    ["Frame"] = "Рамка",
    ["Frame hue"] = "Оттенок рамки",
    ["Frame strata"] = "Слой отображения рамки",
    ["Fullscreen"] = "Полноэкранный",
    ["Fullscreen Dialog"] = "Полноэкранный диалог",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - Настройки геймпада",
    ["Gnomeregan"] = "Гномреган",
    ["Hide Blizzard level-up toast"] = "Скрыть уведомление Blizzard о новом уровне",
    ["High"] = "Высокий",
    ["Horde"] = "Орда",
    ["Horde ring"] = "Обрамление Орды",
    ["Ignore mouseover delay"] = "Не продлевать показ при наведении",
    ["Improved value"] = "Значение после повышения уровня",
    ["Include profession trainers"] = "Учитывать учителей профессий",
    ["Language"] = "Язык",
    ["Left"] = "Влево",
    ["Left edge"] = "Левый край",
    ["Level %d"] = "Уровень %d",
    ["Level Up (default)"] = "Новый уровень (по умолчанию)",
    ["Level number"] = "Номер уровня",
    ["Lock Location"] = "Закрепить положение",
    ["Low"] = "Низкий",
    ["Master"] = "Общая громкость",
    ["Medium"] = "Средний",
    ["Mode"] = "Режим",
    ["Modern"] = "Современный",
    ["Move"] = "Переместить",
    ["Music"] = "Музыка",
    ["Mute Blizzard level-up sound"] = "Отключить звук нового уровня Blizzard",
    ["Never"] = "Никогда",
    ["New trainer entries saved: %d (%s)."] = "Новых записей сохранено: %d (учитель: %s).",
    ["No new skills this level"] = "На этом уровне нет новых способностей",
    ["No portrait ring"] = "Без обрамления",
    ["No registered custom sounds"] = "Нет доступных своих звуков",
    ["No stat changes"] = "Характеристики не изменились",
    ["No trainer data for this class.\nVisit your class trainer."] = "Нет данных для этого класса.\nПосетите учителя своего класса.",
    ["No unlearned skills available"] = "Нет неизученных способностей",
    ["None"] = "Нет",
    ["Off"] = "Выкл.",
    ["On"] = "Вкл.",
    ["Only display new skills"] = "Только новые способности, без повышенных рангов",
    ["Only skills unlocked at this level"] = "Только способности, открытые на этом уровне",
    ["Open Controller Options"] = "Открыть настройки геймпада",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "Необязательно. Заменяет выбранный выше звук. Пример: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "Воспроизвести звук",
    ["Play sound on level up"] = "Звук при повышении уровня",
    ["Player portrait"] = "Портрет персонажа",
    ["Popup scale"] = "Масштаб уведомления",
    ["Portrait"] = "Портрет",
    ["Portrait border"] = "Граница портрета",
    ["Portrait ring"] = "Обрамление портрета",
    ["Portrait ring hue"] = "Оттенок обрамления",
    ["Portrait ring offset X"] = "Смещение обрамления по X",
    ["Portrait ring offset Y"] = "Смещение обрамления по Y",
    ["Portrait ring scale"] = "Масштаб обрамления",
    ["Preview Level-Up"] = "Предпросмотр уведомления",
    ["Print performance report"] = "Показать отчёт о производительности",
    ["Quest Complete"] = "Задание выполнено",
    ["Ready Check"] = "Проверка готовности",
    ["Reduced motion"] = "Уменьшить анимацию",
    ["Refresh Cache Status"] = "Обновить состояние кэша",
    ["Registered custom sound"] = "Доступный свой звук",
    ["Reload UI"] = "Перезагрузить интерфейс",
    ["Reset Appearance"] = "Сбросить внешний вид",
    ["Reset all options"] = "Сбросить все настройки",
    ["Reset performance data"] = "Сбросить замеры",
    ["Reset to Defaults"] = "По умолчанию",
    ["Right"] = "Вправо",
    ["Right edge"] = "Правый край",
    ["Right-click to close"] = "Правая кнопка мыши — закрыть",
    ["Right-click to toggle the addon"] = "Правая кнопка мыши — вкл./выкл.",
    ["Section divider"] = "Разделитель секций",
    ["Section padding"] = "Расстояние между секциями",
    ["Select"] = "Выбрать",
    ["Show Hunter pet abilities"] = "Способности питомцев охотника",
    ["Show Warlock pet abilities"] = "Способности питомцев чернокнижника",
    ["Show all available grimoires"] = "Все доступные гримуары",
    ["Show learning costs"] = "Стоимость обучения",
    ["Show minimap button"] = "Кнопка у мини-карты",
    ["Show text shadows"] = "Тени текста",
    ["Show time played this level"] = "Время до повышения уровня",
    ["Show unlearned weapon skills"] = "Неизученные навыки владения оружием",
    ["Skipped %d future skills without a readable required level."] = "Пропущено способностей более высоких уровней: %d. Требуемый уровень не удалось прочитать.",
    ["Slide direction"] = "Направление анимации",
    ["Some options are not available in the controller menu."] = "Некоторые настройки недоступны в меню геймпада.",
    ["Sound"] = "Звук",
    ["Sound Effects"] = "Звуковые эффекты",
    ["Sound channel"] = "Звуковой канал",
    ["Sound volume"] = "Громкость звука",
    ["Stat name / old value"] = "Характеристика / старое значение",
    ["Stats Gained"] = "Прирост характеристик",
    ["Stats header"] = "Заголовок характеристик",
    ["Steel ring"] = "Стальное обрамление",
    ["Stretch"] = "Растянуть",
    ["Suspend Preview"] = "Оставлять предпросмотр на экране",
    ["Tabs"] = "Вкладки",
    ["Text"] = "Текст",
    ["Textures"] = "Текстуры",
    ["The level-up screen failed to display (see above). Please report this error."] = "Не удалось показать уведомление о новом уровне (см. выше). Сообщите об этой ошибке.",
    ["Theme"] = "Тема",
    ["Tile"] = "Замостить",
    ["Time to level: %dh %02dm"] = "Время до нового уровня: %d ч %02d мин",
    ["Time to level: %dm %02ds"] = "Время до нового уровня: %d мин %02d с",
    ["Time to level: %ds"] = "Время до нового уровня: %d с",
    ["Title"] = "Заголовок",
    ["Tooltip (highest)"] = "Подсказки (верхний слой)",
    ["Top edge"] = "Верхний край",
    ["Top-left corner"] = "Левый верхний угол",
    ["Top-right corner"] = "Правый верхний угол",
    ["Trainer Data"] = "Данные учителей",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "Данные учителей обновлены. Посетите учителя своего класса, чтобы заново записать способности и стоимость обучения.",
    ["Use class colors"] = "Использовать цвета классов",
    ["Use horizontal scrolling"] = "Горизонтальная прокрутка",
    ["Version %s"] = "Версия %s",
    ["Warlock Grimoires"] = "Гримуары чернокнижника",
    ["Weapon skills: %s"] = "Навыки владения оружием: %s",
    ["Wood Panel"] = "Деревянная панель",
    ["addon %s"] = "Аддон: %s",
    ["error:"] = "Ошибка:",
    ["this trainer"] = "этот учитель",
    ["unknown"] = "неизвестно",
} end)

RegisterLocaleBuilder("koKR", function() return {
    ["%s (recommended for gamepad)"] = "%s (게임패드 권장)",
    ["%s hue"] = "%s 색조",
    ["%s rotation"] = "%s 회전",
    ["A to clear"] = "A: 삭제",
    ["A to play"] = "A: 재생",
    ["A to preview"] = "A: 미리 보기",
    ["A to print"] = "A: 보고서 표시",
    ["A to reset"] = "A: 초기화",
    ["A trainer rescan is required."] = "상급자에게서 데이터를 다시 수집해야 합니다.",
    ["Abilities"] = "기술",
    ["Abilities header"] = "기술 제목",
    ["Ability icon border"] = "기술 아이콘 테두리",
    ["Adjust"] = "조절",
    ["Alarm Clock"] = "알람",
    ["Alliance"] = "얼라이언스",
    ["Alliance ring"] = "얼라이언스 초상화 장식",
    ["Allow click-through"] = "마우스 클릭 통과",
    ["Alternate"] = "번갈아 표시",
    ["Ambience"] = "환경 소리",
    ["Animation"] = "애니메이션",
    ["Animation speed"] = "애니메이션 속도",
    ["Appearance"] = "외형",
    ["Auction Window Open"] = "경매장 열기",
    ["Auto (below preview)"] = "자동 (미리 보기 아래)",
    ["Auto Detect"] = "자동 감지",
    ["Automatically save trainer data"] = "상급자 데이터 자동 저장",
    ["Background"] = "배경",
    ["Background hue"] = "배경 색조",
    ["Background opacity"] = "배경 불투명도",
    ["Background texture"] = "배경 텍스처",
    ["Black Metal"] = "검은 금속",
    ["Bloodlord Mandokir"] = "혈군주 만도키르",
    ["Bottom edge"] = "아래쪽 가장자리",
    ["Bottom-left corner"] = "왼쪽 아래 모서리",
    ["Bottom-right corner"] = "오른쪽 아래 모서리",
    ["by %s"] = "제작: %s",
    ["Cache Status"] = "캐시 상태",
    ["Cache status unavailable."] = "캐시 상태를 확인할 수 없습니다.",
    ["Center"] = "중앙",
    ["Changes apply after reloading the UI."] = "인터페이스를 다시 불러오면 변경 사항이 적용됩니다.",
    ["Class icon"] = "직업 아이콘",
    ["Clear trainer cache"] = "상급자 캐시 삭제",
    ["Click to open options"] = "클릭하여 설정 열기",
    ["Close"] = "닫기",
    ["Colors"] = "색상",
    ["Compact Layout"] = "간결한 배치",
    ["Controller glyphs"] = "게임패드 버튼 아이콘",
    ["Controller menu frame strata"] = "게임패드 메뉴 표시 계층",
    ["Copper ring"] = "구리 초상화 장식",
    ["Custom"] = "사용자 지정",
    ["Custom sound"] = "사용자 지정 소리",
    ["Custom sound file"] = "사용자 지정 소리 파일",
    ["Debug"] = "디버그",
    ["Default font"] = "기본 글꼴",
    ["Dialog"] = "대화",
    ["Display duration"] = "표시 시간",
    ["Don't show until combat ends"] = "전투 종료 후 표시",
    ["Drag to move"] = "드래그하여 이동",
    ["Enable addon"] = "애드온 활성화",
    ["Enable debug commands"] = "디버그 명령 활성화",
    ["Equal-width stat text"] = "능력치 텍스트 너비 통일",
    ["Fill"] = "채우기",
    ["Filter grimoires by active pet"] = "현재 소환수의 흑마법서만 표시",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "게임 버전: %s\n직업: %s\n캐시된 기술: %d\n최근 상급자: %s\n최근 수집: %s\n스키마: %d%s",
    ["Flip H"] = "좌우 반전",
    ["Flip V"] = "상하 반전",
    ["Font"] = "글꼴",
    ["Frame"] = "테두리",
    ["Frame hue"] = "테두리 색조",
    ["Frame strata"] = "프레임 표시 계층",
    ["Fullscreen"] = "전체 화면",
    ["Fullscreen Dialog"] = "전체 화면 대화",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - 게임패드 설정",
    ["Gnomeregan"] = "놈리건",
    ["Hide Blizzard level-up toast"] = "블리자드 레벨 상승 알림 숨기기",
    ["High"] = "높음",
    ["Horde"] = "호드",
    ["Horde ring"] = "호드 초상화 장식",
    ["Ignore mouseover delay"] = "마우스를 올려도 표시 시간 유지",
    ["Improved value"] = "레벨 상승 후 수치",
    ["Include profession trainers"] = "전문 기술 전문가 포함",
    ["Language"] = "언어",
    ["Left"] = "왼쪽",
    ["Left edge"] = "왼쪽 가장자리",
    ["Level %d"] = "%d 레벨",
    ["Level Up (default)"] = "레벨 상승 (기본값)",
    ["Level number"] = "레벨 숫자",
    ["Lock Location"] = "위치 고정",
    ["Low"] = "낮음",
    ["Master"] = "주 음량",
    ["Medium"] = "중간",
    ["Mode"] = "모드",
    ["Modern"] = "현대식",
    ["Move"] = "이동",
    ["Music"] = "음악",
    ["Mute Blizzard level-up sound"] = "블리자드 레벨 상승 소리 끄기",
    ["Never"] = "기록 없음",
    ["New trainer entries saved: %d (%s)."] = "새 기록 저장: %d개 (상급자: %s).",
    ["No new skills this level"] = "이 레벨에 새 기술이 없습니다",
    ["No portrait ring"] = "초상화 장식 없음",
    ["No registered custom sounds"] = "사용 가능한 사용자 지정 소리 없음",
    ["No stat changes"] = "능력치 변화 없음",
    ["No trainer data for this class.\nVisit your class trainer."] = "이 직업의 데이터가 없습니다.\n직업 상급자를 찾아가세요.",
    ["No unlearned skills available"] = "배울 수 있는 새 기술 없음",
    ["None"] = "없음",
    ["Off"] = "끔",
    ["On"] = "켬",
    ["Only display new skills"] = "상위 등급을 제외한 새 기술만 표시",
    ["Only skills unlocked at this level"] = "현재 레벨에 해제된 기술만 표시",
    ["Open Controller Options"] = "게임패드 설정 열기",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "선택 사항입니다. 위의 소리 대신 재생합니다. 예: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "소리 재생",
    ["Play sound on level up"] = "레벨 상승 시 소리 재생",
    ["Player portrait"] = "플레이어 초상화",
    ["Popup scale"] = "레벨 상승 알림 크기",
    ["Portrait"] = "초상화",
    ["Portrait border"] = "초상화 테두리",
    ["Portrait ring"] = "초상화 장식",
    ["Portrait ring hue"] = "초상화 장식 색조",
    ["Portrait ring offset X"] = "초상화 장식 X 위치",
    ["Portrait ring offset Y"] = "초상화 장식 Y 위치",
    ["Portrait ring scale"] = "초상화 장식 크기",
    ["Preview Level-Up"] = "레벨 상승 미리 보기",
    ["Print performance report"] = "성능 보고서 표시",
    ["Quest Complete"] = "퀘스트 완료",
    ["Ready Check"] = "전투 준비 확인",
    ["Reduced motion"] = "애니메이션 줄이기",
    ["Refresh Cache Status"] = "캐시 상태 새로 고침",
    ["Registered custom sound"] = "사용 가능한 사용자 지정 소리",
    ["Reload UI"] = "인터페이스 다시 불러오기",
    ["Reset Appearance"] = "외형 초기화",
    ["Reset all options"] = "모든 설정 초기화",
    ["Reset performance data"] = "성능 측정값 초기화",
    ["Reset to Defaults"] = "기본값으로",
    ["Right"] = "오른쪽",
    ["Right edge"] = "오른쪽 가장자리",
    ["Right-click to close"] = "오른쪽 클릭으로 닫기",
    ["Right-click to toggle the addon"] = "오른쪽 클릭으로 애드온 켜기/끄기",
    ["Section divider"] = "구역 구분선",
    ["Section padding"] = "구역 간격",
    ["Select"] = "선택",
    ["Show Hunter pet abilities"] = "사냥꾼 야수 기술 표시",
    ["Show Warlock pet abilities"] = "흑마법사 소환수 기술 표시",
    ["Show all available grimoires"] = "사용 가능한 모든 흑마법서 표시",
    ["Show learning costs"] = "배우는 비용 표시",
    ["Show minimap button"] = "미니맵 버튼 표시",
    ["Show text shadows"] = "글자 그림자 표시",
    ["Show time played this level"] = "레벨 상승에 걸린 시간 표시",
    ["Show unlearned weapon skills"] = "배우지 않은 무기 숙련 표시",
    ["Skipped %d future skills without a readable required level."] = "필요 레벨을 확인할 수 없는 상위 레벨 기술 %d개를 건너뛰었습니다.",
    ["Slide direction"] = "등장 방향",
    ["Some options are not available in the controller menu."] = "일부 설정은 게임패드 메뉴에서 사용할 수 없습니다.",
    ["Sound"] = "소리",
    ["Sound Effects"] = "효과음",
    ["Sound channel"] = "소리 채널",
    ["Sound volume"] = "소리 크기",
    ["Stat name / old value"] = "능력치 이름 / 이전 수치",
    ["Stats Gained"] = "능력치 증가",
    ["Stats header"] = "능력치 제목",
    ["Steel ring"] = "강철 초상화 장식",
    ["Stretch"] = "늘이기",
    ["Suspend Preview"] = "미리 보기 계속 표시",
    ["Tabs"] = "탭",
    ["Text"] = "텍스트",
    ["Textures"] = "텍스처",
    ["The level-up screen failed to display (see above). Please report this error."] = "레벨 상승 알림을 표시하지 못했습니다 (위 내용 참조). 이 오류를 제보해 주세요.",
    ["Theme"] = "테마",
    ["Tile"] = "바둑판식 배열",
    ["Time to level: %dh %02dm"] = "레벨 상승 시간: %d시간 %02d분",
    ["Time to level: %dm %02ds"] = "레벨 상승 시간: %d분 %02d초",
    ["Time to level: %ds"] = "레벨 상승 시간: %d초",
    ["Title"] = "제목",
    ["Tooltip (highest)"] = "툴팁 (최상위)",
    ["Top edge"] = "위쪽 가장자리",
    ["Top-left corner"] = "왼쪽 위 모서리",
    ["Top-right corner"] = "오른쪽 위 모서리",
    ["Trainer Data"] = "상급자 데이터",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "상급자 데이터가 갱신되었습니다. 직업 상급자에게서 기술과 비용을 다시 수집하세요.",
    ["Use class colors"] = "직업 색상 사용",
    ["Use horizontal scrolling"] = "가로 스크롤 사용",
    ["Version %s"] = "버전 %s",
    ["Warlock Grimoires"] = "흑마법서",
    ["Weapon skills: %s"] = "무기 숙련: %s",
    ["Wood Panel"] = "나무 패널",
    ["addon %s"] = "애드온: %s",
    ["error:"] = "오류:",
    ["this trainer"] = "이 상급자",
    ["unknown"] = "알 수 없음",
} end)

RegisterLocaleBuilder("zhCN", function() return {
    ["%s (recommended for gamepad)"] = "%s（推荐用于手柄）",
    ["%s hue"] = "%s色调",
    ["%s rotation"] = "%s旋转",
    ["A to clear"] = "A：清除",
    ["A to play"] = "A：播放",
    ["A to preview"] = "A：预览",
    ["A to print"] = "A：显示报告",
    ["A to reset"] = "A：重置",
    ["A trainer rescan is required."] = "需要重新记录训练师的数据。",
    ["Abilities"] = "技能",
    ["Abilities header"] = "技能标题",
    ["Ability icon border"] = "技能图标边框",
    ["Adjust"] = "调整",
    ["Alarm Clock"] = "闹钟",
    ["Alliance"] = "联盟",
    ["Alliance ring"] = "联盟饰环",
    ["Allow click-through"] = "允许鼠标点击穿透",
    ["Alternate"] = "交替",
    ["Ambience"] = "环境音效",
    ["Animation"] = "动画",
    ["Animation speed"] = "动画速度",
    ["Appearance"] = "外观",
    ["Auction Window Open"] = "打开拍卖行",
    ["Auto (below preview)"] = "自动（预览下方）",
    ["Auto Detect"] = "自动检测",
    ["Automatically save trainer data"] = "自动保存训练师数据",
    ["Background"] = "背景",
    ["Background hue"] = "背景色调",
    ["Background opacity"] = "背景不透明度",
    ["Background texture"] = "背景材质",
    ["Black Metal"] = "黑色金属",
    ["Bloodlord Mandokir"] = "血领主曼多基尔",
    ["Bottom edge"] = "下边缘",
    ["Bottom-left corner"] = "左下角",
    ["Bottom-right corner"] = "右下角",
    ["by %s"] = "作者：%s",
    ["Cache Status"] = "缓存状态",
    ["Cache status unavailable."] = "无法获取缓存状态。",
    ["Center"] = "中央",
    ["Changes apply after reloading the UI."] = "重新加载界面后生效。",
    ["Class icon"] = "职业图标",
    ["Clear trainer cache"] = "清除训练师缓存",
    ["Click to open options"] = "点击打开设置",
    ["Close"] = "关闭",
    ["Colors"] = "颜色",
    ["Compact Layout"] = "紧凑布局",
    ["Controller glyphs"] = "手柄按钮图标",
    ["Controller menu frame strata"] = "手柄菜单显示层级",
    ["Copper ring"] = "铜质饰环",
    ["Custom"] = "自定义",
    ["Custom sound"] = "自定义音效",
    ["Custom sound file"] = "自定义音效文件",
    ["Debug"] = "调试",
    ["Default font"] = "默认字体",
    ["Dialog"] = "对话",
    ["Display duration"] = "显示时长",
    ["Don't show until combat ends"] = "战斗结束后显示",
    ["Drag to move"] = "拖动以移动",
    ["Enable addon"] = "启用插件",
    ["Enable debug commands"] = "启用调试命令",
    ["Equal-width stat text"] = "统一属性文本宽度",
    ["Fill"] = "填充",
    ["Filter grimoires by active pet"] = "仅显示当前召唤恶魔的魔典",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "游戏版本：%s\n职业：%s\n缓存技能：%d\n最近训练师：%s\n最近记录：%s\n数据结构：%d%s",
    ["Flip H"] = "水平翻转",
    ["Flip V"] = "垂直翻转",
    ["Font"] = "字体",
    ["Frame"] = "边框",
    ["Frame hue"] = "边框色调",
    ["Frame strata"] = "边框显示层级",
    ["Fullscreen"] = "全屏",
    ["Fullscreen Dialog"] = "全屏对话框",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - 手柄设置",
    ["Gnomeregan"] = "诺莫瑞根",
    ["Hide Blizzard level-up toast"] = "隐藏暴雪升级提示",
    ["High"] = "高",
    ["Horde"] = "部落",
    ["Horde ring"] = "部落饰环",
    ["Ignore mouseover delay"] = "鼠标悬停不延迟关闭",
    ["Improved value"] = "升级后的数值",
    ["Include profession trainers"] = "包含专业训练师",
    ["Language"] = "语言",
    ["Left"] = "左",
    ["Left edge"] = "左边缘",
    ["Level %d"] = "%d级",
    ["Level Up (default)"] = "升级（默认）",
    ["Level number"] = "等级数字",
    ["Lock Location"] = "锁定位置",
    ["Low"] = "低",
    ["Master"] = "主音量",
    ["Medium"] = "中",
    ["Mode"] = "模式",
    ["Modern"] = "现代",
    ["Move"] = "移动",
    ["Music"] = "音乐",
    ["Mute Blizzard level-up sound"] = "静音暴雪升级音效",
    ["Never"] = "从未",
    ["New trainer entries saved: %d (%s)."] = "已保存%d条新记录（训练师：%s）。",
    ["No new skills this level"] = "本级没有新技能",
    ["No portrait ring"] = "无头像饰环",
    ["No registered custom sounds"] = "没有可用的自定义音效",
    ["No stat changes"] = "属性没有变化",
    ["No trainer data for this class.\nVisit your class trainer."] = "没有此职业的数据。\n请拜访你的职业训练师。",
    ["No unlearned skills available"] = "没有尚未学习的技能",
    ["None"] = "无",
    ["Off"] = "关闭",
    ["On"] = "开启",
    ["Only display new skills"] = "仅显示新技能，不显示已学技能的升级",
    ["Only skills unlocked at this level"] = "仅显示本级解锁的技能",
    ["Open Controller Options"] = "打开手柄设置",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "可选。替换上方音效。示例：Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "播放音效",
    ["Play sound on level up"] = "升级时播放音效",
    ["Player portrait"] = "玩家头像",
    ["Popup scale"] = "升级提示缩放",
    ["Portrait"] = "头像",
    ["Portrait border"] = "头像边框",
    ["Portrait ring"] = "头像饰环",
    ["Portrait ring hue"] = "头像饰环色调",
    ["Portrait ring offset X"] = "头像饰环X偏移",
    ["Portrait ring offset Y"] = "头像饰环Y偏移",
    ["Portrait ring scale"] = "头像饰环缩放",
    ["Preview Level-Up"] = "预览升级提示",
    ["Print performance report"] = "显示性能报告",
    ["Quest Complete"] = "任务完成",
    ["Ready Check"] = "就位确认",
    ["Reduced motion"] = "减少动画",
    ["Refresh Cache Status"] = "刷新缓存状态",
    ["Registered custom sound"] = "已注册的自定义音效",
    ["Reload UI"] = "重载界面",
    ["Reset Appearance"] = "重置外观",
    ["Reset all options"] = "重置所有设置",
    ["Reset performance data"] = "清除性能数据",
    ["Reset to Defaults"] = "恢复默认",
    ["Right"] = "右",
    ["Right edge"] = "右边缘",
    ["Right-click to close"] = "右键点击关闭",
    ["Right-click to toggle the addon"] = "右键点击启用或禁用插件",
    ["Section divider"] = "分区分隔线",
    ["Section padding"] = "分区间距",
    ["Select"] = "选择",
    ["Show Hunter pet abilities"] = "显示猎人宠物技能",
    ["Show Warlock pet abilities"] = "显示术士恶魔技能",
    ["Show all available grimoires"] = "显示所有可用魔典",
    ["Show learning costs"] = "显示学习费用",
    ["Show minimap button"] = "显示小地图按钮",
    ["Show text shadows"] = "显示文字阴影",
    ["Show time played this level"] = "显示升级用时",
    ["Show unlearned weapon skills"] = "显示尚未学习的武器技能",
    ["Skipped %d future skills without a readable required level."] = "已跳过%d项无法读取需求等级的高等级技能。",
    ["Slide direction"] = "滑入方向",
    ["Some options are not available in the controller menu."] = "部分选项无法在手柄菜单中设置。",
    ["Sound"] = "音效",
    ["Sound Effects"] = "音效",
    ["Sound channel"] = "声音通道",
    ["Sound volume"] = "音量",
    ["Stat name / old value"] = "属性名称／原数值",
    ["Stats Gained"] = "属性提升",
    ["Stats header"] = "属性标题",
    ["Steel ring"] = "钢质饰环",
    ["Stretch"] = "拉伸",
    ["Suspend Preview"] = "保持预览显示",
    ["Tabs"] = "标签页",
    ["Text"] = "文字",
    ["Textures"] = "材质",
    ["The level-up screen failed to display (see above). Please report this error."] = "无法显示升级提示（见上文）。请报告此错误。",
    ["Theme"] = "主题",
    ["Tile"] = "平铺",
    ["Time to level: %dh %02dm"] = "升级用时：%d小时%02d分钟",
    ["Time to level: %dm %02ds"] = "升级用时：%d分钟%02d秒",
    ["Time to level: %ds"] = "升级用时：%d秒",
    ["Title"] = "标题",
    ["Tooltip (highest)"] = "提示信息（最高层）",
    ["Top edge"] = "上边缘",
    ["Top-left corner"] = "左上角",
    ["Top-right corner"] = "右上角",
    ["Trainer Data"] = "训练师数据",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "训练师数据已更新。请拜访你的职业训练师，重新记录技能和学习费用。",
    ["Use class colors"] = "使用职业颜色",
    ["Use horizontal scrolling"] = "使用水平滚动",
    ["Version %s"] = "版本%s",
    ["Warlock Grimoires"] = "术士魔典",
    ["Weapon skills: %s"] = "武器技能：%s",
    ["Wood Panel"] = "木质面板",
    ["addon %s"] = "插件：%s",
    ["error:"] = "错误：",
    ["this trainer"] = "此训练师",
    ["unknown"] = "未知",
} end)

RegisterLocaleBuilder("zhTW", function() return {
    ["%s (recommended for gamepad)"] = "%s（建議使用控制器）",
    ["%s hue"] = "%s色調",
    ["%s rotation"] = "%s旋轉",
    ["A to clear"] = "A：清除",
    ["A to play"] = "A：播放",
    ["A to preview"] = "A：預覽",
    ["A to print"] = "A：顯示報告",
    ["A to reset"] = "A：重設",
    ["A trainer rescan is required."] = "需要重新記錄訓練師的資料。",
    ["Abilities"] = "技能",
    ["Abilities header"] = "技能標題",
    ["Ability icon border"] = "技能圖示外框",
    ["Adjust"] = "調整",
    ["Alarm Clock"] = "鬧鐘",
    ["Alliance"] = "聯盟",
    ["Alliance ring"] = "聯盟飾環",
    ["Allow click-through"] = "允許滑鼠點擊穿透",
    ["Alternate"] = "交替",
    ["Ambience"] = "環境音效",
    ["Animation"] = "動畫",
    ["Animation speed"] = "動畫速度",
    ["Appearance"] = "外觀",
    ["Auction Window Open"] = "開啟拍賣場",
    ["Auto (below preview)"] = "自動（預覽下方）",
    ["Auto Detect"] = "自動偵測",
    ["Automatically save trainer data"] = "自動儲存訓練師資料",
    ["Background"] = "背景",
    ["Background hue"] = "背景色調",
    ["Background opacity"] = "背景不透明度",
    ["Background texture"] = "背景材質",
    ["Black Metal"] = "黑色金屬",
    ["Bloodlord Mandokir"] = "血領主曼多基爾",
    ["Bottom edge"] = "下邊緣",
    ["Bottom-left corner"] = "左下角",
    ["Bottom-right corner"] = "右下角",
    ["by %s"] = "作者：%s",
    ["Cache Status"] = "快取狀態",
    ["Cache status unavailable."] = "無法取得快取狀態。",
    ["Center"] = "中央",
    ["Changes apply after reloading the UI."] = "重新載入介面後生效。",
    ["Class icon"] = "職業圖示",
    ["Clear trainer cache"] = "清除訓練師快取",
    ["Click to open options"] = "點擊開啟設定",
    ["Close"] = "關閉",
    ["Colors"] = "顏色",
    ["Compact Layout"] = "精簡配置",
    ["Controller glyphs"] = "控制器按鈕圖示",
    ["Controller menu frame strata"] = "控制器選單顯示層級",
    ["Copper ring"] = "銅製飾環",
    ["Custom"] = "自訂",
    ["Custom sound"] = "自訂音效",
    ["Custom sound file"] = "自訂音效檔案",
    ["Debug"] = "偵錯",
    ["Default font"] = "預設字型",
    ["Dialog"] = "對話",
    ["Display duration"] = "顯示時間",
    ["Don't show until combat ends"] = "戰鬥結束後顯示",
    ["Drag to move"] = "拖曳以移動",
    ["Enable addon"] = "啟用插件",
    ["Enable debug commands"] = "啟用偵錯指令",
    ["Equal-width stat text"] = "統一屬性文字寬度",
    ["Fill"] = "填滿",
    ["Filter grimoires by active pet"] = "僅顯示目前召喚惡魔的魔典",
    ["Flavor: %s\nClass: %s\nCached abilities: %d\nLast trainer: %s\nLast scan: %s\nSchema: %d%s"] = "遊戲版本：%s\n職業：%s\n快取技能：%d\n最近訓練師：%s\n最近記錄：%s\n資料結構：%d%s",
    ["Flip H"] = "水平翻轉",
    ["Flip V"] = "垂直翻轉",
    ["Font"] = "字型",
    ["Frame"] = "外框",
    ["Frame hue"] = "外框色調",
    ["Frame strata"] = "外框顯示層級",
    ["Fullscreen"] = "全螢幕",
    ["Fullscreen Dialog"] = "全螢幕對話框",
    ["GnomeLevelUp - Controller options"] = "GnomeLevelUp - 控制器設定",
    ["Gnomeregan"] = "諾姆瑞根",
    ["Hide Blizzard level-up toast"] = "隱藏暴雪升級提示",
    ["High"] = "高",
    ["Horde"] = "部落",
    ["Horde ring"] = "部落飾環",
    ["Ignore mouseover delay"] = "滑鼠停留不延後關閉",
    ["Improved value"] = "升級後的數值",
    ["Include profession trainers"] = "包含專業技能訓練師",
    ["Language"] = "語言",
    ["Left"] = "左",
    ["Left edge"] = "左邊緣",
    ["Level %d"] = "%d級",
    ["Level Up (default)"] = "升級（預設）",
    ["Level number"] = "等級數字",
    ["Lock Location"] = "鎖定位置",
    ["Low"] = "低",
    ["Master"] = "主音量",
    ["Medium"] = "中",
    ["Mode"] = "模式",
    ["Modern"] = "現代",
    ["Move"] = "移動",
    ["Music"] = "音樂",
    ["Mute Blizzard level-up sound"] = "靜音暴雪升級音效",
    ["Never"] = "從未",
    ["New trainer entries saved: %d (%s)."] = "已儲存%d筆新記錄（訓練師：%s）。",
    ["No new skills this level"] = "本級沒有新技能",
    ["No portrait ring"] = "無頭像飾環",
    ["No registered custom sounds"] = "沒有可用的自訂音效",
    ["No stat changes"] = "屬性沒有變化",
    ["No trainer data for this class.\nVisit your class trainer."] = "沒有此職業的資料。\n請拜訪你的職業訓練師。",
    ["No unlearned skills available"] = "沒有尚未學習的技能",
    ["None"] = "無",
    ["Off"] = "關閉",
    ["On"] = "開啟",
    ["Only display new skills"] = "僅顯示新技能，不含已學技能的升級",
    ["Only skills unlocked at this level"] = "僅顯示本級解鎖的技能",
    ["Open Controller Options"] = "開啟控制器設定",
    ["Optional. Overrides the sound above. Example: Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg"] = "選填。取代上方音效。範例：Interface\\AddOns\\GnomeLevelUp\\Sounds\\ding.ogg",
    ["Play sound"] = "播放音效",
    ["Play sound on level up"] = "升級時播放音效",
    ["Player portrait"] = "玩家頭像",
    ["Popup scale"] = "升級提示縮放",
    ["Portrait"] = "頭像",
    ["Portrait border"] = "頭像外框",
    ["Portrait ring"] = "頭像飾環",
    ["Portrait ring hue"] = "頭像飾環色調",
    ["Portrait ring offset X"] = "頭像飾環X偏移",
    ["Portrait ring offset Y"] = "頭像飾環Y偏移",
    ["Portrait ring scale"] = "頭像飾環縮放",
    ["Preview Level-Up"] = "預覽升級提示",
    ["Print performance report"] = "顯示效能報告",
    ["Quest Complete"] = "任務完成",
    ["Ready Check"] = "準備確認",
    ["Reduced motion"] = "減少動畫",
    ["Refresh Cache Status"] = "更新快取狀態",
    ["Registered custom sound"] = "已註冊的自訂音效",
    ["Reload UI"] = "重新載入介面",
    ["Reset Appearance"] = "重設外觀",
    ["Reset all options"] = "重設所有設定",
    ["Reset performance data"] = "清除效能資料",
    ["Reset to Defaults"] = "恢復預設",
    ["Right"] = "右",
    ["Right edge"] = "右邊緣",
    ["Right-click to close"] = "右鍵點擊關閉",
    ["Right-click to toggle the addon"] = "右鍵點擊啟用或停用插件",
    ["Section divider"] = "區段分隔線",
    ["Section padding"] = "區段間距",
    ["Select"] = "選擇",
    ["Show Hunter pet abilities"] = "顯示獵人寵物技能",
    ["Show Warlock pet abilities"] = "顯示術士惡魔技能",
    ["Show all available grimoires"] = "顯示所有可用魔典",
    ["Show learning costs"] = "顯示學習費用",
    ["Show minimap button"] = "顯示小地圖按鈕",
    ["Show text shadows"] = "顯示文字陰影",
    ["Show time played this level"] = "顯示升級用時",
    ["Show unlearned weapon skills"] = "顯示尚未學習的武器技能",
    ["Skipped %d future skills without a readable required level."] = "已略過%d項無法讀取需求等級的高等級技能。",
    ["Slide direction"] = "滑入方向",
    ["Some options are not available in the controller menu."] = "部分選項無法在控制器選單中設定。",
    ["Sound"] = "音效",
    ["Sound Effects"] = "音效",
    ["Sound channel"] = "聲音頻道",
    ["Sound volume"] = "音量",
    ["Stat name / old value"] = "屬性名稱／原數值",
    ["Stats Gained"] = "屬性提升",
    ["Stats header"] = "屬性標題",
    ["Steel ring"] = "鋼製飾環",
    ["Stretch"] = "延展",
    ["Suspend Preview"] = "保持預覽顯示",
    ["Tabs"] = "分頁",
    ["Text"] = "文字",
    ["Textures"] = "材質",
    ["The level-up screen failed to display (see above). Please report this error."] = "無法顯示升級提示（見上文）。請回報此錯誤。",
    ["Theme"] = "主題",
    ["Tile"] = "並排重複",
    ["Time to level: %dh %02dm"] = "升級用時：%d小時%02d分鐘",
    ["Time to level: %dm %02ds"] = "升級用時：%d分鐘%02d秒",
    ["Time to level: %ds"] = "升級用時：%d秒",
    ["Title"] = "標題",
    ["Tooltip (highest)"] = "浮動提示（最高層）",
    ["Top edge"] = "上邊緣",
    ["Top-left corner"] = "左上角",
    ["Top-right corner"] = "右上角",
    ["Trainer Data"] = "訓練師資料",
    ["Trainer data was updated. Visit your class trainer once to rescan skills and costs."] = "訓練師資料已更新。請拜訪你的職業訓練師，重新記錄技能與學習費用。",
    ["Use class colors"] = "使用職業顏色",
    ["Use horizontal scrolling"] = "使用水平捲動",
    ["Version %s"] = "版本%s",
    ["Warlock Grimoires"] = "術士魔典",
    ["Weapon skills: %s"] = "武器技能：%s",
    ["Wood Panel"] = "木製面板",
    ["addon %s"] = "插件：%s",
    ["error:"] = "錯誤：",
    ["this trainer"] = "此訓練師",
    ["unknown"] = "未知",
} end)

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("frFR", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Bienvenue dans GnomeLevelUp ! Depuis la version 1.4.0, vous n’avez plus besoin d’analyser les maîtres de classe manuellement : la liste est déjà remplie ! Merci de me signaler tout problème sur GitHub ou Curseforge !",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "¡Bienvenido a GnomeLevelUp! Desde la versión 1.4.0 ya no necesitas escanear los instructores manualmente: ¡la lista ya está incluida! ¡Comunícame cualquier problema que encuentres en GitHub o Curseforge!",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "¡Bienvenido a GnomeLevelUp! Desde la versión 1.4.0 ya no necesitas escanear a los instructores manualmente: ¡la lista ya está incluida! ¡Repórtame cualquier problema que encuentres en GitHub o Curseforge!",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Willkommen bei GnomeLevelUp! Seit Version 1.4.0 musst du Lehrer nicht mehr manuell scannen: Die Liste ist bereits enthalten! Bitte melde mir alle auftretenden Probleme auf GitHub oder Curseforge!",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Benvenuto in GnomeLevelUp! Dalla versione 1.4.0 non è più necessario scansionare manualmente gli istruttori: l’elenco è già incluso! Segnalami eventuali problemi su GitHub o Curseforge!",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Boas-vindas ao GnomeLevelUp! A partir da versão 1.4.0, você não precisa mais verificar os instrutores manualmente: a lista já está preenchida! Relate qualquer problema que encontrar para mim no GitHub ou Curseforge!",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Добро пожаловать в GnomeLevelUp! Начиная с версии 1.4.0 больше не нужно сканировать учителей вручную: список уже заполнен! Пожалуйста, сообщайте мне о любых проблемах на GitHub или Curseforge!",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "GnomeLevelUp에 오신 것을 환영합니다! 1.4.0부터는 기술 목록이 미리 포함되어 있으므로 상급자를 수동으로 스캔할 필요가 없습니다! 문제가 발생하면 GitHub 또는 Curseforge에서 제게 알려 주세요!",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "欢迎使用 GnomeLevelUp！从 1.4.0 版本起，技能列表已预先填充，无需再手动扫描训练师！如遇任何问题，请在 GitHub 或 Curseforge 上向我反馈！",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "歡迎使用 GnomeLevelUp！從 1.4.0 版本起，技能清單已預先填入，無須再手動掃描訓練師！如遇任何問題，請在 GitHub 或 Curseforge 上向我回報！",
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
RegisterLocaleBuilder("esES", function() return {
    ["Check trainer lists for catalogue changes"] = "Comprobar cambios en las listas de los instructores",
    ["Export trainer report"] = "Exportar informe de instructores",
    ["No trainer catalogue differences have been recorded."] = "No se han registrado diferencias con el catálogo de instructores.",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "Tras /reload o cerrar sesión, envía el archivo guardado al autor del addon en GitHub o Curseforge. Incluye tus ajustes de GnomeLevelUp. También puedes copiar el JSON de abajo, que contiene solo el informe.",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "¡Se ha detectado un cambio en los datos de los instructores! ¡Escribe /glu trainerreport y envíame el archivo!",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "Opciones del informe: escribe %s para abrir la ventana de exportación y copiar el JSON que contiene solo el informe.",
    ["Trainer reports cleared."] = "Informes de instructores borrados.",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "Archivo del informe tras /reload o cerrar sesión (dentro de la carpeta del cliente de WoW actual): %s",
    ["Report file: %s"] = "Archivo del informe: %s",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Check trainer lists for catalogue changes"] = "Comprobar cambios en las listas de los instructores",
    ["Export trainer report"] = "Exportar informe de instructores",
    ["No trainer catalogue differences have been recorded."] = "No se han registrado diferencias con el catálogo de instructores.",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "Después de /reload o cerrar sesión, envía el archivo guardado al autor del addon en GitHub o Curseforge. Incluye tus ajustes de GnomeLevelUp. También puedes copiar el JSON de abajo, que contiene solo el informe.",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "¡Se ha detectado un cambio en los datos de los instructores! ¡Escribe /glu trainerreport y envíame el archivo!",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "Opciones del informe: escribe %s para abrir la ventana de exportación y copiar el JSON que contiene solo el informe.",
    ["Trainer reports cleared."] = "Informes de instructores borrados.",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "Archivo del informe después de /reload o cerrar sesión (dentro de la carpeta del cliente de WoW actual): %s",
    ["Report file: %s"] = "Archivo del informe: %s",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Check trainer lists for catalogue changes"] = "Lehrerlisten auf Katalogänderungen prüfen",
    ["Export trainer report"] = "Lehrerbericht exportieren",
    ["No trainer catalogue differences have been recorded."] = "Es wurden keine Abweichungen vom Lehrerkatalog aufgezeichnet.",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "Sende die gespeicherte Datei nach /reload oder dem Ausloggen dem Addon-Autor auf GitHub oder Curseforge. Sie enthält deine GnomeLevelUp-Einstellungen. Alternativ kannst du unten nur den Bericht als JSON kopieren.",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "Eine Änderung der Lehrerdaten wurde erkannt. Bitte gib /glu trainerreport ein und sende mir die Datei!",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "Berichtsoptionen: Gib %s ein, um das Exportfenster zu öffnen und nur den Bericht als JSON zu kopieren.",
    ["Trainer reports cleared."] = "Lehrerberichte gelöscht.",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "Berichtsdatei nach /reload oder dem Ausloggen (im Ordner des aktuellen WoW-Clients): %s",
    ["Report file: %s"] = "Berichtsdatei: %s",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Check trainer lists for catalogue changes"] = "Controlla le modifiche agli elenchi degli istruttori",
    ["Export trainer report"] = "Esporta rapporto sugli istruttori",
    ["No trainer catalogue differences have been recorded."] = "Non sono state registrate differenze rispetto al catalogo degli istruttori.",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "Dopo /reload o la disconnessione, invia il file salvato all’autore dell’addon su GitHub o Curseforge. Include le impostazioni di GnomeLevelUp. In alternativa, copia il JSON qui sotto, che contiene solo il rapporto.",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "È stata rilevata una modifica ai dati degli istruttori. Digita /glu trainerreport e inviami il file!",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "Opzioni del rapporto: digita %s per aprire la finestra di esportazione e copiare il JSON contenente solo il rapporto.",
    ["Trainer reports cleared."] = "Rapporti sugli istruttori cancellati.",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "File del rapporto dopo /reload o la disconnessione (nella cartella del client WoW attuale): %s",
    ["Report file: %s"] = "File del rapporto: %s",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Check trainer lists for catalogue changes"] = "Verificar alterações nas listas dos instrutores",
    ["Export trainer report"] = "Exportar relatório de instrutores",
    ["No trainer catalogue differences have been recorded."] = "Nenhuma diferença no catálogo de instrutores foi registrada.",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "Após /reload ou sair do personagem, envie o arquivo salvo ao autor do addon no GitHub ou Curseforge. Ele inclui suas configurações do GnomeLevelUp. Como alternativa, copie abaixo o JSON que contém apenas o relatório.",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "Uma alteração nos dados dos instrutores foi detectada. Digite /glu trainerreport e envie o arquivo para mim!",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "Opções do relatório: digite %s para abrir a janela de exportação e copiar o JSON que contém apenas o relatório.",
    ["Trainer reports cleared."] = "Relatórios de instrutores apagados.",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "Arquivo do relatório após /reload ou sair do personagem (na pasta do cliente atual do WoW): %s",
    ["Report file: %s"] = "Arquivo do relatório: %s",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Check trainer lists for catalogue changes"] = "Проверять списки учителей на изменения каталога",
    ["Export trainer report"] = "Экспорт отчёта об учителях",
    ["No trainer catalogue differences have been recorded."] = "Различия с каталогом учителей не зарегистрированы.",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "После /reload или выхода из персонажа отправьте сохранённый файл автору аддона на GitHub или Curseforge. Он содержит настройки GnomeLevelUp. Вместо этого можно скопировать JSON ниже, содержащий только отчёт.",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "Обнаружено изменение данных учителей. Введите /glu trainerreport и отправьте мне файл!",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "Варианты отчёта: введите %s, чтобы открыть окно экспорта и скопировать JSON, содержащий только отчёт.",
    ["Trainer reports cleared."] = "Отчёты об учителях удалены.",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "Файл отчёта после /reload или выхода из персонажа (в папке текущего клиента WoW): %s",
    ["Report file: %s"] = "Файл отчёта: %s",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Check trainer lists for catalogue changes"] = "상급자 목록의 기술 목록 변경 확인",
    ["Export trainer report"] = "상급자 보고서 내보내기",
    ["No trainer catalogue differences have been recorded."] = "기술 목록과 다른 내용이 기록되지 않았습니다.",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "/reload 또는 캐릭터 접속 종료 후 저장된 파일을 GitHub 또는 Curseforge에서 애드온 제작자에게 보내 주세요. 이 파일에는 GnomeLevelUp 설정도 포함됩니다. 대신 아래에서 보고서만 포함된 JSON을 복사할 수도 있습니다.",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "상급자 데이터의 변경이 감지되었습니다. /glu trainerreport를 입력하고 파일을 제게 보내 주세요!",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "보고서 옵션: %s를 입력하면 내보내기 창을 열고 보고서만 포함된 JSON을 복사할 수 있습니다.",
    ["Trainer reports cleared."] = "상급자 보고서가 삭제되었습니다.",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "/reload 또는 캐릭터 접속 종료 후 저장되는 보고서 파일 (현재 WoW 클라이언트 폴더 기준): %s",
    ["Report file: %s"] = "보고서 파일: %s",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Check trainer lists for catalogue changes"] = "检查训练师列表中的技能目录变更",
    ["Export trainer report"] = "导出训练师报告",
    ["No trainer catalogue differences have been recorded."] = "尚未记录任何与训练师技能目录不同的内容。",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "执行 /reload 或退出角色后，请在 GitHub 或 Curseforge 上将保存的文件发送给插件作者。文件包含你的 GnomeLevelUp 设置。你也可以复制下方仅包含报告的 JSON。",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "检测到训练师数据发生变更，请输入 /glu trainerreport 并将文件发送给我！",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "报告选项：输入 %s 打开导出窗口，复制仅包含报告的 JSON。",
    ["Trainer reports cleared."] = "训练师报告已清除。",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "执行 /reload 或退出角色后保存的报告文件（位于当前 WoW 客户端文件夹内）：%s",
    ["Report file: %s"] = "报告文件：%s",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Check trainer lists for catalogue changes"] = "檢查訓練師清單中的技能目錄變更",
    ["Export trainer report"] = "匯出訓練師報告",
    ["No trainer catalogue differences have been recorded."] = "尚未記錄任何與訓練師技能目錄不同的內容。",
    ["After /reload or logout, send the saved file to the addon author on GitHub or Curseforge. It includes your GnomeLevelUp settings. Alternatively, copy the report-only JSON below."] = "執行 /reload 或登出角色後，請在 GitHub 或 Curseforge 上將儲存的檔案傳送給插件作者。檔案包含你的 GnomeLevelUp 設定。你也可以複製下方僅包含報告的 JSON。",
    ["A change in the trainer data has been detected, please type /glu trainerreport and submit the file to me!"] = "偵測到訓練師資料發生變更，請輸入 /glu trainerreport 並將檔案傳送給我！",
    ["Report options: type %s to open the export window and copy report-only JSON."] = "報告選項：輸入 %s 開啟匯出視窗，複製僅包含報告的 JSON。",
    ["Trainer reports cleared."] = "訓練師報告已清除。",
    ["Saved report file after /reload or logout (inside your current WoW client folder): %s"] = "執行 /reload 或登出角色後儲存的報告檔案（位於目前 WoW 用戶端資料夾內）：%s",
    ["Report file: %s"] = "報告檔案：%s",
} end)


-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("frFR", function() return {
    ["Portrait pulse and starburst"] = "Pulsation et éclat du portrait",
    ["Highlight new abilities"] = "Mettre en évidence les nouvelles techniques",
    ["Emphasize stat gains"] = "Mettre en valeur les gains de caractéristiques",
    ["New ability"] = "Nouvelle technique",
    ["Rank upgrade"] = "Amélioration de rang",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Portrait pulse and starburst"] = "Pulso y destello del retrato",
    ["Highlight new abilities"] = "Resaltar nuevas facultades",
    ["Emphasize stat gains"] = "Destacar aumentos de estadísticas",
    ["New ability"] = "Nueva facultad",
    ["Rank upgrade"] = "Mejora de rango",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Portrait pulse and starburst"] = "Pulso y destello del retrato",
    ["Highlight new abilities"] = "Resaltar nuevas facultades",
    ["Emphasize stat gains"] = "Destacar aumentos de estadísticas",
    ["New ability"] = "Nueva facultad",
    ["Rank upgrade"] = "Mejora de rango",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Portrait pulse and starburst"] = "Porträtpuls und Strahlenkranz",
    ["Highlight new abilities"] = "Neue Fähigkeiten hervorheben",
    ["Emphasize stat gains"] = "Attributsgewinne hervorheben",
    ["New ability"] = "Neue Fähigkeit",
    ["Rank upgrade"] = "Rangaufwertung",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Portrait pulse and starburst"] = "Impulso e bagliore del ritratto",
    ["Highlight new abilities"] = "Evidenzia nuove abilità",
    ["Emphasize stat gains"] = "Evidenzia aumenti delle statistiche",
    ["New ability"] = "Nuova abilità",
    ["Rank upgrade"] = "Aumento di grado",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Portrait pulse and starburst"] = "Pulso e clarão do retrato",
    ["Highlight new abilities"] = "Destacar novas habilidades",
    ["Emphasize stat gains"] = "Destacar ganhos de atributos",
    ["New ability"] = "Nova habilidade",
    ["Rank upgrade"] = "Melhoria de grau",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Portrait pulse and starburst"] = "Импульс и сияние портрета",
    ["Highlight new abilities"] = "Выделять новые способности",
    ["Emphasize stat gains"] = "Выделять прирост характеристик",
    ["New ability"] = "Новая способность",
    ["Rank upgrade"] = "Повышение ранга",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Portrait pulse and starburst"] = "초상화 파동 및 별빛 효과",
    ["Highlight new abilities"] = "새 능력 강조",
    ["Emphasize stat gains"] = "능력치 증가 강조",
    ["New ability"] = "새 능력",
    ["Rank upgrade"] = "등급 상승",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Portrait pulse and starburst"] = "头像脉冲和星芒",
    ["Highlight new abilities"] = "突出显示新技能",
    ["Emphasize stat gains"] = "突出显示属性提升",
    ["New ability"] = "新技能",
    ["Rank upgrade"] = "等级提升",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Portrait pulse and starburst"] = "頭像脈衝與星芒",
    ["Highlight new abilities"] = "醒目顯示新技能",
    ["Emphasize stat gains"] = "醒目顯示屬性提升",
    ["New ability"] = "新技能",
    ["Rank upgrade"] = "等級提升",
} end)




-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("frFR", function() return {
    ["Portrait sparks"] = "Étincelles du portrait",
    ["New ability sparkles"] = "Étincelles des nouvelles techniques",
    ["Background embers"] = "Braises en arrière-plan",
    ["Frame edge glow"] = "Lueur du cadre",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Portrait sparks"] = "Chispas del retrato",
    ["New ability sparkles"] = "Destellos en nuevas facultades",
    ["Background embers"] = "Ascuas de fondo",
    ["Frame edge glow"] = "Resplandor del marco",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Portrait sparks"] = "Chispas del retrato",
    ["New ability sparkles"] = "Destellos en nuevas facultades",
    ["Background embers"] = "Ascuas de fondo",
    ["Frame edge glow"] = "Resplandor del marco",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Portrait sparks"] = "Porträtfunken",
    ["New ability sparkles"] = "Funkeln neuer Fähigkeiten",
    ["Background embers"] = "Glut im Hintergrund",
    ["Frame edge glow"] = "Rahmenleuchten",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Portrait sparks"] = "Scintille del ritratto",
    ["New ability sparkles"] = "Scintille delle nuove abilità",
    ["Background embers"] = "Braci sullo sfondo",
    ["Frame edge glow"] = "Bagliore della cornice",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Portrait sparks"] = "Faíscas do retrato",
    ["New ability sparkles"] = "Brilhos nas novas habilidades",
    ["Background embers"] = "Brasas no fundo",
    ["Frame edge glow"] = "Brilho da moldura",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Portrait sparks"] = "Искры портрета",
    ["New ability sparkles"] = "Искры новых способностей",
    ["Background embers"] = "Угольки на фоне",
    ["Frame edge glow"] = "Свечение рамки",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Portrait sparks"] = "초상화 불꽃",
    ["New ability sparkles"] = "새 능력 반짝임",
    ["Background embers"] = "배경 불씨",
    ["Frame edge glow"] = "테두리 빛",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Portrait sparks"] = "头像火花",
    ["New ability sparkles"] = "新技能闪光",
    ["Background embers"] = "背景余烬",
    ["Frame edge glow"] = "边框辉光",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Portrait sparks"] = "頭像火花",
    ["New ability sparkles"] = "新技能閃光",
    ["Background embers"] = "背景餘燼",
    ["Frame edge glow"] = "邊框光暈",
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
RegisterLocaleBuilder("esES", function() return {
    ["Portrait mote count"] = "Motas del retrato : cantidad",
    ["Portrait mote size (%)"] = "Motas del retrato : tamaño (%)",
    ["Portrait mote opacity (%)"] = "Motas del retrato : opacidad (%)",
    ["Starburst mote count"] = "Motas del destello : cantidad",
    ["Starburst mote size (%)"] = "Motas del destello : tamaño (%)",
    ["Starburst mote opacity (%)"] = "Motas del destello : opacidad (%)",
    ["Background ember count"] = "Brasas del fondo : cantidad",
    ["Background ember size (%)"] = "Brasas del fondo : tamaño (%)",
    ["Background ember opacity (%)"] = "Brasas del fondo : opacidad (%)",
    ["Ability sparkle count"] = "Destellos de habilidad : cantidad",
    ["Ability sparkle size (%)"] = "Destellos de habilidad : tamaño (%)",
    ["Ability sparkle opacity (%)"] = "Destellos de habilidad : opacidad (%)",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Portrait mote count"] = "Motas del retrato : cantidad",
    ["Portrait mote size (%)"] = "Motas del retrato : tamaño (%)",
    ["Portrait mote opacity (%)"] = "Motas del retrato : opacidad (%)",
    ["Starburst mote count"] = "Motas del destello : cantidad",
    ["Starburst mote size (%)"] = "Motas del destello : tamaño (%)",
    ["Starburst mote opacity (%)"] = "Motas del destello : opacidad (%)",
    ["Background ember count"] = "Brasas del fondo : cantidad",
    ["Background ember size (%)"] = "Brasas del fondo : tamaño (%)",
    ["Background ember opacity (%)"] = "Brasas del fondo : opacidad (%)",
    ["Ability sparkle count"] = "Destellos de habilidad : cantidad",
    ["Ability sparkle size (%)"] = "Destellos de habilidad : tamaño (%)",
    ["Ability sparkle opacity (%)"] = "Destellos de habilidad : opacidad (%)",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Portrait mote count"] = "Porträtpartikel : Anzahl",
    ["Portrait mote size (%)"] = "Porträtpartikel : Größe (%)",
    ["Portrait mote opacity (%)"] = "Porträtpartikel : Deckkraft (%)",
    ["Starburst mote count"] = "Strahlenpartikel : Anzahl",
    ["Starburst mote size (%)"] = "Strahlenpartikel : Größe (%)",
    ["Starburst mote opacity (%)"] = "Strahlenpartikel : Deckkraft (%)",
    ["Background ember count"] = "Hintergrundglut : Anzahl",
    ["Background ember size (%)"] = "Hintergrundglut : Größe (%)",
    ["Background ember opacity (%)"] = "Hintergrundglut : Deckkraft (%)",
    ["Ability sparkle count"] = "Fähigkeitsfunken : Anzahl",
    ["Ability sparkle size (%)"] = "Fähigkeitsfunken : Größe (%)",
    ["Ability sparkle opacity (%)"] = "Fähigkeitsfunken : Deckkraft (%)",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Portrait mote count"] = "Particelle del ritratto : numero",
    ["Portrait mote size (%)"] = "Particelle del ritratto : dimensione (%)",
    ["Portrait mote opacity (%)"] = "Particelle del ritratto : opacità (%)",
    ["Starburst mote count"] = "Particelle del bagliore : numero",
    ["Starburst mote size (%)"] = "Particelle del bagliore : dimensione (%)",
    ["Starburst mote opacity (%)"] = "Particelle del bagliore : opacità (%)",
    ["Background ember count"] = "Braci dello sfondo : numero",
    ["Background ember size (%)"] = "Braci dello sfondo : dimensione (%)",
    ["Background ember opacity (%)"] = "Braci dello sfondo : opacità (%)",
    ["Ability sparkle count"] = "Scintille delle abilità : numero",
    ["Ability sparkle size (%)"] = "Scintille delle abilità : dimensione (%)",
    ["Ability sparkle opacity (%)"] = "Scintille delle abilità : opacità (%)",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Portrait mote count"] = "Partículas do retrato : quantidade",
    ["Portrait mote size (%)"] = "Partículas do retrato : tamanho (%)",
    ["Portrait mote opacity (%)"] = "Partículas do retrato : opacidade (%)",
    ["Starburst mote count"] = "Partículas do clarão : quantidade",
    ["Starburst mote size (%)"] = "Partículas do clarão : tamanho (%)",
    ["Starburst mote opacity (%)"] = "Partículas do clarão : opacidade (%)",
    ["Background ember count"] = "Brasas do fundo : quantidade",
    ["Background ember size (%)"] = "Brasas do fundo : tamanho (%)",
    ["Background ember opacity (%)"] = "Brasas do fundo : opacidade (%)",
    ["Ability sparkle count"] = "Brilhos de habilidade : quantidade",
    ["Ability sparkle size (%)"] = "Brilhos de habilidade : tamanho (%)",
    ["Ability sparkle opacity (%)"] = "Brilhos de habilidade : opacidade (%)",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Portrait mote count"] = "Частицы портрета : количество",
    ["Portrait mote size (%)"] = "Частицы портрета : размер (%)",
    ["Portrait mote opacity (%)"] = "Частицы портрета : непрозрачность (%)",
    ["Starburst mote count"] = "Частицы сияния : количество",
    ["Starburst mote size (%)"] = "Частицы сияния : размер (%)",
    ["Starburst mote opacity (%)"] = "Частицы сияния : непрозрачность (%)",
    ["Background ember count"] = "Угольки на фоне : количество",
    ["Background ember size (%)"] = "Угольки на фоне : размер (%)",
    ["Background ember opacity (%)"] = "Угольки на фоне : непрозрачность (%)",
    ["Ability sparkle count"] = "Искры способностей : количество",
    ["Ability sparkle size (%)"] = "Искры способностей : размер (%)",
    ["Ability sparkle opacity (%)"] = "Искры способностей : непрозрачность (%)",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Portrait mote count"] = "초상화 입자 : 개수",
    ["Portrait mote size (%)"] = "초상화 입자 : 크기 (%)",
    ["Portrait mote opacity (%)"] = "초상화 입자 : 불투명도 (%)",
    ["Starburst mote count"] = "광채 입자 : 개수",
    ["Starburst mote size (%)"] = "광채 입자 : 크기 (%)",
    ["Starburst mote opacity (%)"] = "광채 입자 : 불투명도 (%)",
    ["Background ember count"] = "배경 불씨 : 개수",
    ["Background ember size (%)"] = "배경 불씨 : 크기 (%)",
    ["Background ember opacity (%)"] = "배경 불씨 : 불투명도 (%)",
    ["Ability sparkle count"] = "능력 반짝임 : 개수",
    ["Ability sparkle size (%)"] = "능력 반짝임 : 크기 (%)",
    ["Ability sparkle opacity (%)"] = "능력 반짝임 : 불투명도 (%)",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Portrait mote count"] = "头像微粒 : 数量",
    ["Portrait mote size (%)"] = "头像微粒 : 大小 (%)",
    ["Portrait mote opacity (%)"] = "头像微粒 : 不透明度 (%)",
    ["Starburst mote count"] = "星芒微粒 : 数量",
    ["Starburst mote size (%)"] = "星芒微粒 : 大小 (%)",
    ["Starburst mote opacity (%)"] = "星芒微粒 : 不透明度 (%)",
    ["Background ember count"] = "背景余烬 : 数量",
    ["Background ember size (%)"] = "背景余烬 : 大小 (%)",
    ["Background ember opacity (%)"] = "背景余烬 : 不透明度 (%)",
    ["Ability sparkle count"] = "技能闪光 : 数量",
    ["Ability sparkle size (%)"] = "技能闪光 : 大小 (%)",
    ["Ability sparkle opacity (%)"] = "技能闪光 : 不透明度 (%)",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Portrait mote count"] = "頭像微粒 : 數量",
    ["Portrait mote size (%)"] = "頭像微粒 : 大小 (%)",
    ["Portrait mote opacity (%)"] = "頭像微粒 : 不透明度 (%)",
    ["Starburst mote count"] = "星芒微粒 : 數量",
    ["Starburst mote size (%)"] = "星芒微粒 : 大小 (%)",
    ["Starburst mote opacity (%)"] = "星芒微粒 : 不透明度 (%)",
    ["Background ember count"] = "背景餘燼 : 數量",
    ["Background ember size (%)"] = "背景餘燼 : 大小 (%)",
    ["Background ember opacity (%)"] = "背景餘燼 : 不透明度 (%)",
    ["Ability sparkle count"] = "技能閃光 : 數量",
    ["Ability sparkle size (%)"] = "技能閃光 : 大小 (%)",
    ["Ability sparkle opacity (%)"] = "技能閃光 : 不透明度 (%)",
} end)

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("frFR", function() return {
    ["Portrait and ring settle"] = "Stabilisation du portrait et de l’anneau",
    ["Reveal dividers"] = "Révéler les séparateurs",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Portrait and ring settle"] = "Asentar retrato y anillo",
    ["Reveal dividers"] = "Revelar separadores",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Portrait and ring settle"] = "Asentar retrato y anillo",
    ["Reveal dividers"] = "Revelar separadores",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Portrait and ring settle"] = "Porträt und Ring sanft einrasten",
    ["Reveal dividers"] = "Trennlinien einblenden",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Portrait and ring settle"] = "Assestamento di ritratto e cornice",
    ["Reveal dividers"] = "Comparsa dei separatori",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Portrait and ring settle"] = "Acomodar retrato e aro",
    ["Reveal dividers"] = "Revelar divisórias",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Portrait and ring settle"] = "Плавная посадка портрета и кольца",
    ["Reveal dividers"] = "Появление разделителей",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Portrait and ring settle"] = "초상화와 테두리 안착 효과",
    ["Reveal dividers"] = "구분선 펼치기",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Portrait and ring settle"] = "头像与边框收拢",
    ["Reveal dividers"] = "分隔线展开",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Portrait and ring settle"] = "頭像與邊框收攏",
    ["Reveal dividers"] = "分隔線展開",
} end)

RegisterLocaleBuilder("frFR", function() return { ["Animated Elements"] = "Éléments animés" } end)

RegisterLocaleBuilder("esES", function() return { ["Animated Elements"] = "Elementos animados" } end)

RegisterLocaleBuilder("esMX", function() return { ["Animated Elements"] = "Elementos animados" } end)

RegisterLocaleBuilder("deDE", function() return { ["Animated Elements"] = "Animierte Elemente" } end)

RegisterLocaleBuilder("itIT", function() return { ["Animated Elements"] = "Elementi animati" } end)

RegisterLocaleBuilder("ptBR", function() return { ["Animated Elements"] = "Elementos animados" } end)

RegisterLocaleBuilder("ruRU", function() return { ["Animated Elements"] = "Анимированные элементы" } end)

RegisterLocaleBuilder("koKR", function() return { ["Animated Elements"] = "애니메이션 요소" } end)

RegisterLocaleBuilder("zhCN", function() return { ["Animated Elements"] = "动画元素" } end)

RegisterLocaleBuilder("zhTW", function() return { ["Animated Elements"] = "動畫元素" } end)

RegisterLocaleBuilder("frFR", function() return {
    ["Starburst opacity (%)"] = "Opacité du halo rayonnant (%)",
    ["Portrait pulse opacity (%)"] = "Opacité de l’impulsion du portrait (%)",
    ["Frame edge glow opacity (%)"] = "Opacité de la lueur du cadre (%)",
} end)

RegisterLocaleBuilder("esES", function() return {
    ["Starburst opacity (%)"] = "Opacidad del destello radial (%)",
    ["Portrait pulse opacity (%)"] = "Opacidad del pulso del retrato (%)",
    ["Frame edge glow opacity (%)"] = "Opacidad del brillo del borde (%)",
} end)

RegisterLocaleBuilder("esMX", function() return {
    ["Starburst opacity (%)"] = "Opacidad del destello radial (%)",
    ["Portrait pulse opacity (%)"] = "Opacidad del pulso del retrato (%)",
    ["Frame edge glow opacity (%)"] = "Opacidad del brillo del borde (%)",
} end)

RegisterLocaleBuilder("deDE", function() return {
    ["Starburst opacity (%)"] = "Deckkraft des Strahlenkranzes (%)",
    ["Portrait pulse opacity (%)"] = "Deckkraft des Porträtimpulses (%)",
    ["Frame edge glow opacity (%)"] = "Deckkraft des Rahmenleuchtens (%)",
} end)

RegisterLocaleBuilder("itIT", function() return {
    ["Starburst opacity (%)"] = "Opacità della raggiera (%)",
    ["Portrait pulse opacity (%)"] = "Opacità dell’impulso del ritratto (%)",
    ["Frame edge glow opacity (%)"] = "Opacità del bagliore del bordo (%)",
} end)

RegisterLocaleBuilder("ptBR", function() return {
    ["Starburst opacity (%)"] = "Opacidade do clarão radial (%)",
    ["Portrait pulse opacity (%)"] = "Opacidade do pulso do retrato (%)",
    ["Frame edge glow opacity (%)"] = "Opacidade do brilho da borda (%)",
} end)

RegisterLocaleBuilder("ruRU", function() return {
    ["Starburst opacity (%)"] = "Непрозрачность звёздного сияния (%)",
    ["Portrait pulse opacity (%)"] = "Непрозрачность импульса портрета (%)",
    ["Frame edge glow opacity (%)"] = "Непрозрачность свечения рамки (%)",
} end)

RegisterLocaleBuilder("koKR", function() return {
    ["Starburst opacity (%)"] = "별빛 폭발 불투명도 (%)",
    ["Portrait pulse opacity (%)"] = "초상화 파동 불투명도 (%)",
    ["Frame edge glow opacity (%)"] = "테두리 발광 불투명도 (%)",
} end)

RegisterLocaleBuilder("zhCN", function() return {
    ["Starburst opacity (%)"] = "星芒不透明度 (%)",
    ["Portrait pulse opacity (%)"] = "头像脉冲不透明度 (%)",
    ["Frame edge glow opacity (%)"] = "边框发光不透明度 (%)",
} end)

RegisterLocaleBuilder("zhTW", function() return {
    ["Starburst opacity (%)"] = "星芒不透明度 (%)",
    ["Portrait pulse opacity (%)"] = "頭像脈衝不透明度 (%)",
    ["Frame edge glow opacity (%)"] = "邊框發光不透明度 (%)",
} end)

RegisterLocaleBuilder("frFR", function() return {
    ["Copy"] = "Copier",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Appuyez sur Ctrl+C pour copier. Le champ sera ensuite vidé.",
} end)

RegisterLocaleBuilder("esES", function() return {
    ["Copy"] = "Copiar",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Pulsa Ctrl+C para copiar. El campo se vaciará después.",
} end)

RegisterLocaleBuilder("esMX", function() return {
    ["Copy"] = "Copiar",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Presiona Ctrl+C para copiar. El campo se vaciará después.",
} end)

RegisterLocaleBuilder("deDE", function() return {
    ["Copy"] = "Kopieren",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Drücke Strg+C zum Kopieren. Danach wird das Feld geleert.",
} end)

RegisterLocaleBuilder("itIT", function() return {
    ["Copy"] = "Copia",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Premi Ctrl+C per copiare. Il campo verrà poi svuotato.",
} end)

RegisterLocaleBuilder("ptBR", function() return {
    ["Copy"] = "Copiar",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Pressione Ctrl+C para copiar. O campo será limpo em seguida.",
} end)

RegisterLocaleBuilder("ruRU", function() return {
    ["Copy"] = "Копировать",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Нажмите Ctrl+C для копирования. После этого поле очистится.",
} end)

RegisterLocaleBuilder("koKR", function() return {
    ["Copy"] = "복사",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Ctrl+C를 눌러 복사하세요. 복사 후 입력란이 비워집니다.",
} end)

RegisterLocaleBuilder("zhCN", function() return {
    ["Copy"] = "复制",
    ["Press Ctrl+C to copy. The field clears afterward."] = "按 Ctrl+C 复制，随后文本框将清空。",
} end)

RegisterLocaleBuilder("zhTW", function() return {
    ["Copy"] = "複製",
    ["Press Ctrl+C to copy. The field clears afterward."] = "按 Ctrl+C 複製，隨後文字框將清空。",
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

RegisterLocaleBuilder("esES", function() return {
    ["Profile"] = "Perfil",
    ["Save per Character"] = "Guardar por personaje",
    ["Profile name"] = "Nombre del perfil",
    ["Create profile"] = "Crear perfil",
    ["Import / export"] = "Importar / exportar",
    ["Import profile"] = "Importar perfil",
    ["Export profile"] = "Exportar perfil",
    ["Changes are saved automatically."] = "Los cambios se guardan automáticamente.",
    ["Profile created."] = "Perfil creado.",
    ["Profile imported."] = "Perfil importado.",
    ["Invalid profile string or profile name."] = "Cadena o nombre de perfil no válidos.",
    ["Enter a unique profile name (up to 80 characters)."] = "Introduce un nombre de perfil único (hasta 80 caracteres).",
    ["Imported profile"] = "Perfil importado",
    ["Press Ctrl+C to copy."] = "Pulsa Ctrl+C para copiar.",
} end)

RegisterLocaleBuilder("esMX", function() return {
    ["Profile"] = "Perfil",
    ["Save per Character"] = "Guardar por personaje",
    ["Profile name"] = "Nombre del perfil",
    ["Create profile"] = "Crear perfil",
    ["Import / export"] = "Importar / exportar",
    ["Import profile"] = "Importar perfil",
    ["Export profile"] = "Exportar perfil",
    ["Changes are saved automatically."] = "Los cambios se guardan automáticamente.",
    ["Profile created."] = "Perfil creado.",
    ["Profile imported."] = "Perfil importado.",
    ["Invalid profile string or profile name."] = "Cadena o nombre de perfil no válidos.",
    ["Enter a unique profile name (up to 80 characters)."] = "Ingresa un nombre de perfil único (hasta 80 caracteres).",
    ["Imported profile"] = "Perfil importado",
    ["Press Ctrl+C to copy."] = "Presiona Ctrl+C para copiar.",
} end)

RegisterLocaleBuilder("deDE", function() return {
    ["Profile"] = "Profil",
    ["Save per Character"] = "Pro Charakter speichern",
    ["Profile name"] = "Profilname",
    ["Create profile"] = "Profil erstellen",
    ["Import / export"] = "Import / Export",
    ["Import profile"] = "Profil importieren",
    ["Export profile"] = "Profil exportieren",
    ["Changes are saved automatically."] = "Änderungen werden automatisch gespeichert.",
    ["Profile created."] = "Profil erstellt.",
    ["Profile imported."] = "Profil importiert.",
    ["Invalid profile string or profile name."] = "Ungültige Profilzeichenfolge oder ungültiger Profilname.",
    ["Enter a unique profile name (up to 80 characters)."] = "Gib einen eindeutigen Profilnamen ein (bis zu 80 Zeichen).",
    ["Imported profile"] = "Importiertes Profil",
    ["Press Ctrl+C to copy."] = "Drücke Strg+C zum Kopieren.",
} end)

RegisterLocaleBuilder("itIT", function() return {
    ["Profile"] = "Profilo",
    ["Save per Character"] = "Salva per personaggio",
    ["Profile name"] = "Nome del profilo",
    ["Create profile"] = "Crea profilo",
    ["Import / export"] = "Importa / esporta",
    ["Import profile"] = "Importa profilo",
    ["Export profile"] = "Esporta profilo",
    ["Changes are saved automatically."] = "Le modifiche vengono salvate automaticamente.",
    ["Profile created."] = "Profilo creato.",
    ["Profile imported."] = "Profilo importato.",
    ["Invalid profile string or profile name."] = "Stringa o nome del profilo non validi.",
    ["Enter a unique profile name (up to 80 characters)."] = "Inserisci un nome di profilo univoco (fino a 80 caratteri).",
    ["Imported profile"] = "Profilo importato",
    ["Press Ctrl+C to copy."] = "Premi Ctrl+C per copiare.",
} end)

RegisterLocaleBuilder("ptBR", function() return {
    ["Profile"] = "Perfil",
    ["Save per Character"] = "Salvar por personagem",
    ["Profile name"] = "Nome do perfil",
    ["Create profile"] = "Criar perfil",
    ["Import / export"] = "Importar / exportar",
    ["Import profile"] = "Importar perfil",
    ["Export profile"] = "Exportar perfil",
    ["Changes are saved automatically."] = "As alterações são salvas automaticamente.",
    ["Profile created."] = "Perfil criado.",
    ["Profile imported."] = "Perfil importado.",
    ["Invalid profile string or profile name."] = "Texto ou nome de perfil inválido.",
    ["Enter a unique profile name (up to 80 characters)."] = "Digite um nome de perfil único (até 80 caracteres).",
    ["Imported profile"] = "Perfil importado",
    ["Press Ctrl+C to copy."] = "Pressione Ctrl+C para copiar.",
} end)

RegisterLocaleBuilder("ruRU", function() return {
    ["Profile"] = "Профиль",
    ["Save per Character"] = "Сохранять для персонажа",
    ["Profile name"] = "Название профиля",
    ["Create profile"] = "Создать профиль",
    ["Import / export"] = "Импорт / экспорт",
    ["Import profile"] = "Импорт профиля",
    ["Export profile"] = "Экспорт профиля",
    ["Changes are saved automatically."] = "Изменения сохраняются автоматически.",
    ["Profile created."] = "Профиль создан.",
    ["Profile imported."] = "Профиль импортирован.",
    ["Invalid profile string or profile name."] = "Недопустимая строка или название профиля.",
    ["Enter a unique profile name (up to 80 characters)."] = "Введите уникальное название профиля (до 80 символов).",
    ["Imported profile"] = "Импортированный профиль",
    ["Press Ctrl+C to copy."] = "Нажмите Ctrl+C для копирования.",
} end)

RegisterLocaleBuilder("koKR", function() return {
    ["Profile"] = "프로필",
    ["Save per Character"] = "캐릭터별 저장",
    ["Profile name"] = "프로필 이름",
    ["Create profile"] = "프로필 생성",
    ["Import / export"] = "가져오기 / 내보내기",
    ["Import profile"] = "프로필 가져오기",
    ["Export profile"] = "프로필 내보내기",
    ["Changes are saved automatically."] = "변경 사항은 자동으로 저장됩니다.",
    ["Profile created."] = "프로필을 생성했습니다.",
    ["Profile imported."] = "프로필을 가져왔습니다.",
    ["Invalid profile string or profile name."] = "프로필 문자열 또는 이름이 올바르지 않습니다.",
    ["Enter a unique profile name (up to 80 characters)."] = "고유한 프로필 이름을 입력하세요 (최대 80자).",
    ["Imported profile"] = "가져온 프로필",
    ["Press Ctrl+C to copy."] = "Ctrl+C를 눌러 복사하세요.",
} end)

RegisterLocaleBuilder("zhCN", function() return {
    ["Profile"] = "配置",
    ["Save per Character"] = "按角色保存",
    ["Profile name"] = "配置名称",
    ["Create profile"] = "创建配置",
    ["Import / export"] = "导入 / 导出",
    ["Import profile"] = "导入配置",
    ["Export profile"] = "导出配置",
    ["Changes are saved automatically."] = "更改会自动保存。",
    ["Profile created."] = "配置已创建。",
    ["Profile imported."] = "配置已导入。",
    ["Invalid profile string or profile name."] = "配置字符串或名称无效。",
    ["Enter a unique profile name (up to 80 characters)."] = "请输入唯一的配置名称（最多80个字符）。",
    ["Imported profile"] = "导入的配置",
    ["Press Ctrl+C to copy."] = "按 Ctrl+C 复制。",
} end)

RegisterLocaleBuilder("zhTW", function() return {
    ["Profile"] = "設定檔",
    ["Save per Character"] = "依角色儲存",
    ["Profile name"] = "設定檔名稱",
    ["Create profile"] = "建立設定檔",
    ["Import / export"] = "匯入 / 匯出",
    ["Import profile"] = "匯入設定檔",
    ["Export profile"] = "匯出設定檔",
    ["Changes are saved automatically."] = "變更會自動儲存。",
    ["Profile created."] = "設定檔已建立。",
    ["Profile imported."] = "設定檔已匯入。",
    ["Invalid profile string or profile name."] = "設定檔字串或名稱無效。",
    ["Enter a unique profile name (up to 80 characters)."] = "請輸入不重複的設定檔名稱（最多80個字元）。",
    ["Imported profile"] = "匯入的設定檔",
    ["Press Ctrl+C to copy."] = "按 Ctrl+C 複製。",
} end)


-- Profile-sharing window.
RegisterLocaleBuilder("frFR", function() return {
    ["Profile name (optional)"] = "Nom du profil (facultatif)",
    ["Invalid profile string."] = "Chaîne de profil invalide.",
    ["Invalid profile settings."] = "Paramètres de profil invalides.",
} end)

RegisterLocaleBuilder("esES", function() return {
    ["Profile name (optional)"] = "Nombre del perfil (opcional)",
    ["Invalid profile string."] = "Cadena de perfil no válida.",
    ["Invalid profile settings."] = "Ajustes del perfil no válidos.",
} end)

RegisterLocaleBuilder("esMX", function() return {
    ["Profile name (optional)"] = "Nombre del perfil (opcional)",
    ["Invalid profile string."] = "Cadena de perfil no válida.",
    ["Invalid profile settings."] = "Configuración del perfil no válida.",
} end)

RegisterLocaleBuilder("deDE", function() return {
    ["Profile name (optional)"] = "Profilname (optional)",
    ["Invalid profile string."] = "Ungültige Profilzeichenfolge.",
    ["Invalid profile settings."] = "Ungültige Profileinstellungen.",
} end)

RegisterLocaleBuilder("itIT", function() return {
    ["Profile name (optional)"] = "Nome del profilo (facoltativo)",
    ["Invalid profile string."] = "Stringa del profilo non valida.",
    ["Invalid profile settings."] = "Impostazioni del profilo non valide.",
} end)

RegisterLocaleBuilder("ptBR", function() return {
    ["Profile name (optional)"] = "Nome do perfil (opcional)",
    ["Invalid profile string."] = "Texto de perfil inválido.",
    ["Invalid profile settings."] = "Configurações de perfil inválidas.",
} end)

RegisterLocaleBuilder("ruRU", function() return {
    ["Profile name (optional)"] = "Название профиля (необязательно)",
    ["Invalid profile string."] = "Недопустимая строка профиля.",
    ["Invalid profile settings."] = "Недопустимые настройки профиля.",
} end)

RegisterLocaleBuilder("koKR", function() return {
    ["Profile name (optional)"] = "프로필 이름 (선택 사항)",
    ["Invalid profile string."] = "프로필 문자열이 올바르지 않습니다.",
    ["Invalid profile settings."] = "프로필 설정이 올바르지 않습니다.",
} end)

RegisterLocaleBuilder("zhCN", function() return {
    ["Profile name (optional)"] = "配置名称（可选）",
    ["Invalid profile string."] = "配置字符串无效。",
    ["Invalid profile settings."] = "配置设置无效。",
} end)

RegisterLocaleBuilder("zhTW", function() return {
    ["Profile name (optional)"] = "設定檔名稱（選填）",
    ["Invalid profile string."] = "設定檔字串無效。",
    ["Invalid profile settings."] = "設定檔設定無效。",
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

RegisterLocaleBuilder("esES", function() return {
    ["Rename profile"] = "Renombrar perfil",
    ["Delete profile"] = "Eliminar perfil",
    ["Profile renamed."] = "Perfil renombrado.",
    ["Profile deleted."] = "Perfil eliminado.",
    ["Default profile cannot be renamed or deleted."] = "El perfil Default no se puede renombrar ni eliminar.",
    ["Profile not found."] = "No se ha encontrado el perfil.",
    ["Profile limit reached (50)."] = "Se ha alcanzado el límite de perfiles (50).",
    ["Delete profile \"%s\"?"] = "¿Eliminar el perfil «%s»?",
    ["Cancel"] = "Cancelar",
    ["Manage profiles"] = "Gestionar perfiles",
} end)

RegisterLocaleBuilder("esMX", function() return {
    ["Rename profile"] = "Renombrar perfil",
    ["Delete profile"] = "Eliminar perfil",
    ["Profile renamed."] = "Perfil renombrado.",
    ["Profile deleted."] = "Perfil eliminado.",
    ["Default profile cannot be renamed or deleted."] = "El perfil Default no se puede renombrar ni eliminar.",
    ["Profile not found."] = "No se encontró el perfil.",
    ["Profile limit reached (50)."] = "Se alcanzó el límite de perfiles (50).",
    ["Delete profile \"%s\"?"] = "¿Eliminar el perfil «%s»?",
    ["Cancel"] = "Cancelar",
    ["Manage profiles"] = "Administrar perfiles",
} end)

RegisterLocaleBuilder("deDE", function() return {
    ["Rename profile"] = "Profil umbenennen",
    ["Delete profile"] = "Profil löschen",
    ["Profile renamed."] = "Profil umbenannt.",
    ["Profile deleted."] = "Profil gelöscht.",
    ["Default profile cannot be renamed or deleted."] = "Das Profil Default kann nicht umbenannt oder gelöscht werden.",
    ["Profile not found."] = "Profil nicht gefunden.",
    ["Profile limit reached (50)."] = "Profillimit erreicht (50).",
    ["Delete profile \"%s\"?"] = "Profil „%s“ löschen?",
    ["Cancel"] = "Abbrechen",
    ["Manage profiles"] = "Profile verwalten",
} end)

RegisterLocaleBuilder("itIT", function() return {
    ["Rename profile"] = "Rinomina profilo",
    ["Delete profile"] = "Elimina profilo",
    ["Profile renamed."] = "Profilo rinominato.",
    ["Profile deleted."] = "Profilo eliminato.",
    ["Default profile cannot be renamed or deleted."] = "Il profilo Default non può essere rinominato o eliminato.",
    ["Profile not found."] = "Profilo non trovato.",
    ["Profile limit reached (50)."] = "Limite di profili raggiunto (50).",
    ["Delete profile \"%s\"?"] = "Eliminare il profilo \"%s\"?",
    ["Cancel"] = "Annulla",
    ["Manage profiles"] = "Gestisci profili",
} end)

RegisterLocaleBuilder("ptBR", function() return {
    ["Rename profile"] = "Renomear perfil",
    ["Delete profile"] = "Excluir perfil",
    ["Profile renamed."] = "Perfil renomeado.",
    ["Profile deleted."] = "Perfil excluído.",
    ["Default profile cannot be renamed or deleted."] = "O perfil Default não pode ser renomeado nem excluído.",
    ["Profile not found."] = "Perfil não encontrado.",
    ["Profile limit reached (50)."] = "Limite de perfis atingido (50).",
    ["Delete profile \"%s\"?"] = "Excluir o perfil \"%s\"?",
    ["Cancel"] = "Cancelar",
    ["Manage profiles"] = "Gerenciar perfis",
} end)

RegisterLocaleBuilder("ruRU", function() return {
    ["Rename profile"] = "Переименовать профиль",
    ["Delete profile"] = "Удалить профиль",
    ["Profile renamed."] = "Профиль переименован.",
    ["Profile deleted."] = "Профиль удалён.",
    ["Default profile cannot be renamed or deleted."] = "Профиль Default нельзя переименовать или удалить.",
    ["Profile not found."] = "Профиль не найден.",
    ["Profile limit reached (50)."] = "Достигнут предел профилей (50).",
    ["Delete profile \"%s\"?"] = "Удалить профиль «%s»?",
    ["Cancel"] = "Отмена",
    ["Manage profiles"] = "Управление профилями",
} end)

RegisterLocaleBuilder("koKR", function() return {
    ["Rename profile"] = "프로필 이름 변경",
    ["Delete profile"] = "프로필 삭제",
    ["Profile renamed."] = "프로필 이름을 변경했습니다.",
    ["Profile deleted."] = "프로필을 삭제했습니다.",
    ["Default profile cannot be renamed or deleted."] = "Default 프로필은 이름을 바꾸거나 삭제할 수 없습니다.",
    ["Profile not found."] = "프로필을 찾을 수 없습니다.",
    ["Profile limit reached (50)."] = "프로필 수 제한에 도달했습니다 (50).",
    ["Delete profile \"%s\"?"] = "\"%s\" 프로필을 삭제하시겠습니까?",
    ["Cancel"] = "취소",
    ["Manage profiles"] = "프로필 관리",
} end)

RegisterLocaleBuilder("zhCN", function() return {
    ["Rename profile"] = "重命名配置",
    ["Delete profile"] = "删除配置",
    ["Profile renamed."] = "配置已重命名。",
    ["Profile deleted."] = "配置已删除。",
    ["Default profile cannot be renamed or deleted."] = "无法重命名或删除 Default 配置。",
    ["Profile not found."] = "找不到配置。",
    ["Profile limit reached (50)."] = "已达到配置数量上限（50）。",
    ["Delete profile \"%s\"?"] = "删除配置“%s”？",
    ["Cancel"] = "取消",
    ["Manage profiles"] = "管理配置",
} end)

RegisterLocaleBuilder("zhTW", function() return {
    ["Rename profile"] = "重新命名設定檔",
    ["Delete profile"] = "刪除設定檔",
    ["Profile renamed."] = "設定檔已重新命名。",
    ["Profile deleted."] = "設定檔已刪除。",
    ["Default profile cannot be renamed or deleted."] = "無法重新命名或刪除 Default 設定檔。",
    ["Profile not found."] = "找不到設定檔。",
    ["Profile limit reached (50)."] = "已達設定檔數量上限（50）。",
    ["Delete profile \"%s\"?"] = "要刪除設定檔「%s」嗎？",
    ["Cancel"] = "取消",
    ["Manage profiles"] = "管理設定檔",
} end)


-- First-run setup.
RegisterLocaleBuilder("frFR", function() return {
    ["GLU First Time Setup"] = "GLU — Première configuration",
    ["Finish setup"] = "Terminer la configuration",
    ["Change these choices anytime in Options."] = "Vous pouvez modifier ces choix à tout moment dans les options.",
} end)

RegisterLocaleBuilder("esES", function() return {
    ["GLU First Time Setup"] = "GLU — Configuración inicial",
    ["Finish setup"] = "Finalizar configuración",
    ["Change these choices anytime in Options."] = "Puedes cambiar estas opciones en cualquier momento en Opciones.",
} end)

RegisterLocaleBuilder("esMX", function() return {
    ["GLU First Time Setup"] = "GLU — Configuración inicial",
    ["Finish setup"] = "Finalizar configuración",
    ["Change these choices anytime in Options."] = "Puedes cambiar estas opciones en cualquier momento en Opciones.",
} end)

RegisterLocaleBuilder("deDE", function() return {
    ["GLU First Time Setup"] = "GLU — Ersteinrichtung",
    ["Finish setup"] = "Einrichtung abschließen",
    ["Change these choices anytime in Options."] = "Diese Auswahl kann jederzeit in den Optionen geändert werden.",
} end)

RegisterLocaleBuilder("itIT", function() return {
    ["GLU First Time Setup"] = "GLU — Configurazione iniziale",
    ["Finish setup"] = "Completa configurazione",
    ["Change these choices anytime in Options."] = "Puoi modificare queste scelte in qualsiasi momento nelle opzioni.",
} end)

RegisterLocaleBuilder("ptBR", function() return {
    ["GLU First Time Setup"] = "GLU — Configuração inicial",
    ["Finish setup"] = "Concluir configuração",
    ["Change these choices anytime in Options."] = "Você pode alterar estas escolhas a qualquer momento nas opções.",
} end)

RegisterLocaleBuilder("ruRU", function() return {
    ["GLU First Time Setup"] = "GLU — Первоначальная настройка",
    ["Finish setup"] = "Завершить настройку",
    ["Change these choices anytime in Options."] = "Эти настройки можно изменить в любое время в меню параметров.",
} end)

RegisterLocaleBuilder("koKR", function() return {
    ["GLU First Time Setup"] = "GLU 최초 설정",
    ["Finish setup"] = "설정 완료",
    ["Change these choices anytime in Options."] = "언제든지 옵션에서 변경할 수 있습니다.",
} end)

RegisterLocaleBuilder("zhCN", function() return {
    ["GLU First Time Setup"] = "GLU 首次设置",
    ["Finish setup"] = "完成设置",
    ["Change these choices anytime in Options."] = "您可以随时在选项中更改这些设置。",
} end)

RegisterLocaleBuilder("zhTW", function() return {
    ["GLU First Time Setup"] = "GLU 首次設定",
    ["Finish setup"] = "完成設定",
    ["Change these choices anytime in Options."] = "您可以隨時在選項中變更這些設定。",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("frFR", function() return {
    ["Show pet skills"] = "Afficher les compétences des familiers",
    ["Enable animations"] = "Activer les animations",
} end)

RegisterLocaleBuilder("esES", function() return {
    ["Show pet skills"] = "Mostrar habilidades de mascotas",
    ["Enable animations"] = "Activar animaciones",
} end)

RegisterLocaleBuilder("esMX", function() return {
    ["Show pet skills"] = "Mostrar habilidades de mascotas",
    ["Enable animations"] = "Activar animaciones",
} end)

RegisterLocaleBuilder("deDE", function() return {
    ["Show pet skills"] = "Begleiterfähigkeiten anzeigen",
    ["Enable animations"] = "Animationen aktivieren",
} end)

RegisterLocaleBuilder("itIT", function() return {
    ["Show pet skills"] = "Mostra abilità dei famigli",
    ["Enable animations"] = "Abilita animazioni",
} end)

RegisterLocaleBuilder("ptBR", function() return {
    ["Show pet skills"] = "Mostrar habilidades dos ajudantes",
    ["Enable animations"] = "Ativar animações",
} end)

RegisterLocaleBuilder("ruRU", function() return {
    ["Show pet skills"] = "Показывать умения питомцев",
    ["Enable animations"] = "Включить анимации",
} end)

RegisterLocaleBuilder("koKR", function() return {
    ["Show pet skills"] = "소환수 기술 표시",
    ["Enable animations"] = "애니메이션 사용",
} end)

RegisterLocaleBuilder("zhCN", function() return {
    ["Show pet skills"] = "显示宠物技能",
    ["Enable animations"] = "启用动画",
} end)

RegisterLocaleBuilder("zhTW", function() return {
    ["Show pet skills"] = "顯示寵物技能",
    ["Enable animations"] = "啟用動畫",
} end)

-- Setup heading.
RegisterLocaleBuilder("frFR", function() return { ["Welcome to GnomeLevelUp!"] = "Bienvenue dans GnomeLevelUp !" } end)
RegisterLocaleBuilder("esES", function() return { ["Welcome to GnomeLevelUp!"] = "¡Bienvenido a GnomeLevelUp!" } end)
RegisterLocaleBuilder("esMX", function() return { ["Welcome to GnomeLevelUp!"] = "¡Bienvenido a GnomeLevelUp!" } end)
RegisterLocaleBuilder("deDE", function() return { ["Welcome to GnomeLevelUp!"] = "Willkommen bei GnomeLevelUp!" } end)
RegisterLocaleBuilder("itIT", function() return { ["Welcome to GnomeLevelUp!"] = "Benvenuto in GnomeLevelUp!" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Welcome to GnomeLevelUp!"] = "Boas-vindas ao GnomeLevelUp!" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Welcome to GnomeLevelUp!"] = "Добро пожаловать в GnomeLevelUp!" } end)
RegisterLocaleBuilder("koKR", function() return { ["Welcome to GnomeLevelUp!"] = "GnomeLevelUp에 오신 것을 환영합니다!" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Welcome to GnomeLevelUp!"] = "欢迎使用 GnomeLevelUp！" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Welcome to GnomeLevelUp!"] = "歡迎使用 GnomeLevelUp！" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("frFR", function() return { ["Background animations"] = "Animations de fond" } end)
RegisterLocaleBuilder("esES", function() return { ["Background animations"] = "Animaciones de fondo" } end)
RegisterLocaleBuilder("esMX", function() return { ["Background animations"] = "Animaciones de fondo" } end)
RegisterLocaleBuilder("deDE", function() return { ["Background animations"] = "Hintergrundanimationen" } end)
RegisterLocaleBuilder("itIT", function() return { ["Background animations"] = "Animazioni di sfondo" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Background animations"] = "Animações de fundo" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Background animations"] = "Фоновые анимации" } end)
RegisterLocaleBuilder("koKR", function() return { ["Background animations"] = "배경 애니메이션" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Background animations"] = "背景动画" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Background animations"] = "背景動畫" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("frFR", function() return { ["Horizontal layout"] = "Disposition horizontale" } end)
RegisterLocaleBuilder("esES", function() return { ["Horizontal layout"] = "Diseño horizontal" } end)
RegisterLocaleBuilder("esMX", function() return { ["Horizontal layout"] = "Diseño horizontal" } end)
RegisterLocaleBuilder("deDE", function() return { ["Horizontal layout"] = "Horizontales Layout" } end)
RegisterLocaleBuilder("itIT", function() return { ["Horizontal layout"] = "Disposizione orizzontale" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Horizontal layout"] = "Layout horizontal" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Horizontal layout"] = "Горизонтальная компоновка" } end)
RegisterLocaleBuilder("koKR", function() return { ["Horizontal layout"] = "가로 배치" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Horizontal layout"] = "横向布局" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Horizontal layout"] = "橫向配置" } end)

RegisterLocaleBuilder("frFR", function() return { ["Player 3D portrait"] = "Portrait 3D du joueur" } end)

RegisterLocaleBuilder("esES", function() return { ["Player 3D portrait"] = "Retrato 3D del jugador" } end)

RegisterLocaleBuilder("esMX", function() return { ["Player 3D portrait"] = "Retrato 3D del jugador" } end)

RegisterLocaleBuilder("deDE", function() return { ["Player 3D portrait"] = "3D-Spielerporträt" } end)

RegisterLocaleBuilder("itIT", function() return { ["Player 3D portrait"] = "Ritratto 3D del giocatore" } end)

RegisterLocaleBuilder("ptBR", function() return { ["Player 3D portrait"] = "Retrato 3D do jogador" } end)

RegisterLocaleBuilder("ruRU", function() return { ["Player 3D portrait"] = "3D-портрет игрока" } end)

RegisterLocaleBuilder("koKR", function() return { ["Player 3D portrait"] = "플레이어 3D 초상화" } end)

RegisterLocaleBuilder("zhCN", function() return { ["Player 3D portrait"] = "玩家3D头像" } end)

RegisterLocaleBuilder("zhTW", function() return { ["Player 3D portrait"] = "玩家3D頭像" } end)

RegisterLocaleBuilder("frFR", function() return { ["3D model rotation (degrees)"] = "Rotation du modèle 3D (degrés)", ["3D model depth"] = "Profondeur du modèle 3D", ["3D model horizontal position"] = "Position horizontale du modèle 3D", ["3D model vertical position"] = "Position verticale du modèle 3D", ["3D model scale (%)"] = "Échelle du modèle 3D (%)" } end)

RegisterLocaleBuilder("esES", function() return { ["3D model rotation (degrees)"] = "Rotación del modelo 3D (grados)", ["3D model depth"] = "Profundidad del modelo 3D", ["3D model horizontal position"] = "Posición horizontal del modelo 3D", ["3D model vertical position"] = "Posición vertical del modelo 3D", ["3D model scale (%)"] = "Escala del modelo 3D (%)" } end)

RegisterLocaleBuilder("esMX", function() return { ["3D model rotation (degrees)"] = "Rotación del modelo 3D (grados)", ["3D model depth"] = "Profundidad del modelo 3D", ["3D model horizontal position"] = "Posición horizontal del modelo 3D", ["3D model vertical position"] = "Posición vertical del modelo 3D", ["3D model scale (%)"] = "Escala del modelo 3D (%)" } end)

RegisterLocaleBuilder("deDE", function() return { ["3D model rotation (degrees)"] = "3D-Modelldrehung (Grad)", ["3D model depth"] = "3D-Modelltiefe", ["3D model horizontal position"] = "Horizontale 3D-Modellposition", ["3D model vertical position"] = "Vertikale 3D-Modellposition", ["3D model scale (%)"] = "3D-Modellskalierung (%)" } end)

RegisterLocaleBuilder("itIT", function() return { ["3D model rotation (degrees)"] = "Rotazione modello 3D (gradi)", ["3D model depth"] = "Profondità modello 3D", ["3D model horizontal position"] = "Posizione orizzontale modello 3D", ["3D model vertical position"] = "Posizione verticale modello 3D", ["3D model scale (%)"] = "Scala modello 3D (%)" } end)

RegisterLocaleBuilder("ptBR", function() return { ["3D model rotation (degrees)"] = "Rotação do modelo 3D (graus)", ["3D model depth"] = "Profundidade do modelo 3D", ["3D model horizontal position"] = "Posição horizontal do modelo 3D", ["3D model vertical position"] = "Posição vertical do modelo 3D", ["3D model scale (%)"] = "Escala do modelo 3D (%)" } end)

RegisterLocaleBuilder("ruRU", function() return { ["3D model rotation (degrees)"] = "Поворот 3D-модели (градусы)", ["3D model depth"] = "Глубина 3D-модели", ["3D model horizontal position"] = "Горизонтальное положение 3D-модели", ["3D model vertical position"] = "Вертикальное положение 3D-модели", ["3D model scale (%)"] = "Масштаб 3D-модели (%)" } end)

RegisterLocaleBuilder("koKR", function() return { ["3D model rotation (degrees)"] = "3D 모델 회전 (도)", ["3D model depth"] = "3D 모델 깊이", ["3D model horizontal position"] = "3D 모델 가로 위치", ["3D model vertical position"] = "3D 모델 세로 위치", ["3D model scale (%)"] = "3D 모델 크기 (%)" } end)

RegisterLocaleBuilder("zhCN", function() return { ["3D model rotation (degrees)"] = "3D模型旋转（度）", ["3D model depth"] = "3D模型深度", ["3D model horizontal position"] = "3D模型水平位置", ["3D model vertical position"] = "3D模型垂直位置", ["3D model scale (%)"] = "3D模型缩放（%）" } end)

RegisterLocaleBuilder("zhTW", function() return { ["3D model rotation (degrees)"] = "3D模型旋轉（度）", ["3D model depth"] = "3D模型深度", ["3D model horizontal position"] = "3D模型水平位置", ["3D model vertical position"] = "3D模型垂直位置", ["3D model scale (%)"] = "3D模型縮放（%）" } end)

RegisterLocaleBuilder("frFR", function() return { ["3D mask size (%)"] = "Taille du masque 3D (%)" } end)
RegisterLocaleBuilder("esES", function() return { ["3D mask size (%)"] = "Tamaño de la máscara 3D (%)" } end)
RegisterLocaleBuilder("esMX", function() return { ["3D mask size (%)"] = "Tamaño de la máscara 3D (%)" } end)
RegisterLocaleBuilder("deDE", function() return { ["3D mask size (%)"] = "3D-Maskengröße (%)" } end)
RegisterLocaleBuilder("itIT", function() return { ["3D mask size (%)"] = "Dimensione maschera 3D (%)" } end)
RegisterLocaleBuilder("ptBR", function() return { ["3D mask size (%)"] = "Tamanho da máscara 3D (%)" } end)
RegisterLocaleBuilder("ruRU", function() return { ["3D mask size (%)"] = "Размер 3D-маски (%)" } end)
RegisterLocaleBuilder("koKR", function() return { ["3D mask size (%)"] = "3D 마스크 크기 (%)" } end)
RegisterLocaleBuilder("zhCN", function() return { ["3D mask size (%)"] = "3D遮罩大小（%）" } end)
RegisterLocaleBuilder("zhTW", function() return { ["3D mask size (%)"] = "3D遮罩大小（%）" } end)

RegisterLocaleBuilder("frFR", function() return { ["3D viewport size (%)"] = "Taille de la fenêtre 3D (%)" } end)
RegisterLocaleBuilder("esES", function() return { ["3D viewport size (%)"] = "Tamaño del área de vista 3D (%)" } end)
RegisterLocaleBuilder("esMX", function() return { ["3D viewport size (%)"] = "Tamaño del área de vista 3D (%)" } end)
RegisterLocaleBuilder("deDE", function() return { ["3D viewport size (%)"] = "3D-Ansichtsgröße (%)" } end)
RegisterLocaleBuilder("itIT", function() return { ["3D viewport size (%)"] = "Dimensione area di visualizzazione 3D (%)" } end)
RegisterLocaleBuilder("ptBR", function() return { ["3D viewport size (%)"] = "Tamanho da área de visualização 3D (%)" } end)
RegisterLocaleBuilder("ruRU", function() return { ["3D viewport size (%)"] = "Размер области 3D-модели (%)" } end)
RegisterLocaleBuilder("koKR", function() return { ["3D viewport size (%)"] = "3D 표시 영역 크기 (%)" } end)
RegisterLocaleBuilder("zhCN", function() return { ["3D viewport size (%)"] = "3D视口大小（%）" } end)
RegisterLocaleBuilder("zhTW", function() return { ["3D viewport size (%)"] = "3D視口大小（%）" } end)

RegisterLocaleBuilder("frFR", function() return { ["Milestone Animations"] = "Animations de palier" } end)
RegisterLocaleBuilder("deDE", function() return { ["Milestone Animations"] = "Meilensteinanimationen" } end)
RegisterLocaleBuilder("esES", function() return { ["Milestone Animations"] = "Animaciones de hito" } end)
RegisterLocaleBuilder("esMX", function() return { ["Milestone Animations"] = "Animaciones de hito" } end)
RegisterLocaleBuilder("itIT", function() return { ["Milestone Animations"] = "Animazioni dei traguardi" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Milestone Animations"] = "Animações de marcos" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Milestone Animations"] = "Анимации юбилейных уровней" } end)
RegisterLocaleBuilder("koKR", function() return { ["Milestone Animations"] = "주요 레벨 애니메이션" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Milestone Animations"] = "里程碑动画" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Milestone Animations"] = "里程碑動畫" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("frFR", function() return { ["Firework size (%)"] = "Taille des feux d’artifice (%)", ["Firework opacity (%)"] = "Opacité des feux d’artifice (%)" } end)
RegisterLocaleBuilder("esES", function() return { ["Firework size (%)"] = "Tamaño de los fuegos artificiales (%)", ["Firework opacity (%)"] = "Opacidad de los fuegos artificiales (%)" } end)
RegisterLocaleBuilder("esMX", function() return { ["Firework size (%)"] = "Tamaño de los fuegos artificiales (%)", ["Firework opacity (%)"] = "Opacidad de los fuegos artificiales (%)" } end)
RegisterLocaleBuilder("deDE", function() return { ["Firework size (%)"] = "Feuerwerksgröße (%)", ["Firework opacity (%)"] = "Feuerwerksdeckkraft (%)" } end)
RegisterLocaleBuilder("itIT", function() return { ["Firework size (%)"] = "Dimensione fuochi d’artificio (%)", ["Firework opacity (%)"] = "Opacità fuochi d’artificio (%)" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Firework size (%)"] = "Tamanho dos fogos de artifício (%)", ["Firework opacity (%)"] = "Opacidade dos fogos de artifício (%)" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Firework size (%)"] = "Размер фейерверков (%)", ["Firework opacity (%)"] = "Непрозрачность фейерверков (%)" } end)
RegisterLocaleBuilder("koKR", function() return { ["Firework size (%)"] = "불꽃놀이 크기 (%)", ["Firework opacity (%)"] = "불꽃놀이 불투명도 (%)" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Firework size (%)"] = "烟花大小（%）", ["Firework opacity (%)"] = "烟花不透明度（%）" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Firework size (%)"] = "煙火大小（%）", ["Firework opacity (%)"] = "煙火不透明度（%）" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("frFR", function() return { ["Frame inset (px)"] = "Marge du cadre (px)" } end)
RegisterLocaleBuilder("esES", function() return { ["Frame inset (px)"] = "Margen del marco (px)" } end)
RegisterLocaleBuilder("esMX", function() return { ["Frame inset (px)"] = "Margen del marco (px)" } end)
RegisterLocaleBuilder("deDE", function() return { ["Frame inset (px)"] = "Rahmeninnenabstand (px)" } end)
RegisterLocaleBuilder("itIT", function() return { ["Frame inset (px)"] = "Margine della cornice (px)" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Frame inset (px)"] = "Margem da moldura (px)" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Frame inset (px)"] = "Отступ рамки (пкс)" } end)
RegisterLocaleBuilder("koKR", function() return { ["Frame inset (px)"] = "프레임 안쪽 여백 (px)" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Frame inset (px)"] = "边框内边距（像素）" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Frame inset (px)"] = "邊框內距（像素）" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("frFR", function() return { ["Portrait ring glint"] = "Éclat de l’anneau du portrait", ["Ability reveal shine"] = "Reflet à l’apparition des capacités", ["Milestone anticipation"] = "Anticipation des niveaux jalons", ["Stat impact sparks"] = "Étincelles des gains de statistiques", ["Background depth"] = "Profondeur de l’arrière-plan", ["Closing animation"] = "Animation de fermeture", ["Milestone color transition"] = "Transition de couleur des niveaux jalons" } end)
RegisterLocaleBuilder("esES", function() return { ["Portrait ring glint"] = "Destello del anillo del retrato", ["Ability reveal shine"] = "Brillo al aparecer habilidades", ["Milestone anticipation"] = "Anticipación de hitos", ["Stat impact sparks"] = "Chispas de mejora de estadísticas", ["Background depth"] = "Profundidad del fondo", ["Closing animation"] = "Animación de cierre", ["Milestone color transition"] = "Transición de color de hitos" } end)
RegisterLocaleBuilder("deDE", function() return { ["Portrait ring glint"] = "Glanz am Porträtring", ["Ability reveal shine"] = "Glanz beim Erscheinen von Fähigkeiten", ["Milestone anticipation"] = "Meilenstein-Vorbereitung", ["Stat impact sparks"] = "Funken bei Attributsgewinnen", ["Background depth"] = "Hintergrundtiefe", ["Closing animation"] = "Schließanimation", ["Milestone color transition"] = "Meilenstein-Farbübergang" } end)
RegisterLocaleBuilder("itIT", function() return { ["Portrait ring glint"] = "Bagliore dell’anello del ritratto", ["Ability reveal shine"] = "Riflesso alla comparsa delle abilità", ["Milestone anticipation"] = "Anticipazione dei traguardi", ["Stat impact sparks"] = "Scintille dei miglioramenti", ["Background depth"] = "Profondità dello sfondo", ["Closing animation"] = "Animazione di chiusura", ["Milestone color transition"] = "Transizione colore dei traguardi" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Portrait ring glint"] = "Brilho do anel do retrato", ["Ability reveal shine"] = "Brilho ao revelar habilidades", ["Milestone anticipation"] = "Antecipação de marcos", ["Stat impact sparks"] = "Faíscas de ganho de atributos", ["Background depth"] = "Profundidade do fundo", ["Closing animation"] = "Animação de fechamento", ["Milestone color transition"] = "Transição de cor dos marcos" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Portrait ring glint"] = "Блик на кольце портрета", ["Ability reveal shine"] = "Блик при появлении способностей", ["Milestone anticipation"] = "Подготовка юбилейного эффекта", ["Stat impact sparks"] = "Искры прироста характеристик", ["Background depth"] = "Глубина фона", ["Closing animation"] = "Анимация закрытия", ["Milestone color transition"] = "Смена цвета юбилейного эффекта" } end)
RegisterLocaleBuilder("koKR", function() return { ["Portrait ring glint"] = "초상화 테두리 반짝임", ["Ability reveal shine"] = "능력 등장 광택", ["Milestone anticipation"] = "주요 레벨 사전 효과", ["Stat impact sparks"] = "능력치 증가 불꽃", ["Background depth"] = "배경 깊이", ["Closing animation"] = "닫기 애니메이션", ["Milestone color transition"] = "주요 레벨 색상 전환" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Portrait ring glint"] = "头像边框闪光", ["Ability reveal shine"] = "技能出现光泽", ["Milestone anticipation"] = "里程碑预备效果", ["Stat impact sparks"] = "属性提升火花", ["Background depth"] = "背景纵深", ["Closing animation"] = "关闭动画", ["Milestone color transition"] = "里程碑颜色过渡" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Portrait ring glint"] = "頭像邊框閃光", ["Ability reveal shine"] = "技能出現光澤", ["Milestone anticipation"] = "里程碑預備效果", ["Stat impact sparks"] = "屬性提升火花", ["Background depth"] = "背景縱深", ["Closing animation"] = "關閉動畫", ["Milestone color transition"] = "里程碑顏色過渡" } end)
RegisterLocaleBuilder("esMX", function() return { ["Portrait ring glint"] = "Destello del anillo del retrato", ["Ability reveal shine"] = "Brillo al aparecer habilidades", ["Milestone anticipation"] = "Anticipación de hitos", ["Stat impact sparks"] = "Chispas de mejora de estadísticas", ["Background depth"] = "Profundidad del fondo", ["Closing animation"] = "Animación de cierre", ["Milestone color transition"] = "Transición de color de hitos" } end)

RegisterLocaleBuilder("frFR", function() return { ["Screenshot milestones"] = "Capturer les niveaux de palier" } end)
RegisterLocaleBuilder("deDE", function() return { ["Screenshot milestones"] = "Screenshots bei Meilensteinen" } end)
RegisterLocaleBuilder("esES", function() return { ["Screenshot milestones"] = "Capturas de pantalla en hitos" } end)
RegisterLocaleBuilder("esMX", function() return { ["Screenshot milestones"] = "Capturas de pantalla en hitos" } end)
RegisterLocaleBuilder("itIT", function() return { ["Screenshot milestones"] = "Screenshot ai traguardi" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Screenshot milestones"] = "Capturas de tela nos marcos" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Screenshot milestones"] = "Скриншоты на юбилейных уровнях" } end)
RegisterLocaleBuilder("koKR", function() return { ["Screenshot milestones"] = "주요 레벨 스크린샷" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Screenshot milestones"] = "里程碑等级截图" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Screenshot milestones"] = "里程碑等級截圖" } end)

RegisterLocaleBuilder("frFR", function() return { ["Portrait motes"] = "Particules du portrait", ["Background motes"] = "Particules d’arrière-plan" } end)
RegisterLocaleBuilder("deDE", function() return { ["Portrait motes"] = "Porträtpartikel", ["Background motes"] = "Hintergrundpartikel" } end)
RegisterLocaleBuilder("esES", function() return { ["Portrait motes"] = "Partículas del retrato", ["Background motes"] = "Partículas de fondo" } end)
RegisterLocaleBuilder("esMX", function() return { ["Portrait motes"] = "Partículas del retrato", ["Background motes"] = "Partículas de fondo" } end)
RegisterLocaleBuilder("itIT", function() return { ["Portrait motes"] = "Particelle del ritratto", ["Background motes"] = "Particelle di sfondo" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Portrait motes"] = "Partículas do retrato", ["Background motes"] = "Partículas de fundo" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Portrait motes"] = "Частицы портрета", ["Background motes"] = "Фоновые частицы" } end)
RegisterLocaleBuilder("koKR", function() return { ["Portrait motes"] = "초상화 입자", ["Background motes"] = "배경 입자" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Portrait motes"] = "头像微粒", ["Background motes"] = "背景微粒" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Portrait motes"] = "頭像微粒", ["Background motes"] = "背景微粒" } end)

RegisterLocaleBuilder("frFR", function() return { ["3D Portraits may consume more memory."] = "Les portraits 3D peuvent utiliser davantage de mémoire." } end)
RegisterLocaleBuilder("esES", function() return { ["3D Portraits may consume more memory."] = "Los retratos 3D pueden consumir más memoria." } end)
RegisterLocaleBuilder("esMX", function() return { ["3D Portraits may consume more memory."] = "Los retratos 3D pueden consumir más memoria." } end)
RegisterLocaleBuilder("deDE", function() return { ["3D Portraits may consume more memory."] = "3D-Porträts können mehr Arbeitsspeicher verbrauchen." } end)
RegisterLocaleBuilder("itIT", function() return { ["3D Portraits may consume more memory."] = "I ritratti 3D possono consumare più memoria." } end)
RegisterLocaleBuilder("ptBR", function() return { ["3D Portraits may consume more memory."] = "Retratos 3D podem consumir mais memória." } end)
RegisterLocaleBuilder("ruRU", function() return { ["3D Portraits may consume more memory."] = "3D-портреты могут потреблять больше памяти." } end)
RegisterLocaleBuilder("koKR", function() return { ["3D Portraits may consume more memory."] = "3D 초상화는 메모리를 더 사용할 수 있습니다." } end)
RegisterLocaleBuilder("zhCN", function() return { ["3D Portraits may consume more memory."] = "3D头像可能占用更多内存。" } end)
RegisterLocaleBuilder("zhTW", function() return { ["3D Portraits may consume more memory."] = "3D頭像可能佔用更多記憶體。" } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("frFR", function() return {
    ["Shorten stat totals"] = "Abréger les totaux des caractéristiques",
    ["Relevant stats only"] = "Caractéristiques pertinentes uniquement",
    ["%sk"] = "%sk", ["%sm"] = "%sM", ["%sb"] = "%sMd",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Shorten stat totals"] = "Abreviar los totales de estadísticas",
    ["Relevant stats only"] = "Solo estadísticas relevantes",
    ["%sk"] = "%sk", ["%sm"] = "%sM", ["%sb"] = "%s mil M",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Shorten stat totals"] = "Abreviar los totales de estadísticas",
    ["Relevant stats only"] = "Solo estadísticas relevantes",
    ["%sk"] = "%sk", ["%sm"] = "%sM", ["%sb"] = "%s mil M",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Shorten stat totals"] = "Attributsummen abkürzen",
    ["Relevant stats only"] = "Nur relevante Attribute",
    ["%sk"] = "%s Tsd.", ["%sm"] = "%s Mio.", ["%sb"] = "%s Mrd.",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Shorten stat totals"] = "Abbrevia i totali delle statistiche",
    ["Relevant stats only"] = "Solo statistiche rilevanti",
    ["%sk"] = "%sk", ["%sm"] = "%sM", ["%sb"] = "%s mld",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Shorten stat totals"] = "Abreviar totais de atributos",
    ["Relevant stats only"] = "Apenas atributos relevantes",
    ["%sk"] = "%s mil", ["%sm"] = "%s mi", ["%sb"] = "%s bi",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Shorten stat totals"] = "Сокращать значения характеристик",
    ["Relevant stats only"] = "Только актуальные характеристики",
    ["%sk"] = "%s тыс.", ["%sm"] = "%s млн", ["%sb"] = "%s млрд",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Shorten stat totals"] = "능력치 총합 줄여 표시",
    ["Relevant stats only"] = "관련 능력치만 표시",
    ["%sk"] = "%s천", ["%sm"] = "%s백만", ["%sb"] = "%s십억",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Shorten stat totals"] = "缩写属性总值",
    ["Relevant stats only"] = "仅显示相关属性",
    ["%sk"] = "%s千", ["%sm"] = "%s百万", ["%sb"] = "%s十亿",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Shorten stat totals"] = "縮寫屬性總值",
    ["Relevant stats only"] = "僅顯示相關屬性",
    ["%sk"] = "%s千", ["%sm"] = "%s百萬", ["%sb"] = "%s十億",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("frFR", function() return { ["Uses game volume"] = "Utilise le volume du jeu" } end)
RegisterLocaleBuilder("esES", function() return { ["Uses game volume"] = "Usa el volumen del juego" } end)
RegisterLocaleBuilder("esMX", function() return { ["Uses game volume"] = "Usa el volumen del juego" } end)
RegisterLocaleBuilder("deDE", function() return { ["Uses game volume"] = "Verwendet die Spiellautstärke" } end)
RegisterLocaleBuilder("itIT", function() return { ["Uses game volume"] = "Usa il volume del gioco" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Uses game volume"] = "Usa o volume do jogo" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Uses game volume"] = "Используется громкость игры" } end)
RegisterLocaleBuilder("koKR", function() return { ["Uses game volume"] = "게임 음량 사용" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Uses game volume"] = "使用游戏音量" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Uses game volume"] = "使用遊戲音量" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("frFR", function() return {
    ["Show faster leveling times"] = "Afficher les nouveaux records de montée en niveau",
    ["Fastest level: %s"] = "Nouveau record : %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Show faster leveling times"] = "Mostrar nuevos récords al subir de nivel",
    ["Fastest level: %s"] = "Nuevo récord: %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Show faster leveling times"] = "Mostrar nuevos récords al subir de nivel",
    ["Fastest level: %s"] = "Nuevo récord: %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Show faster leveling times"] = "Neue Rekordzeiten beim Stufenaufstieg anzeigen",
    ["Fastest level: %s"] = "Neue Bestzeit: %s",
    ["%dh %02dm %02ds"] = "%dStd. %02dMin. %02dSek.", ["%dm %02ds"] = "%dMin. %02dSek.", ["%ds"] = "%dSek.",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Show faster leveling times"] = "Mostra i nuovi record di avanzamento di livello",
    ["Fastest level: %s"] = "Nuovo record: %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Show faster leveling times"] = "Mostrar novos recordes ao subir de nível",
    ["Fastest level: %s"] = "Novo recorde: %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Show faster leveling times"] = "Показывать новые рекорды получения уровня",
    ["Fastest level: %s"] = "Новый рекорд: %s",
    ["%dh %02dm %02ds"] = "%dч %02dмин %02dс", ["%dm %02ds"] = "%dмин %02dс", ["%ds"] = "%dс",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Show faster leveling times"] = "레벨업 최고 기록 표시",
    ["Fastest level: %s"] = "새 최고 기록: %s",
    ["%dh %02dm %02ds"] = "%d시간 %02d분 %02d초", ["%dm %02ds"] = "%d분 %02d초", ["%ds"] = "%d초",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Show faster leveling times"] = "显示升级用时新纪录",
    ["Fastest level: %s"] = "升级新纪录：%s",
    ["%dh %02dm %02ds"] = "%d小时%02d分%02d秒", ["%dm %02ds"] = "%d分%02d秒", ["%ds"] = "%d秒",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Show faster leveling times"] = "顯示升級用時新紀錄",
    ["Fastest level: %s"] = "升級新紀錄：%s",
    ["%dh %02dm %02ds"] = "%d小時%02d分%02d秒", ["%dm %02ds"] = "%d分%02d秒", ["%ds"] = "%d秒",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("frFR", function() return {
    ["Max Level Celebration"] = "Célébration du niveau maximum",
    ["Time to max level: %s"] = "Temps jusqu’au niveau maximum : %s",
    ["%dd %02dh %02dm %02ds"] = "%dj %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Son de l’impact du portrait",
    ["Starburst sound"] = "Son de l’éclat du portrait",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Max Level Celebration"] = "Celebración del nivel máximo",
    ["Time to max level: %s"] = "Tiempo hasta el nivel máximo: %s",
    ["%dd %02dh %02dm %02ds"] = "%dd %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Sonido del impacto del retrato",
    ["Starburst sound"] = "Sonido del destello del retrato",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Max Level Celebration"] = "Celebración del nivel máximo",
    ["Time to max level: %s"] = "Tiempo hasta el nivel máximo: %s",
    ["%dd %02dh %02dm %02ds"] = "%dd %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Sonido del impacto del retrato",
    ["Starburst sound"] = "Sonido del destello del retrato",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Max Level Celebration"] = "Feier der Maximalstufe",
    ["Time to max level: %s"] = "Zeit bis zur Höchststufe: %s",
    ["%dd %02dh %02dm %02ds"] = "%dT. %02dStd. %02dMin. %02dSek.",
    ["Portrait impact sound"] = "Sound des Porträtimpulses",
    ["Starburst sound"] = "Sound des Sternenleuchtens",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Max Level Celebration"] = "Celebrazione del livello massimo",
    ["Time to max level: %s"] = "Tempo per il livello massimo: %s",
    ["%dd %02dh %02dm %02ds"] = "%dg %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Suono dell’impatto del ritratto",
    ["Starburst sound"] = "Suono del bagliore del ritratto",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Max Level Celebration"] = "Celebração do nível máximo",
    ["Time to max level: %s"] = "Tempo até o nível máximo: %s",
    ["%dd %02dh %02dm %02ds"] = "%dd %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Som do impacto do retrato",
    ["Starburst sound"] = "Som do clarão do retrato",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Max Level Celebration"] = "Празднование максимального уровня",
    ["Time to max level: %s"] = "Время до максимального уровня: %s",
    ["%dd %02dh %02dm %02ds"] = "%dд %02dч %02dмин %02dс",
    ["Portrait impact sound"] = "Звук импульса портрета",
    ["Starburst sound"] = "Звук звёздной вспышки",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Max Level Celebration"] = "최고 레벨 축하",
    ["Time to max level: %s"] = "최고 레벨까지 걸린 시간: %s",
    ["%dd %02dh %02dm %02ds"] = "%d일 %02d시간 %02d분 %02d초",
    ["Portrait impact sound"] = "초상화 충격 효과음",
    ["Starburst sound"] = "별빛 폭발 효과음",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Max Level Celebration"] = "满级庆祝",
    ["Time to max level: %s"] = "升至满级用时：%s",
    ["%dd %02dh %02dm %02ds"] = "%d天%02d小时%02d分%02d秒",
    ["Portrait impact sound"] = "头像冲击音效",
    ["Starburst sound"] = "星芒爆发音效",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Max Level Celebration"] = "滿級慶祝",
    ["Time to max level: %s"] = "升至滿級用時：%s",
    ["%dd %02dh %02dm %02ds"] = "%d天%02d小時%02d分%02d秒",
    ["Portrait impact sound"] = "頭像衝擊音效",
    ["Starburst sound"] = "星芒爆發音效",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("frFR", function() return {
    ["Time to Level: %s"] = "Temps pour monter de niveau : %s",
    ["New fastest time!:"] = "Nouveau meilleur temps ! :",
    ["New fastest time!: %s"] = "Nouveau meilleur temps ! : %s",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Time to Level: %s"] = "Tiempo para subir de nivel: %s",
    ["New fastest time!:"] = "¡Nuevo mejor tiempo!:",
    ["New fastest time!: %s"] = "¡Nuevo mejor tiempo!: %s",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Time to Level: %s"] = "Tiempo para subir de nivel: %s",
    ["New fastest time!:"] = "¡Nuevo mejor tiempo!:",
    ["New fastest time!: %s"] = "¡Nuevo mejor tiempo!: %s",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Time to Level: %s"] = "Zeit bis zum Stufenaufstieg: %s",
    ["New fastest time!:"] = "Neue Bestzeit!:",
    ["New fastest time!: %s"] = "Neue Bestzeit!: %s",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Time to Level: %s"] = "Tempo per salire di livello: %s",
    ["New fastest time!:"] = "Nuovo miglior tempo!:",
    ["New fastest time!: %s"] = "Nuovo miglior tempo!: %s",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Time to Level: %s"] = "Tempo para subir de nível: %s",
    ["New fastest time!:"] = "Novo melhor tempo!:",
    ["New fastest time!: %s"] = "Novo melhor tempo!: %s",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Time to Level: %s"] = "Время до уровня: %s",
    ["New fastest time!:"] = "Новое лучшее время!:",
    ["New fastest time!: %s"] = "Новое лучшее время!: %s",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Time to Level: %s"] = "레벨업 소요 시간: %s",
    ["New fastest time!:"] = "새로운 최단 시간!:",
    ["New fastest time!: %s"] = "새로운 최단 시간!: %s",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Time to Level: %s"] = "升级用时：%s",
    ["New fastest time!:"] = "新的最快用时！：",
    ["New fastest time!: %s"] = "新的最快用时！：%s",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Time to Level: %s"] = "升級用時：%s",
    ["New fastest time!:"] = "新的最快用時！：",
    ["New fastest time!: %s"] = "新的最快用時！：%s",
} end)

RegisterLocaleBuilder("frFR", function() return {
    ["Glint finishing spark"] = "Étincelle finale du reflet",
    ["Portrait shine"] = "Reflet du portrait",
    ["Ring surges"] = "Décharges de l’anneau",
    ["Max-level portrait sparks"] = "Étincelles du portrait au niveau maximum",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Glint finishing spark"] = "Chispa final del destello",
    ["Portrait shine"] = "Brillo del retrato",
    ["Ring surges"] = "Descargas del anillo",
    ["Max-level portrait sparks"] = "Chispas del retrato al nivel máximo",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Glint finishing spark"] = "Chispa final del destello",
    ["Portrait shine"] = "Brillo del retrato",
    ["Ring surges"] = "Descargas del anillo",
    ["Max-level portrait sparks"] = "Chispas del retrato al nivel máximo",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Glint finishing spark"] = "Abschließender Glanzfunke",
    ["Portrait shine"] = "Porträtglanz",
    ["Ring surges"] = "Ringentladungen",
    ["Max-level portrait sparks"] = "Porträtfunken auf Maximalstufe",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Glint finishing spark"] = "Scintilla finale del riflesso",
    ["Portrait shine"] = "Bagliore del ritratto",
    ["Ring surges"] = "Scariche dell’anello",
    ["Max-level portrait sparks"] = "Scintille del ritratto al livello massimo",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Glint finishing spark"] = "Faísca final do reflexo",
    ["Portrait shine"] = "Brilho do retrato",
    ["Ring surges"] = "Descargas do anel",
    ["Max-level portrait sparks"] = "Faíscas do retrato no nível máximo",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Glint finishing spark"] = "Завершающая искра блика",
    ["Portrait shine"] = "Сияние портрета",
    ["Ring surges"] = "Разряды кольца",
    ["Max-level portrait sparks"] = "Искры портрета на максимальном уровне",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Glint finishing spark"] = "반짝임 마무리 불꽃",
    ["Portrait shine"] = "초상화 광택",
    ["Ring surges"] = "테두리 전기 방전",
    ["Max-level portrait sparks"] = "최고 레벨 초상화 불꽃",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Glint finishing spark"] = "闪光结束火花",
    ["Portrait shine"] = "头像流光",
    ["Ring surges"] = "圆环电涌",
    ["Max-level portrait sparks"] = "满级头像火花",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Glint finishing spark"] = "閃光結束火花",
    ["Portrait shine"] = "頭像流光",
    ["Ring surges"] = "圓環電湧",
    ["Max-level portrait sparks"] = "滿級頭像火花",
} end)

RegisterLocaleBuilder("frFR", function() return {
    ["New Best Time!"] = "Nouveau meilleur temps !",
    ["Fastest Time: %s"] = "Meilleur temps : %s",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["New Best Time!"] = "¡Nuevo mejor tiempo!",
    ["Fastest Time: %s"] = "Mejor tiempo: %s",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["New Best Time!"] = "¡Nuevo mejor tiempo!",
    ["Fastest Time: %s"] = "Mejor tiempo: %s",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["New Best Time!"] = "Neue Bestzeit!",
    ["Fastest Time: %s"] = "Bestzeit: %s",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["New Best Time!"] = "Nuovo miglior tempo!",
    ["Fastest Time: %s"] = "Miglior tempo: %s",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["New Best Time!"] = "Novo melhor tempo!",
    ["Fastest Time: %s"] = "Melhor tempo: %s",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["New Best Time!"] = "Новое лучшее время!",
    ["Fastest Time: %s"] = "Лучшее время: %s",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["New Best Time!"] = "새로운 최단 시간!",
    ["Fastest Time: %s"] = "최단 시간: %s",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["New Best Time!"] = "新的最佳用时！",
    ["Fastest Time: %s"] = "最佳用时：%s",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["New Best Time!"] = "新的最佳用時！",
    ["Fastest Time: %s"] = "最佳用時：%s",
} end)

RegisterLocaleBuilder("frFR", function() return {
    ["Abbreviate stat names"] = "Abréger les noms des caractéristiques",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Abbreviate stat names"] = "Abreviar nombres de estadísticas",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Abbreviate stat names"] = "Abreviar nombres de estadísticas",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Abbreviate stat names"] = "Attributnamen abkürzen",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Abbreviate stat names"] = "Abbrevia i nomi delle statistiche",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Abbreviate stat names"] = "Abreviar nomes dos atributos",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Abbreviate stat names"] = "Сокращать названия характеристик",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Abbreviate stat names"] = "능력치 이름 줄이기",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Abbreviate stat names"] = "缩写属性名称",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Abbreviate stat names"] = "縮寫屬性名稱",
} end)

RegisterLocaleBuilder("frFR", function() return {
    ["%sM %sk"] = "%sM %sk",
    ["Recorded level timers and best times reset for this character."] = "Minuteurs de niveau et meilleurs temps enregistrés réinitialisés pour ce personnage.",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["%sM %sk"] = "%sM %sk",
    ["Recorded level timers and best times reset for this character."] = "Se han restablecido los tiempos de nivel y récords guardados de este personaje.",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["%sM %sk"] = "%sM %sk",
    ["Recorded level timers and best times reset for this character."] = "Se han restablecido los tiempos de nivel y récords guardados de este personaje.",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["%sM %sk"] = "%s Mio. %s Tsd.",
    ["Recorded level timers and best times reset for this character."] = "Gespeicherte Stufenzeiten und Bestzeiten dieses Charakters wurden zurückgesetzt.",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["%sM %sk"] = "%sM %sk",
    ["Recorded level timers and best times reset for this character."] = "Tempi di livello e record salvati di questo personaggio azzerati.",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["%sM %sk"] = "%s mi %s mil",
    ["Recorded level timers and best times reset for this character."] = "Tempos de nível e recordes salvos deste personagem foram redefinidos.",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["%sM %sk"] = "%s млн %s тыс.",
    ["Recorded level timers and best times reset for this character."] = "Сохранённые времена уровней и рекорды этого персонажа сброшены.",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["%sM %sk"] = "%s백만 %s천",
    ["Recorded level timers and best times reset for this character."] = "이 캐릭터의 저장된 레벨 시간과 최단 시간이 초기화되었습니다.",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["%sM %sk"] = "%s百万 %s千",
    ["Recorded level timers and best times reset for this character."] = "已重置此角色记录的升级计时和最佳用时。",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["%sM %sk"] = "%s百萬 %s千",
    ["Recorded level timers and best times reset for this character."] = "已重設此角色記錄的升級計時和最佳用時。",
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
RegisterLocaleBuilder("esES", function() return {
    ["Classic Mode"] = "Modo clásico",
    ["Choose the language used by GLU."] = "Elige el idioma de GLU.",
    ["Choose the popup background and frame style."] = "Elige el fondo y el marco de la ventana.",
    ["Arrange portrait, stats and abilities side by side."] = "Coloca el retrato, las estadísticas y las habilidades lado a lado.",
    ["Choose the artwork shown in the portrait ring."] = "Elige la imagen del retrato.",
    ["Show the level timer and celebrate new best times."] = "Muestra el tiempo del nivel y celebra nuevos récords.",
    ["Use a smaller vertical popup with less empty space."] = "Usa una ventana vertical más compacta.",
    ["Show Hunter pet skills and Warlock pet training."] = "Muestra habilidades de mascotas de cazador y brujo.",
    ["No decorative animations, similar to earlier GLU releases."] = "Sin animaciones decorativas, similar a las versiones anteriores de GLU.",
    ["Close the popup by right-clicking it."] = "Cierra la ventana haciendo clic derecho.",
    ["Allow the popup to close while the pointer is over it."] = "Permite cerrar la ventana mientras el puntero está encima.",
    ["Use your class colour for popup accents and text."] = "Usa el color de clase para el texto y los adornos.",
    ["Choose the controller button symbols shown in hints."] = "Elige los símbolos de los botones del mando.",
    ["Show weapon training available to your character."] = "Muestra el entrenamiento de armas disponible.",
    ["Show the money required to learn abilities."] = "Muestra el coste de aprender habilidades.",
    ["Abbreviate large stat totals without changing gain counters."] = "Abrevia los totales grandes sin cambiar los incrementos.",
    ["Show only stats relevant to your current class and specialization."] = "Muestra solo las estadísticas relevantes para tu clase y especialización.",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Classic Mode"] = "Klassischer Modus",
    ["Choose the language used by GLU."] = "Wähle die Sprache für GLU.",
    ["Choose the popup background and frame style."] = "Wähle Hintergrund und Rahmen des Fensters.",
    ["Arrange portrait, stats and abilities side by side."] = "Ordne Porträt, Attribute und Fähigkeiten nebeneinander an.",
    ["Choose the artwork shown in the portrait ring."] = "Wähle das Bild im Porträtring.",
    ["Show the level timer and celebrate new best times."] = "Zeige die Stufenzeit und feiere neue Bestzeiten.",
    ["Use a smaller vertical popup with less empty space."] = "Verwende ein kompakteres vertikales Fenster.",
    ["Show Hunter pet skills and Warlock pet training."] = "Zeige Begleiterfähigkeiten von Jägern und Hexenmeistern.",
    ["No decorative animations, similar to earlier GLU releases."] = "Keine dekorativen Animationen, ähnlich wie in früheren GLU-Versionen.",
    ["Close the popup by right-clicking it."] = "Schließe das Fenster mit einem Rechtsklick.",
    ["Allow the popup to close while the pointer is over it."] = "Erlaube das Schließen, während der Mauszeiger darüber liegt.",
    ["Use your class colour for popup accents and text."] = "Verwende die Klassenfarbe für Text und Akzente.",
    ["Choose the controller button symbols shown in hints."] = "Wähle die Symbole für Controller-Tasten.",
    ["Show weapon training available to your character."] = "Zeige verfügbares Waffentraining.",
    ["Show the money required to learn abilities."] = "Zeige die Lernkosten von Fähigkeiten.",
    ["Abbreviate large stat totals without changing gain counters."] = "Kürze große Attributsummen ohne Änderung der Zuwächse.",
    ["Show only stats relevant to your current class and specialization."] = "Zeige nur für Klasse und Spezialisierung relevante Attribute.",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Classic Mode"] = "Modalità classica",
    ["Choose the language used by GLU."] = "Scegli la lingua di GLU.",
    ["Choose the popup background and frame style."] = "Scegli lo sfondo e la cornice della finestra.",
    ["Arrange portrait, stats and abilities side by side."] = "Disponi ritratto, statistiche e abilità fianco a fianco.",
    ["Choose the artwork shown in the portrait ring."] = "Scegli l’immagine nel ritratto.",
    ["Show the level timer and celebrate new best times."] = "Mostra il tempo del livello e celebra i nuovi record.",
    ["Use a smaller vertical popup with less empty space."] = "Usa una finestra verticale più compatta.",
    ["Show Hunter pet skills and Warlock pet training."] = "Mostra le abilità dei famigli di cacciatore e stregone.",
    ["No decorative animations, similar to earlier GLU releases."] = "Nessuna animazione decorativa, come nelle versioni precedenti di GLU.",
    ["Close the popup by right-clicking it."] = "Chiudi la finestra con un clic destro.",
    ["Allow the popup to close while the pointer is over it."] = "Consenti la chiusura con il puntatore sulla finestra.",
    ["Use your class colour for popup accents and text."] = "Usa il colore di classe per testo e decorazioni.",
    ["Choose the controller button symbols shown in hints."] = "Scegli i simboli dei pulsanti del controller.",
    ["Show weapon training available to your character."] = "Mostra l’addestramento alle armi disponibile.",
    ["Show the money required to learn abilities."] = "Mostra il costo di apprendimento delle abilità.",
    ["Abbreviate large stat totals without changing gain counters."] = "Abbrevia i totali elevati senza cambiare gli incrementi.",
    ["Show only stats relevant to your current class and specialization."] = "Mostra solo le statistiche utili alla classe e specializzazione.",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Classic Mode"] = "Modo clássico",
    ["Choose the language used by GLU."] = "Escolha o idioma do GLU.",
    ["Choose the popup background and frame style."] = "Escolha o fundo e a moldura da janela.",
    ["Arrange portrait, stats and abilities side by side."] = "Organize retrato, atributos e habilidades lado a lado.",
    ["Choose the artwork shown in the portrait ring."] = "Escolha a imagem no retrato.",
    ["Show the level timer and celebrate new best times."] = "Mostre o tempo do nível e celebre novos recordes.",
    ["Use a smaller vertical popup with less empty space."] = "Use uma janela vertical mais compacta.",
    ["Show Hunter pet skills and Warlock pet training."] = "Mostre habilidades de ajudantes de caçador e bruxo.",
    ["No decorative animations, similar to earlier GLU releases."] = "Sem animações decorativas, semelhante às versões anteriores do GLU.",
    ["Close the popup by right-clicking it."] = "Feche a janela com o botão direito.",
    ["Allow the popup to close while the pointer is over it."] = "Permita fechar a janela com o ponteiro sobre ela.",
    ["Use your class colour for popup accents and text."] = "Use a cor da classe no texto e nos detalhes.",
    ["Choose the controller button symbols shown in hints."] = "Escolha os símbolos dos botões do controle.",
    ["Show weapon training available to your character."] = "Mostre treinamentos de armas disponíveis.",
    ["Show the money required to learn abilities."] = "Mostre o custo para aprender habilidades.",
    ["Abbreviate large stat totals without changing gain counters."] = "Abrevie totais grandes sem alterar os ganhos.",
    ["Show only stats relevant to your current class and specialization."] = "Mostre apenas atributos relevantes para sua classe e especialização.",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Classic Mode"] = "Классический режим",
    ["Choose the language used by GLU."] = "Выберите язык GLU.",
    ["Choose the popup background and frame style."] = "Выберите фон и рамку окна.",
    ["Arrange portrait, stats and abilities side by side."] = "Расположите портрет, характеристики и способности рядом.",
    ["Choose the artwork shown in the portrait ring."] = "Выберите изображение портрета.",
    ["Show the level timer and celebrate new best times."] = "Показывайте время уровня и отмечайте новые рекорды.",
    ["Use a smaller vertical popup with less empty space."] = "Используйте более компактное вертикальное окно.",
    ["Show Hunter pet skills and Warlock pet training."] = "Показывайте способности питомцев охотника и чернокнижника.",
    ["No decorative animations, similar to earlier GLU releases."] = "Без декоративных анимаций, как в ранних версиях GLU.",
    ["Close the popup by right-clicking it."] = "Закрывайте окно правой кнопкой мыши.",
    ["Allow the popup to close while the pointer is over it."] = "Разрешите закрытие окна под указателем мыши.",
    ["Use your class colour for popup accents and text."] = "Используйте цвет класса для текста и оформления.",
    ["Choose the controller button symbols shown in hints."] = "Выберите символы кнопок контроллера.",
    ["Show weapon training available to your character."] = "Показывайте доступное обучение владению оружием.",
    ["Show the money required to learn abilities."] = "Показывайте стоимость изучения способностей.",
    ["Abbreviate large stat totals without changing gain counters."] = "Сокращайте большие значения без изменения приростов.",
    ["Show only stats relevant to your current class and specialization."] = "Показывайте только характеристики для вашего класса и специализации.",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Classic Mode"] = "클래식 모드",
    ["Choose the language used by GLU."] = "GLU에서 사용할 언어를 선택합니다.",
    ["Choose the popup background and frame style."] = "팝업의 배경과 테두리를 선택합니다.",
    ["Arrange portrait, stats and abilities side by side."] = "초상화, 능력치와 능력을 나란히 배치합니다.",
    ["Choose the artwork shown in the portrait ring."] = "초상화 고리에 표시할 이미지를 선택합니다.",
    ["Show the level timer and celebrate new best times."] = "레벨 소요 시간을 표시하고 신기록을 축하합니다.",
    ["Use a smaller vertical popup with less empty space."] = "빈 공간이 적은 작은 세로 팝업을 사용합니다.",
    ["Show Hunter pet skills and Warlock pet training."] = "사냥꾼과 흑마법사 소환수의 능력을 표시합니다.",
    ["No decorative animations, similar to earlier GLU releases."] = "이전 GLU 버전처럼 장식 애니메이션을 사용하지 않습니다.",
    ["Close the popup by right-clicking it."] = "오른쪽 클릭으로 팝업을 닫습니다.",
    ["Allow the popup to close while the pointer is over it."] = "마우스를 올려 놓아도 팝업이 닫히도록 합니다.",
    ["Use your class colour for popup accents and text."] = "텍스트와 장식에 직업 색상을 사용합니다.",
    ["Choose the controller button symbols shown in hints."] = "힌트에 표시할 컨트롤러 버튼 기호를 선택합니다.",
    ["Show weapon training available to your character."] = "배울 수 있는 무기 숙련을 표시합니다.",
    ["Show the money required to learn abilities."] = "능력을 배우는 데 필요한 비용을 표시합니다.",
    ["Abbreviate large stat totals without changing gain counters."] = "증가량은 그대로 두고 큰 능력치 합계를 줄여 표시합니다.",
    ["Show only stats relevant to your current class and specialization."] = "현재 직업과 전문화에 필요한 능력치만 표시합니다.",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Classic Mode"] = "经典模式",
    ["Choose the language used by GLU."] = "选择GLU使用的语言。",
    ["Choose the popup background and frame style."] = "选择弹窗的背景与边框样式。",
    ["Arrange portrait, stats and abilities side by side."] = "将头像、属性和技能并排显示。",
    ["Choose the artwork shown in the portrait ring."] = "选择头像圆环内显示的图像。",
    ["Show the level timer and celebrate new best times."] = "显示本级用时并庆祝新纪录。",
    ["Use a smaller vertical popup with less empty space."] = "使用更紧凑的竖向弹窗。",
    ["Show Hunter pet skills and Warlock pet training."] = "显示猎人和术士宠物的技能训练。",
    ["No decorative animations, similar to earlier GLU releases."] = "无装饰动画，类似于早期的GLU版本。",
    ["Close the popup by right-clicking it."] = "右键点击弹窗将其关闭。",
    ["Allow the popup to close while the pointer is over it."] = "鼠标悬停时也允许弹窗关闭。",
    ["Use your class colour for popup accents and text."] = "使用职业颜色显示文字和装饰。",
    ["Choose the controller button symbols shown in hints."] = "选择提示中显示的手柄按键符号。",
    ["Show weapon training available to your character."] = "显示可学习的武器训练。",
    ["Show the money required to learn abilities."] = "显示学习技能所需的费用。",
    ["Abbreviate large stat totals without changing gain counters."] = "缩写较大的属性总值，保留原有增量。",
    ["Show only stats relevant to your current class and specialization."] = "仅显示当前职业和专精相关的属性。",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Classic Mode"] = "經典模式",
    ["Choose the language used by GLU."] = "選擇GLU使用的語言。",
    ["Choose the popup background and frame style."] = "選擇彈窗的背景與邊框樣式。",
    ["Arrange portrait, stats and abilities side by side."] = "將頭像、屬性和技能並排顯示。",
    ["Choose the artwork shown in the portrait ring."] = "選擇頭像圓環內顯示的圖像。",
    ["Show the level timer and celebrate new best times."] = "顯示本級用時並慶祝新紀錄。",
    ["Use a smaller vertical popup with less empty space."] = "使用更精簡的直向彈窗。",
    ["Show Hunter pet skills and Warlock pet training."] = "顯示獵人和術士寵物的技能訓練。",
    ["No decorative animations, similar to earlier GLU releases."] = "無裝飾動畫，類似於早期的GLU版本。",
    ["Close the popup by right-clicking it."] = "右鍵點擊彈窗將其關閉。",
    ["Allow the popup to close while the pointer is over it."] = "滑鼠停留時也允許彈窗關閉。",
    ["Use your class colour for popup accents and text."] = "使用職業顏色顯示文字和裝飾。",
    ["Choose the controller button symbols shown in hints."] = "選擇提示中顯示的控制器按鍵符號。",
    ["Show weapon training available to your character."] = "顯示可學習的武器訓練。",
    ["Show the money required to learn abilities."] = "顯示學習技能所需的費用。",
    ["Abbreviate large stat totals without changing gain counters."] = "縮寫較大的屬性總值，保留原有增量。",
    ["Show only stats relevant to your current class and specialization."] = "僅顯示目前職業和專精相關的屬性。",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Classic Mode"] = "Modo clásico",
    ["Choose the language used by GLU."] = "Elige el idioma de GLU.",
    ["Choose the popup background and frame style."] = "Elige el fondo y el marco de la ventana.",
    ["Arrange portrait, stats and abilities side by side."] = "Coloca el retrato, las estadísticas y las habilidades lado a lado.",
    ["Choose the artwork shown in the portrait ring."] = "Elige la imagen del retrato.",
    ["Show the level timer and celebrate new best times."] = "Muestra el tiempo del nivel y celebra nuevos récords.",
    ["Use a smaller vertical popup with less empty space."] = "Usa una ventana vertical más compacta.",
    ["Show Hunter pet skills and Warlock pet training."] = "Muestra habilidades de mascotas de cazador y brujo.",
    ["No decorative animations, similar to earlier GLU releases."] = "Sin animaciones decorativas, similar a las versiones anteriores de GLU.",
    ["Close the popup by right-clicking it."] = "Cierra la ventana haciendo clic derecho.",
    ["Allow the popup to close while the pointer is over it."] = "Permite cerrar la ventana mientras el puntero está encima.",
    ["Use your class colour for popup accents and text."] = "Usa el color de clase para el texto y los adornos.",
    ["Choose the controller button symbols shown in hints."] = "Elige los símbolos de los botones del mando.",
    ["Show weapon training available to your character."] = "Muestra el entrenamiento de armas disponible.",
    ["Show the money required to learn abilities."] = "Muestra el coste de aprender habilidades.",
    ["Abbreviate large stat totals without changing gain counters."] = "Abrevia los totales grandes sin cambiar los incrementos.",
    ["Show only stats relevant to your current class and specialization."] = "Muestra solo las estadísticas relevantes para tu clase y especialización.",
} end)


-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("frFR", function() return {
    ["Stat text size"] = "Taille du texte des caractéristiques",
    ["Heading text size"] = "Taille des titres",
    ["Time to Level text size"] = "Taille du texte du temps de niveau",
    ["Level %d - %d"] = "Niveaux %d - %d",
    ["Time for %d levels: %s"] = "Temps pour %d niveaux : %s",
} end)
RegisterLocaleBuilder("esES", function() return {
    ["Stat text size"] = "Tamaño del texto de estadísticas",
    ["Heading text size"] = "Tamaño de los encabezados",
    ["Time to Level text size"] = "Tamaño del texto de tiempo de nivel",
    ["Level %d - %d"] = "Niveles %d - %d",
    ["Time for %d levels: %s"] = "Tiempo para %d niveles: %s",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Stat text size"] = "Tamaño del texto de estadísticas",
    ["Heading text size"] = "Tamaño de los encabezados",
    ["Time to Level text size"] = "Tamaño del texto de tiempo de nivel",
    ["Level %d - %d"] = "Niveles %d - %d",
    ["Time for %d levels: %s"] = "Tiempo para %d niveles: %s",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Stat text size"] = "Attributtextgröße",
    ["Heading text size"] = "Überschriftengröße",
    ["Time to Level text size"] = "Textgröße der Stufenzeit",
    ["Level %d - %d"] = "Stufen %d - %d",
    ["Time for %d levels: %s"] = "Zeit für %d Stufen: %s",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Stat text size"] = "Dimensione del testo delle statistiche",
    ["Heading text size"] = "Dimensione dei titoli",
    ["Time to Level text size"] = "Dimensione del testo del tempo di livello",
    ["Level %d - %d"] = "Livelli %d - %d",
    ["Time for %d levels: %s"] = "Tempo per %d livelli: %s",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Stat text size"] = "Tamanho do texto dos atributos",
    ["Heading text size"] = "Tamanho dos títulos",
    ["Time to Level text size"] = "Tamanho do texto de tempo de nível",
    ["Level %d - %d"] = "Níveis %d - %d",
    ["Time for %d levels: %s"] = "Tempo para %d níveis: %s",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Stat text size"] = "Размер текста характеристик",
    ["Heading text size"] = "Размер заголовков",
    ["Time to Level text size"] = "Размер текста времени уровня",
    ["Level %d - %d"] = "Уровни %d - %d",
    ["Time for %d levels: %s"] = "Время за %d уровней: %s",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Stat text size"] = "능력치 글자 크기",
    ["Heading text size"] = "제목 글자 크기",
    ["Time to Level text size"] = "레벨 소요 시간 글자 크기",
    ["Level %d - %d"] = "레벨 %d - %d",
    ["Time for %d levels: %s"] = "%d레벨 소요 시간: %s",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Stat text size"] = "属性文字大小",
    ["Heading text size"] = "标题文字大小",
    ["Time to Level text size"] = "升级用时文字大小",
    ["Level %d - %d"] = "等级 %d - %d",
    ["Time for %d levels: %s"] = "%d级用时：%s",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Stat text size"] = "屬性文字大小",
    ["Heading text size"] = "標題文字大小",
    ["Time to Level text size"] = "升級用時文字大小",
    ["Level %d - %d"] = "等級 %d - %d",
    ["Time for %d levels: %s"] = "%d級用時：%s",
} end)

-- Provisional client language for widgets created during file loading. Core
-- selects the saved override at ADDON_LOADED, before constructing options.
ns.SetLocale("auto")

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
RegisterLocaleBuilder("esES", function() return {
    ["Show secondary stats"] = "Mostrar estadísticas secundarias",
    ["Secondary Stats"] = "Estadísticas secundarias",
    ["Replace primary stats with secondary stats halfway through the popup."] = "Sustituye las estadísticas principales por las secundarias a la mitad de la duración de la ventana.",
    ["Crit. Strike"] = "Golpe crítico",
    ["Haste"] = "Celeridad",
    ["Mastery"] = "Maestría",
    ["Versatility"] = "Versatilidad",
    ["Hit Chance"] = "Probabilidad de golpe",
    ["Expertise"] = "Pericia",
    ["Attack Power"] = "Poder de ataque",
    ["Ranged Attack Power"] = "Poder de ataque a distancia",
    ["Spell Power"] = "Poder con hechizos",
    ["Healing Power"] = "Poder de sanación",
    ["Armor"] = "Armadura",
    ["Defense"] = "Defensa",
    ["Dodge"] = "Esquivar",
    ["Parry"] = "Parar",
    ["Block"] = "Bloquear",
    ["Armor Penetration"] = "Penetración de armadura",
    ["Mana per 5 sec"] = "Maná cada 5 s",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Show secondary stats"] = "Sekundärwerte anzeigen",
    ["Secondary Stats"] = "Sekundärwerte",
    ["Replace primary stats with secondary stats halfway through the popup."] = "Ersetzt nach der Hälfte der Anzeigedauer die Hauptwerte durch Sekundärwerte.",
    ["Crit. Strike"] = "Kritischer Trefferwert",
    ["Haste"] = "Tempo",
    ["Mastery"] = "Meisterschaft",
    ["Versatility"] = "Vielseitigkeit",
    ["Hit Chance"] = "Trefferchance",
    ["Expertise"] = "Waffenkunde",
    ["Attack Power"] = "Angriffskraft",
    ["Ranged Attack Power"] = "Distanzangriffskraft",
    ["Spell Power"] = "Zaubermacht",
    ["Healing Power"] = "Heilmacht",
    ["Armor"] = "Rüstung",
    ["Defense"] = "Verteidigung",
    ["Dodge"] = "Ausweichen",
    ["Parry"] = "Parieren",
    ["Block"] = "Blocken",
    ["Armor Penetration"] = "Rüstungsdurchschlag",
    ["Mana per 5 sec"] = "Mana alle 5 Sek.",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Show secondary stats"] = "Mostra statistiche secondarie",
    ["Secondary Stats"] = "Statistiche secondarie",
    ["Replace primary stats with secondary stats halfway through the popup."] = "Sostituisce le statistiche primarie con quelle secondarie a metà della durata della finestra.",
    ["Crit. Strike"] = "Critico",
    ["Haste"] = "Celerità",
    ["Mastery"] = "Maestria",
    ["Versatility"] = "Versatilità",
    ["Hit Chance"] = "Probabilità di colpire",
    ["Expertise"] = "Perizia",
    ["Attack Power"] = "Potenza d’attacco",
    ["Ranged Attack Power"] = "Potenza d’attacco a distanza",
    ["Spell Power"] = "Potenza magica",
    ["Healing Power"] = "Potenza di cura",
    ["Armor"] = "Armatura",
    ["Defense"] = "Difesa",
    ["Dodge"] = "Schivata",
    ["Parry"] = "Parata",
    ["Block"] = "Blocco",
    ["Armor Penetration"] = "Penetrazione dell’armatura",
    ["Mana per 5 sec"] = "Mana ogni 5 s",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Show secondary stats"] = "Mostrar atributos secundários",
    ["Secondary Stats"] = "Atributos secundários",
    ["Replace primary stats with secondary stats halfway through the popup."] = "Substitui os atributos primários pelos secundários na metade da duração da janela.",
    ["Crit. Strike"] = "Acerto Crítico",
    ["Haste"] = "Aceleração",
    ["Mastery"] = "Maestria",
    ["Versatility"] = "Versatilidade",
    ["Hit Chance"] = "Chance de Acerto",
    ["Expertise"] = "Aptidão",
    ["Attack Power"] = "Poder de Ataque",
    ["Ranged Attack Power"] = "Poder de Ataque à Distância",
    ["Spell Power"] = "Poder Mágico",
    ["Healing Power"] = "Poder de Cura",
    ["Armor"] = "Armadura",
    ["Defense"] = "Defesa",
    ["Dodge"] = "Esquiva",
    ["Parry"] = "Aparo",
    ["Block"] = "Bloqueio",
    ["Armor Penetration"] = "Penetração de Armadura",
    ["Mana per 5 sec"] = "Mana a cada 5 s",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Show secondary stats"] = "Показывать вторичные характеристики",
    ["Secondary Stats"] = "Вторичные характеристики",
    ["Replace primary stats with secondary stats halfway through the popup."] = "Заменять основные характеристики вторичными в середине времени показа окна.",
    ["Crit. Strike"] = "Критический удар",
    ["Haste"] = "Скорость",
    ["Mastery"] = "Искусность",
    ["Versatility"] = "Универсальность",
    ["Hit Chance"] = "Вероятность попадания",
    ["Expertise"] = "Мастерство",
    ["Attack Power"] = "Сила атаки",
    ["Ranged Attack Power"] = "Сила атаки дальнего боя",
    ["Spell Power"] = "Сила заклинаний",
    ["Healing Power"] = "Сила исцеления",
    ["Armor"] = "Броня",
    ["Defense"] = "Защита",
    ["Dodge"] = "Уклонение",
    ["Parry"] = "Парирование",
    ["Block"] = "Блокирование",
    ["Armor Penetration"] = "Пробивание брони",
    ["Mana per 5 sec"] = "Мана за 5 сек.",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Show secondary stats"] = "보조 능력치 표시",
    ["Secondary Stats"] = "보조 능력치",
    ["Replace primary stats with secondary stats halfway through the popup."] = "팝업 표시 시간이 절반 지나면 주 능력치를 보조 능력치로 바꿉니다.",
    ["Crit. Strike"] = "치명타 및 극대화",
    ["Haste"] = "가속",
    ["Mastery"] = "특화",
    ["Versatility"] = "유연성",
    ["Hit Chance"] = "적중률",
    ["Expertise"] = "숙련",
    ["Attack Power"] = "전투력",
    ["Ranged Attack Power"] = "원거리 전투력",
    ["Spell Power"] = "주문력",
    ["Healing Power"] = "치유량",
    ["Armor"] = "방어도",
    ["Defense"] = "방어 숙련",
    ["Dodge"] = "회피",
    ["Parry"] = "무기 막기",
    ["Block"] = "방패 막기",
    ["Armor Penetration"] = "방어구 관통",
    ["Mana per 5 sec"] = "5초당 마나",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Show secondary stats"] = "显示次要属性",
    ["Secondary Stats"] = "次要属性",
    ["Replace primary stats with secondary stats halfway through the popup."] = "弹窗显示时间过半时，将主要属性替换为次要属性。",
    ["Crit. Strike"] = "爆击",
    ["Haste"] = "急速",
    ["Mastery"] = "精通",
    ["Versatility"] = "全能",
    ["Hit Chance"] = "命中几率",
    ["Expertise"] = "精准",
    ["Attack Power"] = "攻击强度",
    ["Ranged Attack Power"] = "远程攻击强度",
    ["Spell Power"] = "法术强度",
    ["Healing Power"] = "治疗强度",
    ["Armor"] = "护甲",
    ["Defense"] = "防御",
    ["Dodge"] = "躲闪",
    ["Parry"] = "招架",
    ["Block"] = "格挡",
    ["Armor Penetration"] = "护甲穿透",
    ["Mana per 5 sec"] = "每5秒恢复法力",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Show secondary stats"] = "顯示次要屬性",
    ["Secondary Stats"] = "次要屬性",
    ["Replace primary stats with secondary stats halfway through the popup."] = "彈出視窗顯示時間過半時，將主要屬性替換為次要屬性。",
    ["Crit. Strike"] = "致命一擊",
    ["Haste"] = "加速",
    ["Mastery"] = "精通",
    ["Versatility"] = "臨機應變",
    ["Hit Chance"] = "命中機率",
    ["Expertise"] = "熟練",
    ["Attack Power"] = "攻擊強度",
    ["Ranged Attack Power"] = "遠程攻擊強度",
    ["Spell Power"] = "法術能量",
    ["Healing Power"] = "治療能量",
    ["Armor"] = "護甲",
    ["Defense"] = "防禦",
    ["Dodge"] = "閃躲",
    ["Parry"] = "招架",
    ["Block"] = "格擋",
    ["Armor Penetration"] = "護甲穿透",
    ["Mana per 5 sec"] = "每5秒恢復法力",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Show secondary stats"] = "Mostrar estadísticas secundarias",
    ["Secondary Stats"] = "Estadísticas secundarias",
    ["Replace primary stats with secondary stats halfway through the popup."] = "Sustituye las estadísticas principales por las secundarias a la mitad de la duración de la ventana.",
    ["Crit. Strike"] = "Golpe crítico",
    ["Haste"] = "Celeridad",
    ["Mastery"] = "Maestría",
    ["Versatility"] = "Versatilidad",
    ["Hit Chance"] = "Probabilidad de golpe",
    ["Expertise"] = "Pericia",
    ["Attack Power"] = "Poder de ataque",
    ["Ranged Attack Power"] = "Poder de ataque a distancia",
    ["Spell Power"] = "Poder con hechizos",
    ["Healing Power"] = "Poder de sanación",
    ["Armor"] = "Armadura",
    ["Defense"] = "Defensa",
    ["Dodge"] = "Esquivar",
    ["Parry"] = "Parar",
    ["Block"] = "Bloquear",
    ["Armor Penetration"] = "Penetración de armadura",
    ["Mana per 5 sec"] = "Maná cada 5 s",
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
    ["Take a screenshot after a real milestone popup opens."] = "Prenez une capture après l’ouverture d’une véritable fenêtre de palier.",
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
RegisterLocaleBuilder("esES", function() return {
    ["Choose the artwork around the portrait."] = "Elige el diseño que rodea el retrato.",
    ["Choose artwork for textured themes."] = "Elige el diseño para los temas con texturas.",
    ["Stretch or tile the background artwork."] = "Estira o repite la textura del fondo.",
    ["Adjust how dark the background appears."] = "Ajusta la oscuridad del fondo.",
    ["Seconds the popup stays visible after its entrance."] = "Segundos que permanece visible tras la animación de entrada.",
    ["Resize the whole popup in the current layout."] = "Cambia el tamaño de toda la ventana en la disposición actual.",
    ["Resize this text while keeping long lines inside the frame."] = "Cambia el tamaño del texto manteniendo las líneas largas dentro del marco.",
    ["Prevent dragging the popup to a new position."] = "Impide arrastrar la ventana a otra posición.",
    ["Show a test popup without changing level history."] = "Muestra una prueba sin cambiar el historial de niveles.",
    ["Restore default appearance settings."] = "Restaura los ajustes de apariencia predeterminados.",
    ["Enable or disable the GLU level-up popup."] = "Activa o desactiva la ventana de subida de nivel de GLU.",
    ["Hide Blizzard's visual level-up notification."] = "Oculta el aviso visual de subida de nivel de Blizzard.",
    ["Delay the popup until combat ends."] = "Retrasa la ventana hasta que termine el combate.",
    ["Show the GLU shortcut on the minimap."] = "Muestra el acceso de GLU en el minimapa.",
    ["Let clicks pass through the popup to the game."] = "Permite que los clics atraviesen la ventana hacia el juego.",
    ["Choose how high this window sits above other interface elements."] = "Elige la prioridad de esta ventana sobre otros elementos de la interfaz.",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "Alinea nombres, totales, flechas y ganancias en columnas compartidas.",
    ["Use short stat labels, including secondary stats."] = "Usa nombres cortos, también para las estadísticas secundarias.",
    ["Take a screenshot after a real milestone popup opens."] = "Toma una captura al abrirse un aviso real de hito.",
    ["Save available training information when visiting trainers."] = "Guarda la formación disponible al visitar instructores.",
    ["Include profession training in trainer scans."] = "Incluye la formación de profesiones en los escaneos.",
    ["Show unlocks from the gained level instead of earlier levels."] = "Muestra las facultades del nivel alcanzado en lugar de niveles anteriores.",
    ["Hide rank upgrades and show only new abilities."] = "Oculta mejoras de rango y muestra solo facultades nuevas.",
    ["Include training abilities for your character's pet."] = "Incluye las facultades de entrenamiento de tu mascota.",
    ["Show grimoires for your currently summoned pet."] = "Muestra los grimorios de la mascota invocada actualmente.",
    ["Scroll long ability lists sideways instead of adding more rows."] = "Desplaza las listas largas lateralmente en lugar de añadir filas.",
    ["Play the selected replacement sound on level-up."] = "Reproduce el sonido de sustitución seleccionado al subir de nivel.",
    ["Silence Blizzard's ding when using a replacement sound."] = "Silencia el sonido de Blizzard al utilizar uno de sustitución.",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "Elige un sonido; Predeterminado conserva el sonido normal de Blizzard.",
    ["Choose which game audio channel plays GLU sounds."] = "Elige el canal de audio del juego para GLU.",
    ["Adjust GLU sound volume where the client supports it."] = "Ajusta el volumen de GLU si el cliente lo permite.",
    ["Preview the selected sound."] = "Escucha el sonido seleccionado.",
    ["Add celebration effects when crossing a ten-level milestone."] = "Añade efectos de celebración al cruzar un hito de diez niveles.",
    ["Add celebration effects when reaching the level cap."] = "Añade efectos al alcanzar el nivel máximo.",
    ["Play the portrait pulse and starburst during the entrance."] = "Anima el pulso y el destello del retrato durante la entrada.",
    ["Make newly learned ability icons shine."] = "Haz brillar los iconos de las facultades recién aprendidas.",
    ["Animate stat totals and highlight their changes."] = "Anima los totales y resalta sus cambios.",
    ["Show decorative particles around the portrait."] = "Muestra partículas decorativas alrededor del retrato.",
    ["Show drifting particles behind the popup content."] = "Muestra partículas flotantes detrás del contenido.",
    ["Animate a glow around textured frame edges."] = "Anima un resplandor en los bordes de los marcos con texturas.",
    ["Let the portrait ring settle into place during the entrance."] = "Deja que el anillo se asiente durante la entrada.",
    ["Animate the section divider lines."] = "Anima las líneas divisorias de las secciones.",
    ["Sweep a bright glint around the portrait ring."] = "Desplaza un reflejo brillante alrededor del anillo.",
    ["Choose the direction stat rows slide in from."] = "Elige la dirección de entrada de las filas de estadísticas.",
    ["Change animation speed without changing display duration."] = "Cambia la velocidad de animación sin cambiar la duración visible.",
    ["Add shadows and glow behind popup text."] = "Añade sombras y brillo detrás del texto.",
    ["Use a separate selected profile for this character."] = "Usa una selección de perfil independiente para este personaje.",
    ["Choose the settings profile to use."] = "Elige el perfil de ajustes que quieres usar.",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "Borra los datos escaneados; conserva las listas incluidas.",
    ["Restore default addon settings."] = "Restaura los ajustes predeterminados del addon.",
    ["Open controls to create, rename or delete profiles."] = "Abre los controles para crear, renombrar o borrar perfiles.",
    ["Reload the interface to apply pending changes."] = "Recarga la interfaz para aplicar los cambios pendientes.",
    ["Share settings by copying a profile code."] = "Comparte ajustes copiando un código de perfil.",
    ["Choose the font used by popup text."] = "Elige la fuente del texto de la ventana.",
    ["Pause a test popup's timeout only while Options is open."] = "Pausa el tiempo de la prueba solo mientras Opciones esté abierto.",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Choose the artwork around the portrait."] = "Wähle die Grafik um das Porträt.",
    ["Choose artwork for textured themes."] = "Wähle Grafiken für texturierte Designs.",
    ["Stretch or tile the background artwork."] = "Strecke oder kachle die Hintergrundgrafik.",
    ["Adjust how dark the background appears."] = "Passe die Dunkelheit des Hintergrunds an.",
    ["Seconds the popup stays visible after its entrance."] = "Anzeigedauer in Sekunden nach der Einblendung.",
    ["Resize the whole popup in the current layout."] = "Ändere die gesamte Fenstergröße im aktuellen Layout.",
    ["Resize this text while keeping long lines inside the frame."] = "Ändere die Textgröße; lange Zeilen bleiben im Rahmen.",
    ["Prevent dragging the popup to a new position."] = "Verhindere das Verschieben des Fensters.",
    ["Show a test popup without changing level history."] = "Zeige eine Vorschau ohne Änderung des Stufenverlaufs.",
    ["Restore default appearance settings."] = "Stelle die Standarddarstellung wieder her.",
    ["Enable or disable the GLU level-up popup."] = "Aktiviere oder deaktiviere die GLU-Stufenanzeige.",
    ["Hide Blizzard's visual level-up notification."] = "Blende Blizzards visuelle Stufenmeldung aus.",
    ["Delay the popup until combat ends."] = "Zeige das Fenster erst nach dem Kampf.",
    ["Show the GLU shortcut on the minimap."] = "Zeige die GLU-Schaltfläche an der Minikarte.",
    ["Let clicks pass through the popup to the game."] = "Lasse Klicks durch das Fenster zum Spiel gelangen.",
    ["Choose how high this window sits above other interface elements."] = "Wähle die Anzeigeebene über anderen Oberflächenelementen.",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "Richte Namen, Werte, Pfeile und Gewinne in gemeinsamen Spalten aus.",
    ["Use short stat labels, including secondary stats."] = "Verwende kurze Namen, auch für Sekundärwerte.",
    ["Take a screenshot after a real milestone popup opens."] = "Erstelle nach einer echten Meilensteinanzeige einen Screenshot.",
    ["Save available training information when visiting trainers."] = "Speichere verfügbare Ausbildung beim Lehrerbesuch.",
    ["Include profession training in trainer scans."] = "Berücksichtige Berufsausbildung beim Scannen.",
    ["Show unlocks from the gained level instead of earlier levels."] = "Zeige Freischaltungen der erreichten statt früherer Stufen.",
    ["Hide rank upgrades and show only new abilities."] = "Blende Rangverbesserungen aus und zeige nur neue Fähigkeiten.",
    ["Include training abilities for your character's pet."] = "Zeige die Ausbildungsmöglichkeiten deines Begleiters.",
    ["Show grimoires for your currently summoned pet."] = "Zeige Grimoires für den aktuell beschworenen Begleiter.",
    ["Scroll long ability lists sideways instead of adding more rows."] = "Scrolle lange Listen seitlich, statt weitere Zeilen hinzuzufügen.",
    ["Play the selected replacement sound on level-up."] = "Spiele beim Stufenaufstieg den gewählten Ersatzton.",
    ["Silence Blizzard's ding when using a replacement sound."] = "Schalte Blizzards Ton bei Verwendung eines Ersatztons stumm.",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "Wähle einen Ton; Standard lässt Blizzards Klang unverändert.",
    ["Choose which game audio channel plays GLU sounds."] = "Wähle den Spiel-Audiokanal für GLU.",
    ["Adjust GLU sound volume where the client supports it."] = "Passe die GLU-Lautstärke an, soweit der Client dies unterstützt.",
    ["Preview the selected sound."] = "Höre den gewählten Ton an.",
    ["Add celebration effects when crossing a ten-level milestone."] = "Feiere das Überschreiten eines Zehner-Meilensteins.",
    ["Add celebration effects when reaching the level cap."] = "Feiere das Erreichen der Maximalstufe.",
    ["Play the portrait pulse and starburst during the entrance."] = "Spiele Porträtpuls und Lichtausbruch beim Einblenden.",
    ["Make newly learned ability icons shine."] = "Lasse neu erlernte Fähigkeitensymbole glänzen.",
    ["Animate stat totals and highlight their changes."] = "Animiere Gesamtwerte und betone ihre Änderungen.",
    ["Show decorative particles around the portrait."] = "Zeige dekorative Partikel um das Porträt.",
    ["Show drifting particles behind the popup content."] = "Zeige schwebende Partikel hinter dem Inhalt.",
    ["Animate a glow around textured frame edges."] = "Animiere ein Leuchten an texturierten Rahmenkanten.",
    ["Let the portrait ring settle into place during the entrance."] = "Lasse den Porträtring beim Einblenden zur Ruhe kommen.",
    ["Animate the section divider lines."] = "Animiere die Abschnittstrennlinien.",
    ["Sweep a bright glint around the portrait ring."] = "Lasse einen hellen Glanz um den Porträtring laufen.",
    ["Choose the direction stat rows slide in from."] = "Wähle die Einflugrichtung der Wertezeilen.",
    ["Change animation speed without changing display duration."] = "Ändere die Animationsgeschwindigkeit ohne Änderung der Anzeigedauer.",
    ["Add shadows and glow behind popup text."] = "Füge Schatten und Leuchten hinter dem Text hinzu.",
    ["Use a separate selected profile for this character."] = "Verwende für diesen Charakter eine eigene Profilauswahl.",
    ["Choose the settings profile to use."] = "Wähle das verwendete Einstellungsprofil.",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "Lösche gescannte Lehrerdaten; integrierte Listen bleiben erhalten.",
    ["Restore default addon settings."] = "Stelle die Standardeinstellungen des Addons wieder her.",
    ["Open controls to create, rename or delete profiles."] = "Öffne die Verwaltung zum Erstellen, Umbenennen oder Löschen von Profilen.",
    ["Reload the interface to apply pending changes."] = "Lade die Oberfläche neu, um ausstehende Änderungen anzuwenden.",
    ["Share settings by copying a profile code."] = "Teile Einstellungen durch Kopieren eines Profilcodes.",
    ["Choose the font used by popup text."] = "Wähle die Schriftart der Fenstertexte.",
    ["Pause a test popup's timeout only while Options is open."] = "Pausiere die Vorschauzeit nur bei geöffneten Optionen.",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Choose the artwork around the portrait."] = "Scegli la grafica intorno al ritratto.",
    ["Choose artwork for textured themes."] = "Scegli la grafica dei temi con texture.",
    ["Stretch or tile the background artwork."] = "Estendi o ripeti la texture di sfondo.",
    ["Adjust how dark the background appears."] = "Regola quanto appare scuro lo sfondo.",
    ["Seconds the popup stays visible after its entrance."] = "Secondi di visibilità dopo l’animazione di entrata.",
    ["Resize the whole popup in the current layout."] = "Ridimensiona tutta la finestra nella disposizione attuale.",
    ["Resize this text while keeping long lines inside the frame."] = "Ridimensiona il testo mantenendo le righe lunghe nel riquadro.",
    ["Prevent dragging the popup to a new position."] = "Impedisci di trascinare la finestra altrove.",
    ["Show a test popup without changing level history."] = "Mostra una prova senza modificare la cronologia dei livelli.",
    ["Restore default appearance settings."] = "Ripristina le impostazioni grafiche predefinite.",
    ["Enable or disable the GLU level-up popup."] = "Attiva o disattiva la finestra di aumento di livello di GLU.",
    ["Hide Blizzard's visual level-up notification."] = "Nascondi l’avviso visivo di aumento di livello di Blizzard.",
    ["Delay the popup until combat ends."] = "Rimanda la finestra alla fine del combattimento.",
    ["Show the GLU shortcut on the minimap."] = "Mostra il collegamento GLU sulla minimappa.",
    ["Let clicks pass through the popup to the game."] = "Lascia passare i clic attraverso la finestra verso il gioco.",
    ["Choose how high this window sits above other interface elements."] = "Scegli la priorità della finestra sugli altri elementi dell’interfaccia.",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "Allinea nomi, totali, frecce e incrementi in colonne comuni.",
    ["Use short stat labels, including secondary stats."] = "Usa nomi brevi anche per le statistiche secondarie.",
    ["Take a screenshot after a real milestone popup opens."] = "Scatta un’istantanea dopo l’apertura di un vero traguardo.",
    ["Save available training information when visiting trainers."] = "Salva gli addestramenti disponibili quando visiti un istruttore.",
    ["Include profession training in trainer scans."] = "Includi le professioni nelle scansioni degli istruttori.",
    ["Show unlocks from the gained level instead of earlier levels."] = "Mostra gli sblocchi del livello raggiunto anziché quelli precedenti.",
    ["Hide rank upgrades and show only new abilities."] = "Nascondi gli avanzamenti di grado e mostra solo nuove abilità.",
    ["Include training abilities for your character's pet."] = "Includi le abilità di addestramento del famiglio.",
    ["Show grimoires for your currently summoned pet."] = "Mostra i grimori del famiglio attualmente evocato.",
    ["Scroll long ability lists sideways instead of adding more rows."] = "Scorri lateralmente gli elenchi lunghi invece di aggiungere righe.",
    ["Play the selected replacement sound on level-up."] = "Riproduci il suono sostitutivo scelto all’aumento di livello.",
    ["Silence Blizzard's ding when using a replacement sound."] = "Disattiva il suono Blizzard quando usi un suono sostitutivo.",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "Scegli un suono; Predefinito lascia invariato l’audio Blizzard.",
    ["Choose which game audio channel plays GLU sounds."] = "Scegli il canale audio del gioco usato da GLU.",
    ["Adjust GLU sound volume where the client supports it."] = "Regola il volume GLU se supportato dal client.",
    ["Preview the selected sound."] = "Ascolta il suono selezionato.",
    ["Add celebration effects when crossing a ten-level milestone."] = "Aggiungi effetti quando superi un traguardo di dieci livelli.",
    ["Add celebration effects when reaching the level cap."] = "Aggiungi effetti quando raggiungi il livello massimo.",
    ["Play the portrait pulse and starburst during the entrance."] = "Anima la pulsazione e il bagliore del ritratto durante l’entrata.",
    ["Make newly learned ability icons shine."] = "Fai brillare le icone delle abilità appena apprese.",
    ["Animate stat totals and highlight their changes."] = "Anima i totali e metti in risalto i cambiamenti.",
    ["Show decorative particles around the portrait."] = "Mostra particelle decorative intorno al ritratto.",
    ["Show drifting particles behind the popup content."] = "Mostra particelle fluttuanti dietro il contenuto.",
    ["Animate a glow around textured frame edges."] = "Anima un bagliore sui bordi delle cornici con texture.",
    ["Let the portrait ring settle into place during the entrance."] = "Lascia assestare l’anello del ritratto durante l’entrata.",
    ["Animate the section divider lines."] = "Anima le linee divisorie delle sezioni.",
    ["Sweep a bright glint around the portrait ring."] = "Fai scorrere un riflesso luminoso intorno all’anello.",
    ["Choose the direction stat rows slide in from."] = "Scegli la direzione di entrata delle righe delle statistiche.",
    ["Change animation speed without changing display duration."] = "Cambia la velocità delle animazioni senza modificare la durata visibile.",
    ["Add shadows and glow behind popup text."] = "Aggiungi ombre e bagliori dietro il testo.",
    ["Use a separate selected profile for this character."] = "Usa una selezione del profilo separata per questo personaggio.",
    ["Choose the settings profile to use."] = "Scegli il profilo di impostazioni da usare.",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "Elimina i dati scansionati; conserva gli elenchi inclusi.",
    ["Restore default addon settings."] = "Ripristina le impostazioni predefinite dell’addon.",
    ["Open controls to create, rename or delete profiles."] = "Apri i comandi per creare, rinominare o eliminare profili.",
    ["Reload the interface to apply pending changes."] = "Ricarica l’interfaccia per applicare le modifiche in sospeso.",
    ["Share settings by copying a profile code."] = "Condividi le impostazioni copiando un codice profilo.",
    ["Choose the font used by popup text."] = "Scegli il carattere del testo della finestra.",
    ["Pause a test popup's timeout only while Options is open."] = "Sospendi il tempo della prova solo mentre le Opzioni sono aperte.",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Choose the artwork around the portrait."] = "Escolha a arte ao redor do retrato.",
    ["Choose artwork for textured themes."] = "Escolha a arte dos temas com textura.",
    ["Stretch or tile the background artwork."] = "Estique ou repita a textura de fundo.",
    ["Adjust how dark the background appears."] = "Ajuste a escuridão do fundo.",
    ["Seconds the popup stays visible after its entrance."] = "Segundos de exibição após a animação de entrada.",
    ["Resize the whole popup in the current layout."] = "Redimensione toda a janela no layout atual.",
    ["Resize this text while keeping long lines inside the frame."] = "Redimensione o texto mantendo linhas longas dentro da moldura.",
    ["Prevent dragging the popup to a new position."] = "Impeça que a janela seja arrastada para outra posição.",
    ["Show a test popup without changing level history."] = "Mostre uma prévia sem alterar o histórico de níveis.",
    ["Restore default appearance settings."] = "Restaure a aparência padrão.",
    ["Enable or disable the GLU level-up popup."] = "Ative ou desative a janela de subida de nível do GLU.",
    ["Hide Blizzard's visual level-up notification."] = "Oculte a notificação visual de subida de nível da Blizzard.",
    ["Delay the popup until combat ends."] = "Adie a janela até o fim do combate.",
    ["Show the GLU shortcut on the minimap."] = "Mostre o atalho do GLU no minimapa.",
    ["Let clicks pass through the popup to the game."] = "Deixe os cliques atravessarem a janela até o jogo.",
    ["Choose how high this window sits above other interface elements."] = "Escolha a prioridade da janela sobre outros elementos da interface.",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "Alinhe nomes, totais, setas e ganhos em colunas compartilhadas.",
    ["Use short stat labels, including secondary stats."] = "Use nomes curtos, inclusive para atributos secundários.",
    ["Take a screenshot after a real milestone popup opens."] = "Tire uma captura após abrir um marco de nível real.",
    ["Save available training information when visiting trainers."] = "Salve o treinamento disponível ao visitar instrutores.",
    ["Include profession training in trainer scans."] = "Inclua treinamento de profissões nas varreduras.",
    ["Show unlocks from the gained level instead of earlier levels."] = "Mostre os desbloqueios do nível alcançado em vez dos anteriores.",
    ["Hide rank upgrades and show only new abilities."] = "Oculte melhorias de grau e mostre apenas habilidades novas.",
    ["Include training abilities for your character's pet."] = "Inclua habilidades de treinamento do seu ajudante.",
    ["Show grimoires for your currently summoned pet."] = "Mostre grimórios do ajudante invocado no momento.",
    ["Scroll long ability lists sideways instead of adding more rows."] = "Role listas longas lateralmente em vez de adicionar linhas.",
    ["Play the selected replacement sound on level-up."] = "Toque o som substituto escolhido ao subir de nível.",
    ["Silence Blizzard's ding when using a replacement sound."] = "Silencie o som da Blizzard ao usar um substituto.",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "Escolha um som; Padrão mantém o áudio normal da Blizzard.",
    ["Choose which game audio channel plays GLU sounds."] = "Escolha o canal de áudio do jogo para o GLU.",
    ["Adjust GLU sound volume where the client supports it."] = "Ajuste o volume do GLU se o cliente permitir.",
    ["Preview the selected sound."] = "Ouça o som selecionado.",
    ["Add celebration effects when crossing a ten-level milestone."] = "Adicione efeitos ao cruzar um marco de dez níveis.",
    ["Add celebration effects when reaching the level cap."] = "Adicione efeitos ao alcançar o nível máximo.",
    ["Play the portrait pulse and starburst during the entrance."] = "Anime a pulsação e o clarão do retrato durante a entrada.",
    ["Make newly learned ability icons shine."] = "Faça brilhar os ícones das habilidades recém-aprendidas.",
    ["Animate stat totals and highlight their changes."] = "Anime os totais e destaque suas mudanças.",
    ["Show decorative particles around the portrait."] = "Mostre partículas decorativas ao redor do retrato.",
    ["Show drifting particles behind the popup content."] = "Mostre partículas flutuantes atrás do conteúdo.",
    ["Animate a glow around textured frame edges."] = "Anime um brilho nas bordas das molduras com textura.",
    ["Let the portrait ring settle into place during the entrance."] = "Deixe o anel do retrato se acomodar durante a entrada.",
    ["Animate the section divider lines."] = "Anime as linhas divisórias das seções.",
    ["Sweep a bright glint around the portrait ring."] = "Faça um reflexo brilhante percorrer o anel do retrato.",
    ["Choose the direction stat rows slide in from."] = "Escolha de onde entram as linhas de atributos.",
    ["Change animation speed without changing display duration."] = "Altere a velocidade das animações sem mudar a duração de exibição.",
    ["Add shadows and glow behind popup text."] = "Adicione sombras e brilho atrás do texto.",
    ["Use a separate selected profile for this character."] = "Use uma seleção de perfil separada para este personagem.",
    ["Choose the settings profile to use."] = "Escolha o perfil de configurações a usar.",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "Remova os dados escaneados; mantenha as listas incluídas.",
    ["Restore default addon settings."] = "Restaure as configurações padrão do addon.",
    ["Open controls to create, rename or delete profiles."] = "Abra os controles para criar, renomear ou excluir perfis.",
    ["Reload the interface to apply pending changes."] = "Recarregue a interface para aplicar alterações pendentes.",
    ["Share settings by copying a profile code."] = "Compartilhe configurações copiando um código de perfil.",
    ["Choose the font used by popup text."] = "Escolha a fonte do texto da janela.",
    ["Pause a test popup's timeout only while Options is open."] = "Pause o tempo da prévia apenas enquanto Opções estiver aberto.",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Choose the artwork around the portrait."] = "Выберите оформление вокруг портрета.",
    ["Choose artwork for textured themes."] = "Выберите оформление текстурированных тем.",
    ["Stretch or tile the background artwork."] = "Растягивайте или повторяйте текстуру фона.",
    ["Adjust how dark the background appears."] = "Настройте затемнение фона.",
    ["Seconds the popup stays visible after its entrance."] = "Время показа в секундах после анимации появления.",
    ["Resize the whole popup in the current layout."] = "Измените размер всего окна в текущей раскладке.",
    ["Resize this text while keeping long lines inside the frame."] = "Измените размер текста, сохраняя длинные строки внутри рамки.",
    ["Prevent dragging the popup to a new position."] = "Запретите перетаскивание окна.",
    ["Show a test popup without changing level history."] = "Покажите пример без изменения истории уровней.",
    ["Restore default appearance settings."] = "Восстановите стандартное оформление.",
    ["Enable or disable the GLU level-up popup."] = "Включите или отключите окно повышения уровня GLU.",
    ["Hide Blizzard's visual level-up notification."] = "Скройте визуальное уведомление Blizzard о повышении уровня.",
    ["Delay the popup until combat ends."] = "Отложите показ окна до окончания боя.",
    ["Show the GLU shortcut on the minimap."] = "Покажите кнопку GLU у миникарты.",
    ["Let clicks pass through the popup to the game."] = "Пропускайте щелчки через окно в игру.",
    ["Choose how high this window sits above other interface elements."] = "Выберите приоритет окна над другими элементами интерфейса.",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "Выровняйте названия, значения, стрелки и приросты по общим столбцам.",
    ["Use short stat labels, including secondary stats."] = "Используйте короткие названия, включая вторичные характеристики.",
    ["Take a screenshot after a real milestone popup opens."] = "Сделайте снимок после открытия настоящего юбилейного уровня.",
    ["Save available training information when visiting trainers."] = "Сохраняйте доступное обучение при посещении учителей.",
    ["Include profession training in trainer scans."] = "Включите обучение профессиям в сканирование.",
    ["Show unlocks from the gained level instead of earlier levels."] = "Показывайте способности достигнутого, а не предыдущих уровней.",
    ["Hide rank upgrades and show only new abilities."] = "Скройте улучшения рангов и показывайте только новые способности.",
    ["Include training abilities for your character's pet."] = "Включите обучаемые способности питомца.",
    ["Show grimoires for your currently summoned pet."] = "Покажите гримуары текущего призванного питомца.",
    ["Scroll long ability lists sideways instead of adding more rows."] = "Прокручивайте длинные списки вбок вместо добавления строк.",
    ["Play the selected replacement sound on level-up."] = "Проигрывайте выбранный заменяющий звук при повышении уровня.",
    ["Silence Blizzard's ding when using a replacement sound."] = "Отключите звук Blizzard при использовании заменяющего звука.",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "Выберите звук; По умолчанию сохраняет обычный звук Blizzard.",
    ["Choose which game audio channel plays GLU sounds."] = "Выберите игровой звуковой канал для GLU.",
    ["Adjust GLU sound volume where the client supports it."] = "Настройте громкость GLU, если клиент это поддерживает.",
    ["Preview the selected sound."] = "Прослушайте выбранный звук.",
    ["Add celebration effects when crossing a ten-level milestone."] = "Добавляйте эффекты при пересечении рубежа в десять уровней.",
    ["Add celebration effects when reaching the level cap."] = "Добавляйте эффекты при достижении максимального уровня.",
    ["Play the portrait pulse and starburst during the entrance."] = "Проигрывайте пульсацию и вспышку портрета при появлении.",
    ["Make newly learned ability icons shine."] = "Подсвечивайте значки новых изученных способностей.",
    ["Animate stat totals and highlight their changes."] = "Анимируйте значения и выделяйте изменения.",
    ["Show decorative particles around the portrait."] = "Показывайте декоративные частицы вокруг портрета.",
    ["Show drifting particles behind the popup content."] = "Показывайте парящие частицы позади содержимого.",
    ["Animate a glow around textured frame edges."] = "Анимируйте свечение краёв текстурированных рамок.",
    ["Let the portrait ring settle into place during the entrance."] = "Плавно устанавливайте кольцо портрета при появлении.",
    ["Animate the section divider lines."] = "Анимируйте линии разделов.",
    ["Sweep a bright glint around the portrait ring."] = "Проводите яркий блик по кольцу портрета.",
    ["Choose the direction stat rows slide in from."] = "Выберите направление появления строк характеристик.",
    ["Change animation speed without changing display duration."] = "Измените скорость анимаций без изменения времени показа.",
    ["Add shadows and glow behind popup text."] = "Добавьте тени и свечение позади текста.",
    ["Use a separate selected profile for this character."] = "Используйте отдельный выбор профиля для этого персонажа.",
    ["Choose the settings profile to use."] = "Выберите используемый профиль настроек.",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "Удалите данные сканирования; встроенные списки сохранятся.",
    ["Restore default addon settings."] = "Восстановите стандартные настройки аддона.",
    ["Open controls to create, rename or delete profiles."] = "Откройте управление созданием, переименованием и удалением профилей.",
    ["Reload the interface to apply pending changes."] = "Перезагрузите интерфейс для применения ожидающих изменений.",
    ["Share settings by copying a profile code."] = "Поделитесь настройками, скопировав код профиля.",
    ["Choose the font used by popup text."] = "Выберите шрифт текста окна.",
    ["Pause a test popup's timeout only while Options is open."] = "Приостанавливайте время примера только при открытых настройках.",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Choose the artwork around the portrait."] = "초상화 주변의 장식을 선택합니다.",
    ["Choose artwork for textured themes."] = "텍스처 테마의 장식을 선택합니다.",
    ["Stretch or tile the background artwork."] = "배경 텍스처를 늘리거나 반복합니다.",
    ["Adjust how dark the background appears."] = "배경의 어두운 정도를 조절합니다.",
    ["Seconds the popup stays visible after its entrance."] = "등장 애니메이션 후 표시되는 시간(초)입니다.",
    ["Resize the whole popup in the current layout."] = "현재 배치에서 팝업 전체 크기를 조절합니다.",
    ["Resize this text while keeping long lines inside the frame."] = "긴 줄이 테두리 안에 들어오도록 글자 크기를 조절합니다.",
    ["Prevent dragging the popup to a new position."] = "팝업을 다른 위치로 끌지 못하게 합니다.",
    ["Show a test popup without changing level history."] = "레벨 기록을 바꾸지 않고 시험 팝업을 표시합니다.",
    ["Restore default appearance settings."] = "기본 외형 설정으로 복원합니다.",
    ["Enable or disable the GLU level-up popup."] = "GLU 레벨 상승 팝업을 켜거나 끕니다.",
    ["Hide Blizzard's visual level-up notification."] = "블리자드의 시각적 레벨 상승 알림을 숨깁니다.",
    ["Delay the popup until combat ends."] = "전투가 끝난 후 팝업을 표시합니다.",
    ["Show the GLU shortcut on the minimap."] = "미니맵에 GLU 바로가기를 표시합니다.",
    ["Let clicks pass through the popup to the game."] = "팝업을 통과해 게임으로 클릭을 전달합니다.",
    ["Choose how high this window sits above other interface elements."] = "다른 인터페이스 요소 위에 표시될 우선순위를 선택합니다.",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "이름, 수치, 화살표와 증가량을 공통 열에 정렬합니다.",
    ["Use short stat labels, including secondary stats."] = "보조 능력치를 포함해 짧은 이름을 사용합니다.",
    ["Take a screenshot after a real milestone popup opens."] = "실제 이정표 팝업이 나타난 후 스크린샷을 찍습니다.",
    ["Save available training information when visiting trainers."] = "상급자를 방문할 때 가능한 훈련 정보를 저장합니다.",
    ["Include profession training in trainer scans."] = "상급자 검색에 전문 기술 훈련을 포함합니다.",
    ["Show unlocks from the gained level instead of earlier levels."] = "이전 레벨 대신 방금 오른 레벨의 기술을 표시합니다.",
    ["Hide rank upgrades and show only new abilities."] = "등급 향상을 숨기고 새로운 기술만 표시합니다.",
    ["Include training abilities for your character's pet."] = "소환수에게 가르칠 수 있는 기술을 포함합니다.",
    ["Show grimoires for your currently summoned pet."] = "현재 소환한 소환수의 흑마법서만 표시합니다.",
    ["Scroll long ability lists sideways instead of adding more rows."] = "긴 기술 목록에 줄을 추가하는 대신 가로로 스크롤합니다.",
    ["Play the selected replacement sound on level-up."] = "레벨 상승 시 선택한 대체 소리를 재생합니다.",
    ["Silence Blizzard's ding when using a replacement sound."] = "대체 소리 사용 시 블리자드 기본 소리를 끕니다.",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "소리를 선택합니다. 기본값은 블리자드 소리를 그대로 유지합니다.",
    ["Choose which game audio channel plays GLU sounds."] = "GLU 소리를 재생할 게임 오디오 채널을 선택합니다.",
    ["Adjust GLU sound volume where the client supports it."] = "클라이언트가 지원하는 경우 GLU 음량을 조절합니다.",
    ["Preview the selected sound."] = "선택한 소리를 미리 듣습니다.",
    ["Add celebration effects when crossing a ten-level milestone."] = "10레벨 이정표를 지날 때 축하 효과를 추가합니다.",
    ["Add celebration effects when reaching the level cap."] = "최대 레벨에 도달하면 축하 효과를 추가합니다.",
    ["Play the portrait pulse and starburst during the entrance."] = "등장 중 초상화의 맥동과 섬광을 재생합니다.",
    ["Make newly learned ability icons shine."] = "새로 배운 기술 아이콘을 빛나게 합니다.",
    ["Animate stat totals and highlight their changes."] = "능력치 수치를 움직이고 변화를 강조합니다.",
    ["Show decorative particles around the portrait."] = "초상화 주변에 장식 입자를 표시합니다.",
    ["Show drifting particles behind the popup content."] = "내용 뒤에 떠다니는 입자를 표시합니다.",
    ["Animate a glow around textured frame edges."] = "텍스처 테두리에 빛나는 효과를 재생합니다.",
    ["Let the portrait ring settle into place during the entrance."] = "등장 중 초상화 고리가 자리를 잡게 합니다.",
    ["Animate the section divider lines."] = "구역 구분선을 움직입니다.",
    ["Sweep a bright glint around the portrait ring."] = "초상화 고리를 따라 밝은 빛이 지나갑니다.",
    ["Choose the direction stat rows slide in from."] = "능력치 줄이 들어오는 방향을 선택합니다.",
    ["Change animation speed without changing display duration."] = "표시 시간은 유지하고 애니메이션 속도만 바꿉니다.",
    ["Add shadows and glow behind popup text."] = "글자 뒤에 그림자와 빛을 추가합니다.",
    ["Use a separate selected profile for this character."] = "이 캐릭터에 별도의 프로필 선택을 사용합니다.",
    ["Choose the settings profile to use."] = "사용할 설정 프로필을 선택합니다.",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "검색한 상급자 데이터를 지우고 기본 목록은 유지합니다.",
    ["Restore default addon settings."] = "애드온을 기본 설정으로 복원합니다.",
    ["Open controls to create, rename or delete profiles."] = "프로필 생성, 이름 변경, 삭제 도구를 엽니다.",
    ["Reload the interface to apply pending changes."] = "인터페이스를 다시 불러와 변경 사항을 적용합니다.",
    ["Share settings by copying a profile code."] = "프로필 코드를 복사해 설정을 공유합니다.",
    ["Choose the font used by popup text."] = "팝업 글꼴을 선택합니다.",
    ["Pause a test popup's timeout only while Options is open."] = "설정 창이 열려 있을 때만 시험 팝업의 시간을 일시 정지합니다.",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Choose the artwork around the portrait."] = "选择头像周围的装饰。",
    ["Choose artwork for textured themes."] = "选择纹理主题的装饰。",
    ["Stretch or tile the background artwork."] = "拉伸或平铺背景纹理。",
    ["Adjust how dark the background appears."] = "调整背景的暗度。",
    ["Seconds the popup stays visible after its entrance."] = "入场动画结束后的显示秒数。",
    ["Resize the whole popup in the current layout."] = "调整当前布局中整个弹窗的大小。",
    ["Resize this text while keeping long lines inside the frame."] = "调整文字大小，并确保长行留在边框内。",
    ["Prevent dragging the popup to a new position."] = "禁止拖动弹窗位置。",
    ["Show a test popup without changing level history."] = "显示测试弹窗，不改变升级历史。",
    ["Restore default appearance settings."] = "恢复默认外观设置。",
    ["Enable or disable the GLU level-up popup."] = "启用或禁用GLU升级弹窗。",
    ["Hide Blizzard's visual level-up notification."] = "隐藏暴雪的升级画面提示。",
    ["Delay the popup until combat ends."] = "等待战斗结束后显示弹窗。",
    ["Show the GLU shortcut on the minimap."] = "在小地图上显示GLU快捷按钮。",
    ["Let clicks pass through the popup to the game."] = "让点击穿过弹窗传递给游戏。",
    ["Choose how high this window sits above other interface elements."] = "选择此窗口在其他界面元素之上的显示层级。",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "将名称、数值、箭头和增量对齐到共用列。",
    ["Use short stat labels, including secondary stats."] = "使用简短名称，包括次要属性。",
    ["Take a screenshot after a real milestone popup opens."] = "真正的里程碑弹窗出现后截取屏幕。",
    ["Save available training information when visiting trainers."] = "拜访训练师时保存可用训练信息。",
    ["Include profession training in trainer scans."] = "将专业训练加入训练师扫描。",
    ["Show unlocks from the gained level instead of earlier levels."] = "显示刚达到等级解锁的技能，而非之前等级。",
    ["Hide rank upgrades and show only new abilities."] = "隐藏等级提升，仅显示新技能。",
    ["Include training abilities for your character's pet."] = "包括角色宠物可训练的技能。",
    ["Show grimoires for your currently summoned pet."] = "显示当前召唤宠物对应的魔典。",
    ["Scroll long ability lists sideways instead of adding more rows."] = "长技能列表横向滚动，而非增加行数。",
    ["Play the selected replacement sound on level-up."] = "升级时播放选定的替代音效。",
    ["Silence Blizzard's ding when using a replacement sound."] = "使用替代音效时关闭暴雪升级音效。",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "选择音效；默认选项保留暴雪的正常声音。",
    ["Choose which game audio channel plays GLU sounds."] = "选择GLU使用的游戏音频通道。",
    ["Adjust GLU sound volume where the client supports it."] = "在客户端支持时调整GLU音量。",
    ["Preview the selected sound."] = "试听选定音效。",
    ["Add celebration effects when crossing a ten-level milestone."] = "跨过十级里程碑时添加庆祝效果。",
    ["Add celebration effects when reaching the level cap."] = "达到最高等级时添加庆祝效果。",
    ["Play the portrait pulse and starburst during the entrance."] = "入场时播放头像脉冲和星爆。",
    ["Make newly learned ability icons shine."] = "让新学技能的图标闪光。",
    ["Animate stat totals and highlight their changes."] = "动态显示属性总值并突出变化。",
    ["Show decorative particles around the portrait."] = "在头像周围显示装饰粒子。",
    ["Show drifting particles behind the popup content."] = "在弹窗内容后显示飘动粒子。",
    ["Animate a glow around textured frame edges."] = "让纹理边框边缘发光。",
    ["Let the portrait ring settle into place during the entrance."] = "入场时让头像圆环逐渐稳定。",
    ["Animate the section divider lines."] = "动态显示分区分隔线。",
    ["Sweep a bright glint around the portrait ring."] = "让亮光扫过头像圆环。",
    ["Choose the direction stat rows slide in from."] = "选择属性行滑入的方向。",
    ["Change animation speed without changing display duration."] = "更改动画速度，不改变显示时长。",
    ["Add shadows and glow behind popup text."] = "为弹窗文字添加阴影和辉光。",
    ["Use a separate selected profile for this character."] = "为此角色使用独立的配置选择。",
    ["Choose the settings profile to use."] = "选择要使用的设置配置。",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "清除扫描的训练师数据，保留内置列表。",
    ["Restore default addon settings."] = "恢复插件默认设置。",
    ["Open controls to create, rename or delete profiles."] = "打开创建、重命名或删除配置的工具。",
    ["Reload the interface to apply pending changes."] = "重新加载界面以应用待生效的更改。",
    ["Share settings by copying a profile code."] = "复制配置代码以分享设置。",
    ["Choose the font used by popup text."] = "选择弹窗文字的字体。",
    ["Pause a test popup's timeout only while Options is open."] = "仅在选项窗口打开时暂停测试弹窗的计时。",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Choose the artwork around the portrait."] = "選擇頭像周圍的裝飾。",
    ["Choose artwork for textured themes."] = "選擇材質主題的裝飾。",
    ["Stretch or tile the background artwork."] = "延展或平鋪背景材質。",
    ["Adjust how dark the background appears."] = "調整背景的暗度。",
    ["Seconds the popup stays visible after its entrance."] = "入場動畫結束後的顯示秒數。",
    ["Resize the whole popup in the current layout."] = "調整目前配置中整個彈出視窗的大小。",
    ["Resize this text while keeping long lines inside the frame."] = "調整文字大小，確保長行留在邊框內。",
    ["Prevent dragging the popup to a new position."] = "禁止拖曳彈出視窗的位置。",
    ["Show a test popup without changing level history."] = "顯示測試視窗，不改變升級記錄。",
    ["Restore default appearance settings."] = "恢復預設外觀設定。",
    ["Enable or disable the GLU level-up popup."] = "啟用或停用GLU升級視窗。",
    ["Hide Blizzard's visual level-up notification."] = "隱藏暴雪的升級畫面提示。",
    ["Delay the popup until combat ends."] = "等待戰鬥結束後顯示視窗。",
    ["Show the GLU shortcut on the minimap."] = "在小地圖上顯示GLU快捷按鈕。",
    ["Let clicks pass through the popup to the game."] = "讓點擊穿過視窗傳遞給遊戲。",
    ["Choose how high this window sits above other interface elements."] = "選擇此視窗在其他介面元素之上的顯示層級。",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "將名稱、數值、箭頭與增量對齊到共用欄。",
    ["Use short stat labels, including secondary stats."] = "使用簡短名稱，包括次要屬性。",
    ["Take a screenshot after a real milestone popup opens."] = "真正的里程碑視窗出現後擷取畫面。",
    ["Save available training information when visiting trainers."] = "拜訪訓練師時儲存可用訓練資訊。",
    ["Include profession training in trainer scans."] = "將專業訓練加入訓練師掃描。",
    ["Show unlocks from the gained level instead of earlier levels."] = "顯示剛達到等級解鎖的技能，而非先前等級。",
    ["Hide rank upgrades and show only new abilities."] = "隱藏等級提升，僅顯示新技能。",
    ["Include training abilities for your character's pet."] = "包括角色寵物可訓練的技能。",
    ["Show grimoires for your currently summoned pet."] = "顯示目前召喚寵物對應的魔典。",
    ["Scroll long ability lists sideways instead of adding more rows."] = "長技能清單橫向捲動，而非增加列數。",
    ["Play the selected replacement sound on level-up."] = "升級時播放選定的替代音效。",
    ["Silence Blizzard's ding when using a replacement sound."] = "使用替代音效時關閉暴雪升級音效。",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "選擇音效；預設選項保留暴雪的正常聲音。",
    ["Choose which game audio channel plays GLU sounds."] = "選擇GLU使用的遊戲音訊聲道。",
    ["Adjust GLU sound volume where the client supports it."] = "在用戶端支援時調整GLU音量。",
    ["Preview the selected sound."] = "試聽選定音效。",
    ["Add celebration effects when crossing a ten-level milestone."] = "跨過十級里程碑時加入慶祝效果。",
    ["Add celebration effects when reaching the level cap."] = "達到最高等級時加入慶祝效果。",
    ["Play the portrait pulse and starburst during the entrance."] = "入場時播放頭像脈衝與星爆。",
    ["Make newly learned ability icons shine."] = "讓新學技能的圖示閃光。",
    ["Animate stat totals and highlight their changes."] = "動態顯示屬性總值並突顯變化。",
    ["Show decorative particles around the portrait."] = "在頭像周圍顯示裝飾粒子。",
    ["Show drifting particles behind the popup content."] = "在視窗內容後顯示飄動粒子。",
    ["Animate a glow around textured frame edges."] = "讓材質邊框邊緣發光。",
    ["Let the portrait ring settle into place during the entrance."] = "入場時讓頭像圓環逐漸穩定。",
    ["Animate the section divider lines."] = "動態顯示分區分隔線。",
    ["Sweep a bright glint around the portrait ring."] = "讓亮光掃過頭像圓環。",
    ["Choose the direction stat rows slide in from."] = "選擇屬性列滑入的方向。",
    ["Change animation speed without changing display duration."] = "更改動畫速度，不改變顯示時間。",
    ["Add shadows and glow behind popup text."] = "為視窗文字加入陰影與光暈。",
    ["Use a separate selected profile for this character."] = "為此角色使用獨立的設定檔選擇。",
    ["Choose the settings profile to use."] = "選擇要使用的設定檔。",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "清除掃描的訓練師資料，保留內建清單。",
    ["Restore default addon settings."] = "恢復插件預設設定。",
    ["Open controls to create, rename or delete profiles."] = "開啟建立、重新命名或刪除設定檔的工具。",
    ["Reload the interface to apply pending changes."] = "重新載入介面以套用尚未生效的變更。",
    ["Share settings by copying a profile code."] = "複製設定檔代碼以分享設定。",
    ["Choose the font used by popup text."] = "選擇視窗文字的字型。",
    ["Pause a test popup's timeout only while Options is open."] = "僅在選項視窗開啟時暫停測試視窗的計時。",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Choose the artwork around the portrait."] = "Elige el diseño que rodea el retrato.",
    ["Choose artwork for textured themes."] = "Elige el diseño para los temas con texturas.",
    ["Stretch or tile the background artwork."] = "Estira o repite la textura del fondo.",
    ["Adjust how dark the background appears."] = "Ajusta la oscuridad del fondo.",
    ["Seconds the popup stays visible after its entrance."] = "Segundos que permanece visible tras la animación de entrada.",
    ["Resize the whole popup in the current layout."] = "Cambia el tamaño de toda la ventana en la disposición actual.",
    ["Resize this text while keeping long lines inside the frame."] = "Cambia el tamaño del texto manteniendo las líneas largas dentro del marco.",
    ["Prevent dragging the popup to a new position."] = "Impide arrastrar la ventana a otra posición.",
    ["Show a test popup without changing level history."] = "Muestra una prueba sin cambiar el historial de niveles.",
    ["Restore default appearance settings."] = "Restaura los ajustes de apariencia predeterminados.",
    ["Enable or disable the GLU level-up popup."] = "Activa o desactiva la ventana de subida de nivel de GLU.",
    ["Hide Blizzard's visual level-up notification."] = "Oculta el aviso visual de subida de nivel de Blizzard.",
    ["Delay the popup until combat ends."] = "Retrasa la ventana hasta que termine el combate.",
    ["Show the GLU shortcut on the minimap."] = "Muestra el acceso de GLU en el minimapa.",
    ["Let clicks pass through the popup to the game."] = "Permite que los clics atraviesen la ventana hacia el juego.",
    ["Choose how high this window sits above other interface elements."] = "Elige la prioridad de esta ventana sobre otros elementos de la interfaz.",
    ["Align stat labels, totals, arrows and gains in shared columns."] = "Alinea nombres, totales, flechas y ganancias en columnas compartidas.",
    ["Use short stat labels, including secondary stats."] = "Usa nombres cortos, también para las estadísticas secundarias.",
    ["Take a screenshot after a real milestone popup opens."] = "Toma una captura al abrirse un aviso real de hito.",
    ["Save available training information when visiting trainers."] = "Guarda la formación disponible al visitar instructores.",
    ["Include profession training in trainer scans."] = "Incluye la formación de profesiones en los escaneos.",
    ["Show unlocks from the gained level instead of earlier levels."] = "Muestra las facultades del nivel alcanzado en lugar de niveles anteriores.",
    ["Hide rank upgrades and show only new abilities."] = "Oculta mejoras de rango y muestra solo facultades nuevas.",
    ["Include training abilities for your character's pet."] = "Incluye las facultades de entrenamiento de tu mascota.",
    ["Show grimoires for your currently summoned pet."] = "Muestra los grimorios de la mascota invocada actualmente.",
    ["Scroll long ability lists sideways instead of adding more rows."] = "Desplaza las listas largas lateralmente en lugar de añadir filas.",
    ["Play the selected replacement sound on level-up."] = "Reproduce el sonido de sustitución seleccionado al subir de nivel.",
    ["Silence Blizzard's ding when using a replacement sound."] = "Silencia el sonido de Blizzard al utilizar uno de sustitución.",
    ["Choose a level-up sound; Default keeps Blizzard audio unchanged."] = "Elige un sonido; Predeterminado conserva el sonido normal de Blizzard.",
    ["Choose which game audio channel plays GLU sounds."] = "Elige el canal de audio del juego para GLU.",
    ["Adjust GLU sound volume where the client supports it."] = "Ajusta el volumen de GLU si el cliente lo permite.",
    ["Preview the selected sound."] = "Escucha el sonido seleccionado.",
    ["Add celebration effects when crossing a ten-level milestone."] = "Añade efectos de celebración al cruzar un hito de diez niveles.",
    ["Add celebration effects when reaching the level cap."] = "Añade efectos al alcanzar el nivel máximo.",
    ["Play the portrait pulse and starburst during the entrance."] = "Anima el pulso y el destello del retrato durante la entrada.",
    ["Make newly learned ability icons shine."] = "Haz brillar los iconos de las facultades recién aprendidas.",
    ["Animate stat totals and highlight their changes."] = "Anima los totales y resalta sus cambios.",
    ["Show decorative particles around the portrait."] = "Muestra partículas decorativas alrededor del retrato.",
    ["Show drifting particles behind the popup content."] = "Muestra partículas flotantes detrás del contenido.",
    ["Animate a glow around textured frame edges."] = "Anima un resplandor en los bordes de los marcos con texturas.",
    ["Let the portrait ring settle into place during the entrance."] = "Deja que el anillo se asiente durante la entrada.",
    ["Animate the section divider lines."] = "Anima las líneas divisorias de las secciones.",
    ["Sweep a bright glint around the portrait ring."] = "Desplaza un reflejo brillante alrededor del anillo.",
    ["Choose the direction stat rows slide in from."] = "Elige la dirección de entrada de las filas de estadísticas.",
    ["Change animation speed without changing display duration."] = "Cambia la velocidad de animación sin cambiar la duración visible.",
    ["Add shadows and glow behind popup text."] = "Añade sombras y brillo detrás del texto.",
    ["Use a separate selected profile for this character."] = "Usa una selección de perfil independiente para este personaje.",
    ["Choose the settings profile to use."] = "Elige el perfil de ajustes que quieres usar.",
    ["Remove scanned trainer data; bundled trainer lists remain."] = "Borra los datos escaneados; conserva las listas incluidas.",
    ["Restore default addon settings."] = "Restaura los ajustes predeterminados del addon.",
    ["Open controls to create, rename or delete profiles."] = "Abre los controles para crear, renombrar o borrar perfiles.",
    ["Reload the interface to apply pending changes."] = "Recarga la interfaz para aplicar los cambios pendientes.",
    ["Share settings by copying a profile code."] = "Comparte ajustes copiando un código de perfil.",
    ["Choose the font used by popup text."] = "Elige la fuente del texto de la ventana.",
    ["Pause a test popup's timeout only while Options is open."] = "Pausa el tiempo de la prueba solo mientras Opciones esté abierto.",
} end)

-- Minimap preview shortcut.
RegisterLocaleBuilder("frFR", function() return { ["Right-click: Preview Level-Up"] = "Clic droit : aperçu de l’alerte" } end)
RegisterLocaleBuilder("esES", function() return { ["Right-click: Preview Level-Up"] = "Clic derecho: vista previa de subida de nivel" } end)
RegisterLocaleBuilder("esMX", function() return { ["Right-click: Preview Level-Up"] = "Clic derecho: vista previa de subida de nivel" } end)
RegisterLocaleBuilder("deDE", function() return { ["Right-click: Preview Level-Up"] = "Rechtsklick: Stufenaufstieg testen" } end)
RegisterLocaleBuilder("itIT", function() return { ["Right-click: Preview Level-Up"] = "Clic destro: anteprima del passaggio di livello" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Right-click: Preview Level-Up"] = "Botão direito: prévia de subida de nível" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Right-click: Preview Level-Up"] = "Правая кнопка мыши: предпросмотр повышения уровня" } end)
RegisterLocaleBuilder("koKR", function() return { ["Right-click: Preview Level-Up"] = "오른쪽 클릭: 레벨 상승 미리 보기" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Right-click: Preview Level-Up"] = "右键点击：预览升级提示" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Right-click: Preview Level-Up"] = "右鍵點擊：預覽升級提示" } end)
