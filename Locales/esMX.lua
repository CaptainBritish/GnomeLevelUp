local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- esMX: Español (Latinoamérica). English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.
-- Loads after esES.lua, which defines the shared Spanish vocabulary.

-- Reuse Spanish vocabulary while keeping independent enable/disable flags.
RegisterLocaleBuilder("esMX", ns.BuildSpanishLocale)
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

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("esMX", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "¡Bienvenido a GnomeLevelUp! Desde la versión 1.4.0 ya no necesitas escanear a los instructores manualmente: ¡la lista ya está incluida! ¡Repórtame cualquier problema que encuentres en GitHub o Curseforge!",
} end)

-- Trainer-change monitoring and report export.
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

-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("esMX", function() return {
    ["Portrait pulse and starburst"] = "Pulso y destello del retrato",
    ["Highlight new abilities"] = "Resaltar nuevas facultades",
    ["Emphasize stat gains"] = "Destacar aumentos de estadísticas",
    ["New ability"] = "Nueva facultad",
    ["Rank upgrade"] = "Mejora de rango",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("esMX", function() return {
    ["Portrait sparks"] = "Chispas del retrato",
    ["New ability sparkles"] = "Destellos en nuevas facultades",
    ["Background embers"] = "Ascuas de fondo",
    ["Frame edge glow"] = "Resplandor del marco",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
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

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("esMX", function() return {
    ["Portrait and ring settle"] = "Asentar retrato y anillo",
    ["Reveal dividers"] = "Revelar separadores",
} end)
RegisterLocaleBuilder("esMX", function() return { ["Animated Elements"] = "Elementos animados" } end)
RegisterLocaleBuilder("esMX", function() return {
    ["Starburst opacity (%)"] = "Opacidad del destello radial (%)",
    ["Portrait pulse opacity (%)"] = "Opacidad del pulso del retrato (%)",
    ["Frame edge glow opacity (%)"] = "Opacidad del brillo del borde (%)",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Copy"] = "Copiar",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Presiona Ctrl+C para copiar. El campo se vaciará después.",
} end)

-- Profile controls and sharing messages.
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

-- Profile-sharing window.
RegisterLocaleBuilder("esMX", function() return {
    ["Profile name (optional)"] = "Nombre del perfil (opcional)",
    ["Invalid profile string."] = "Cadena de perfil no válida.",
    ["Invalid profile settings."] = "Configuración del perfil no válida.",
} end)

-- Profile management.
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

-- First-run setup.
RegisterLocaleBuilder("esMX", function() return {
    ["GLU First Time Setup"] = "GLU — Configuración inicial",
    ["Finish setup"] = "Finalizar configuración",
    ["Change these choices anytime in Options."] = "Puedes cambiar estas opciones en cualquier momento en Opciones.",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("esMX", function() return {
    ["Show pet skills"] = "Mostrar habilidades de mascotas",
    ["Enable animations"] = "Activar animaciones",
} end)

-- Setup heading.
RegisterLocaleBuilder("esMX", function() return { ["Welcome to GnomeLevelUp!"] = "¡Bienvenido a GnomeLevelUp!" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("esMX", function() return { ["Background animations"] = "Animaciones de fondo" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("esMX", function() return { ["Horizontal layout"] = "Diseño horizontal" } end)
RegisterLocaleBuilder("esMX", function() return { ["Player 3D portrait"] = "Retrato 3D del jugador" } end)
RegisterLocaleBuilder("esMX", function() return { ["3D model rotation (degrees)"] = "Rotación del modelo 3D (grados)", ["3D model depth"] = "Profundidad del modelo 3D", ["3D model horizontal position"] = "Posición horizontal del modelo 3D", ["3D model vertical position"] = "Posición vertical del modelo 3D", ["3D model scale (%)"] = "Escala del modelo 3D (%)" } end)
RegisterLocaleBuilder("esMX", function() return { ["3D mask size (%)"] = "Tamaño de la máscara 3D (%)" } end)
RegisterLocaleBuilder("esMX", function() return { ["3D viewport size (%)"] = "Tamaño del área de vista 3D (%)" } end)
RegisterLocaleBuilder("esMX", function() return { ["Milestone Animations"] = "Animaciones de hito" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("esMX", function() return { ["Firework size (%)"] = "Tamaño de los fuegos artificiales (%)", ["Firework opacity (%)"] = "Opacidad de los fuegos artificiales (%)" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("esMX", function() return { ["Frame inset (px)"] = "Margen del marco (px)" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("esMX", function() return { ["Portrait ring glint"] = "Destello del anillo del retrato", ["Ability reveal shine"] = "Brillo al aparecer habilidades", ["Milestone anticipation"] = "Anticipación de hitos", ["Stat impact sparks"] = "Chispas de mejora de estadísticas", ["Background depth"] = "Profundidad del fondo", ["Closing animation"] = "Animación de cierre", ["Milestone color transition"] = "Transición de color de hitos" } end)
RegisterLocaleBuilder("esMX", function() return { ["Screenshot milestones"] = "Capturas de pantalla en hitos" } end)
RegisterLocaleBuilder("esMX", function() return { ["Portrait motes"] = "Partículas del retrato", ["Background motes"] = "Partículas de fondo" } end)
RegisterLocaleBuilder("esMX", function() return { ["3D Portraits may consume more memory."] = "Los retratos 3D pueden consumir más memoria." } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("esMX", function() return {
    ["Shorten stat totals"] = "Abreviar los totales de estadísticas",
    ["Relevant stats only"] = "Solo estadísticas relevantes",
    ["%sk"] = "%sk", ["%sm"] = "%sM", ["%sb"] = "%s mil M",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("esMX", function() return { ["Uses game volume"] = "Usa el volumen del juego" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("esMX", function() return {
    ["Show faster leveling times"] = "Mostrar nuevos récords al subir de nivel",
    ["Fastest level: %s"] = "Nuevo récord: %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("esMX", function() return {
    ["Max Level Celebration"] = "Celebración del nivel máximo",
    ["Time to max level: %s"] = "Tiempo hasta el nivel máximo: %s",
    ["%dd %02dh %02dm %02ds"] = "%dd %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Sonido del impacto del retrato",
    ["Starburst sound"] = "Sonido del destello del retrato",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("esMX", function() return {
    ["Time to Level: %s"] = "Tiempo para subir de nivel: %s",
    ["New fastest time!:"] = "¡Nuevo mejor tiempo!:",
    ["New fastest time!: %s"] = "¡Nuevo mejor tiempo!: %s",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Glint finishing spark"] = "Chispa final del destello",
    ["Portrait shine"] = "Brillo del retrato",
    ["Ring surges"] = "Descargas del anillo",
    ["Max-level portrait sparks"] = "Chispas del retrato al nivel máximo",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["New Best Time!"] = "¡Nuevo mejor tiempo!",
    ["Fastest Time: %s"] = "Mejor tiempo: %s",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Abbreviate stat names"] = "Abreviar nombres de estadísticas",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["%sM %sk"] = "%sM %sk",
    ["Recorded level timers and best times reset for this character."] = "Se han restablecido los tiempos de nivel y récords guardados de este personaje.",
} end)

-- Classic Mode and first-time setup descriptions.
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
RegisterLocaleBuilder("esMX", function() return {
    ["Stat text size"] = "Tamaño del texto de estadísticas",
    ["Heading text size"] = "Tamaño de los encabezados",
    ["Time to Level text size"] = "Tamaño del texto de tiempo de nivel",
    ["Level %d - %d"] = "Niveles %d - %d",
    ["Time for %d levels: %s"] = "Tiempo para %d niveles: %s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
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
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "Toma una captura de pantalla cuando una subida de nivel real coincida con el intervalo de hitos seleccionado.",
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
RegisterLocaleBuilder("esMX", function() return { ["Middle-click: Preview Level-Up"] = "Clic central: vista previa de subida de nivel" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("esMX", function() return {
    ["Switch to secondary stats at"] = "Cambiar a estadísticas secundarias al",
    ["Choose the percentage of display time spent on primary stats."] = "Elige el porcentaje del tiempo de visualización dedicado a las estadísticas principales.",
    ["Replace primary stats with secondary stats during the popup."] = "Sustituye las estadísticas principales por las secundarias durante el aviso.",
    ["Right-click: Replay last level-up"] = "Clic derecho: repetir la última subida de nivel",
    ["No recorded level-up to replay yet."] = "Todavía no hay una subida de nivel registrada para repetir.",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("esMX", function() return {
    ["Adjust the space between popup sections."] = "Ajusta el espacio entre las secciones del aviso.",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "Compara los servicios del instructor con el catálogo incluido y ofrece un informe si hay diferencias.",
    ["Open saved trainer differences and instructions for exporting a report."] = "Abre las diferencias guardadas y las instrucciones para exportar un informe.",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "Incluye los grimorios disponibles para todos los demonios del brujo, no solo la mascota activa.",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "Introduce la ruta de un archivo OGG relativa al addon para el sonido personalizado.",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "Elige un sonido personalizado registrado por este addon o SharedMedia.",
    ["Show advanced tuning controls, test commands and performance counters."] = "Muestra ajustes avanzados, comandos de prueba y contadores de rendimiento.",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "Imprime los tiempos medidos en el chat. Activa la depuración para recopilarlos.",
    ["Clear performance counters before measuring another popup."] = "Borra los contadores antes de medir otro aviso.",
    ["Choose automatic client detection or force Retail or Forever rules."] = "Elige la detección automática del cliente o fuerza las reglas de Retail o Forever.",
    ["Update the displayed trainer-cache information."] = "Actualiza la información mostrada sobre la caché de instructores.",
    ["Enter a name to create a profile or rename the current one."] = "Introduce un nombre para crear un perfil o renombrar el actual.",
    ["Save the current options as a new profile with the entered name."] = "Guarda los ajustes actuales en un perfil nuevo con el nombre introducido.",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "Renombra el perfil seleccionado. El perfil predeterminado no se puede renombrar.",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "Elimina el perfil seleccionado tras confirmar. El perfil predeterminado no se puede eliminar.",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "Restaura los ajustes predeterminados; conserva los tiempos de nivel y los informes guardados.",
    ["Move the 3D portrait closer to or farther from the camera."] = "Acerca o aleja el retrato 3D de la cámara.",
    ["Move the 3D portrait left or right inside its viewport."] = "Mueve el retrato 3D a izquierda o derecha dentro de su área.",
    ["Move the 3D portrait up or down inside its viewport."] = "Mueve el retrato 3D arriba o abajo dentro de su área.",
    ["Turn the 3D portrait around its vertical axis."] = "Gira el retrato 3D sobre su eje vertical.",
    ["Change the size of the 3D character model."] = "Cambia el tamaño del modelo 3D del personaje.",
    ["Change the circular mask that clips the 3D portrait."] = "Cambia la máscara circular que recorta el retrato 3D.",
    ["Change the 3D rendering area around the portrait."] = "Cambia el área de renderizado 3D alrededor del retrato.",
    ["Resize the ring artwork without resizing the portrait."] = "Cambia el tamaño del aro sin cambiar el del retrato.",
    ["Move the ring artwork left or right."] = "Mueve el aro a izquierda o derecha.",
    ["Move the ring artwork up or down."] = "Mueve el aro arriba o abajo.",
    ["Adjust the empty inset between textured borders and popup content."] = "Ajusta el margen vacío entre los bordes con textura y el contenido del aviso.",
    ["Mirror this frame piece horizontally."] = "Refleja horizontalmente esta pieza del marco.",
    ["Mirror this frame piece vertically."] = "Refleja verticalmente esta pieza del marco.",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "Cambia el color del elemento indicado. Los colores de clase pueden sustituir los colores de acento.",
    ["Tint this individual frame piece."] = "Tiñe solo esta pieza del marco.",
    ["Rotate this individual frame piece."] = "Gira solo esta pieza del marco.",
    ["Set the number of particles for this effect. Zero hides them."] = "Establece cuántas partículas tiene este efecto. Cero las oculta.",
    ["Resize this effect's particles as a percentage of their normal size."] = "Cambia el tamaño de las partículas como porcentaje de su tamaño normal.",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "Establece la opacidad de las partículas. Cero las vuelve invisibles.",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "Establece la opacidad de la animación indicada. Cero la vuelve invisible.",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "Reproduce un sonido al activarse esta animación. Introduce un ID de archivo de sonido de WoW; 0 silencia este efecto.",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Celebra cada hito de diez niveles con anticipación del retrato, acentos más brillantes y efectos de estadísticas. El modo clásico desactiva estos adornos.",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "Al nivel máximo, añade fuegos artificiales curvos con colores de clase, chispas en el aro y más partículas de fondo. El modo clásico desactiva estos efectos.",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "Hace pulsar el aro y revela un destello creciente detrás del retrato. Los hitos y el nivel máximo también añaden un brillo periódico al retrato.",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "Añade brillo de aparición, resplandor y chispas a las facultades recién aprendidas. Las mejoras de rango no se resaltan.",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "Anima los totales desde sus valores anteriores y después ilumina los números modificados. Los hitos también añaden chispas al terminar el contador.",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "Libera pequeñas luces flotantes alrededor del retrato después del destello. Requiere el pulso y destello del retrato.",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "Muestra partículas ascendentes detrás del aviso. Los hitos y el nivel máximo aumentan su densidad; el nivel máximo también las acelera.",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "Desplaza un resplandor que se desvanece por los bordes con textura al abrirse. No está disponible con Moderno.",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "Empieza con el retrato ligeramente ampliado y vuelve suavemente al tamaño normal. Los hitos añaden un breve destello de anticipación.",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "Extiende las líneas divisorias al entrar cada sección. El modo clásico conserva las transiciones de texto, pero desactiva este adorno.",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "Desplaza una chispa brillante por el aro y termina con un destello mayor que se desvanece. Al nivel máximo, el destello final aumenta y parpadea.",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("esMX", function() return { ["Trellis"] = "Celosía" } end)

-- Flat background selector.
RegisterLocaleBuilder("esMX", function() return { ["Solid Colour"] = "Color sólido" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("esMX", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "Elige el color y la transparencia del fondo. Color sólido usa este color directamente." } end)

-- Marine background selector.
RegisterLocaleBuilder("esMX", function() return { ["Coral"] = "Coral" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("esMX", function() return { ["Scratched Stone"] = "Piedra rayada" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("esMX", function() return { ["Reset Theme Hues"] = "Restablecer tonos del tema", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "Restaura los tonos predeterminados del fondo, marco y aro del retrato seleccionados. Conserva las demás preferencias guardadas." } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("esMX", function() return { ["Background Fill Mode"] = "Modo de relleno del fondo" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("esMX", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "Rellenar conserva las proporciones y recorta el exceso, Estirar adapta al marco y Mosaico repite la imagen." } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("esMX", function() return { ["Alliance Brick"] = "Ladrillos de la Alianza" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("esMX", function() return { ["Memory: %s"] = "Memoria: %s", ["Memory: unavailable"] = "Memoria: no disponible" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("esMX", function() return { ["Performance profiling enabled."] = "Medición de rendimiento activada.", ["Performance profiling disabled."] = "Medición de rendimiento desactivada.", ["Profiling is off. Use /glu perf on to record measurements."] = "La medición está desactivada. Usa /glu perf on para registrar mediciones." } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("esMX", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - iniciar/detener la medición (desactivada al recargar)", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - mostrar los diagnósticos de rendimiento registrados" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("esMX", function() return { ["Level History"] = "Historial de niveles", ["Compare account-wide bests"] = "Comparar récords de la cuenta", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "Compara los nuevos tiempos con el nivel más rápido registrado entre tus personajes del mismo modo de juego.", ["Character"] = "Personaje", ["Choose a character whose recorded level times you want to view."] = "Elige el personaje cuyos tiempos quieres consultar.", ["History mode"] = "Modo del historial", ["View Retail or Forever history. Records are kept separate."] = "Consulta el historial de Retail o Forever. Los registros se mantienen separados.", ["Reset this character's times"] = "Reiniciar tiempos de este personaje", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "Borra los tiempos y récords de este personaje en ambos modos. Conserva los demás personajes.", ["Fill sample times (20h)"] = "Tiempos de prueba (20 h)", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "Llena cada nivel con tiempos temporales de 20 horas. Los nuevos récords reemplazan las muestras sin sobrescribir el historial existente.", ["Clear sample history"] = "Borrar historial de prueba", ["Remove the temporary sample times and show real records again."] = "Elimina los tiempos temporales y vuelve a mostrar los registros reales.", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "Solo aparecen personajes con tiempos de nivel registrados. Los niveles sin datos muestran un guion.", ["Sample history (not saved)"] = "Historial de prueba (sin guardar)", ["Recorded: %d / %d"] = "Registrados: %d / %d", ["Total: %s"] = "Total: %s", ["Recorded time"] = "Tiempo registrado", ["Personal best"] = "Récord personal", ["Account best"] = "Récord de cuenta", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "Consulta los tiempos registrados y tus mejores tiempos entre personajes. Pasa el ratón por una fila para ver qué personaje logró el récord personal." } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("esMX", function() return { ["Milestone interval"] = "Intervalo de hitos", ["Every 5 levels"] = "Cada 5 niveles", ["Every 10 levels"] = "Cada 10 niveles", ["Every 20 levels"] = "Cada 20 niveles", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "Elige la frecuencia de las animaciones y capturas de pantalla de hitos. Las animaciones de nivel máximo tienen su propia opción.", ["Add celebration effects at the selected milestone interval."] = "Añade efectos en el intervalo de hitos seleccionado.", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Celebra los hitos seleccionados con anticipación del retrato, detalles más brillantes y efectos de estadísticas. El modo clásico desactiva estos efectos.", ["Choose a level up to 1000 that is a multiple of %d."] = "Elige un nivel de hasta 1000 que sea múltiplo de %d." } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("esMX", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "No se pudo preparar la ventana de nivel. Prueba /reload. Si vuelve a ocurrir, comunica este error: %s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "No se pudo reproducir el sonido elegido. Elige otro en Opciones > Sonido. Detalles: %s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "No se pudo mostrar la ventana de nivel. Prueba /reload. Si vuelve a ocurrir, comunica el error anterior.", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "El nivel máximo no está disponible. Espera a que termine la carga y vuelve a probar /glu maxlevel.", ["Paste the complete GLU profile export, then try again."] = "Pega la exportación completa del perfil GLU y vuelve a intentarlo.", ["Export the profile again from an up-to-date GLU installation."] = "Exporta de nuevo el perfil desde una instalación actualizada de GLU." } end)
RegisterLocaleBuilder("esMX", function() return { ["Ability Cost Size"] = "Tamaño del costo de habilidades", ["Adjust the size of ability prices for the current layout."] = "Ajusta el tamaño del precio de las habilidades en la disposición actual." } end)
RegisterLocaleBuilder("esMX", function() return { ["Learning cost: %s"] = "Costo de aprendizaje: %s", ["%d abilities"] = "%d habilidades", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "Muestra una ventana de prueba sin cambiar el historial. Haz clic derecho para elegir el número de habilidades." } end)
RegisterLocaleBuilder("esMX", function() return { ["Show prices in tooltips"] = "Mostrar precios al pasar el cursor", ["Show full learning costs when hovering over abilities."] = "Muestra el costo completo al pasar el cursor sobre las habilidades." } end)
RegisterLocaleBuilder("esMX", function() return { ["Contributors"] = "Colaboradores" } end)
RegisterLocaleBuilder("esMX", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "Error al capturar estadísticas: Los cambios esperados seguían sin aparecer tras varios intentos.",
    ["3D Portrait render failed: The player model did not load in time."] = "Error al mostrar el retrato 3D: El modelo del personaje no se cargó a tiempo.",
    ["3D Portrait render failed: Could not assign the player model."] = "Error al mostrar el retrato 3D: No se pudo asignar el modelo del personaje.",
} end)
RegisterLocaleBuilder("esMX", function() return { ["Theme sound"] = "Sonido del tema" } end)
RegisterLocaleBuilder("esMX", function() return {
    ["Idle motes sound"] = "Sonido de partículas ambientales",
    ["Fireworks sound"] = "Sonido de fuegos artificiales",
    ["Fade-in sound"] = "Sonido de entrada gradual",
    ["Fade-out sound"] = "Sonido de salida gradual",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "Ingresa un ID de archivo de sonido de WoW para sustituir este sonido. Ingresa 0 para quitar la sustitución.",
} end)
RegisterLocaleBuilder("esMX", function() return {
    ["Use Theme Sounds"] = "Usar sonidos del tema",
    ["Play the theme's animation sounds without changing your level-up sound."] = "Reproduce los sonidos de animación del tema sin cambiar tu sonido al subir de nivel.",
    ["Class-coloured portrait background"] = "Fondo del retrato con color de clase",
    ["Fill the background behind the 3D player portrait with your class colour."] = "Rellena el fondo del retrato 3D del personaje con el color de tu clase.",
} end)
RegisterLocaleBuilder("esMX", function() return { ["Stat glint sound"] = "Sonido del destello de estadísticas" } end)
RegisterLocaleBuilder("esMX", function() return { ["Screenshot every level"] = "Captura de pantalla en cada nivel", ["Take a screenshot after every real level-up."] = "Toma una captura de pantalla después de cada subida de nivel real.", ["Could not save the level-up screenshot."] = "No se pudo guardar la captura de pantalla de la subida de nivel." } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("esMX", function() return {
    ["Strength"] = "Fuerza", ["Agility"] = "Agilidad", ["Stamina"] = "Aguante", ["Intellect"] = "Intelecto", ["Spirit"] = "Espíritu",
    ["Level"] = "Nivel",
    ["Health"] = "Salud", ["Mana"] = "Maná", ["Default"] = "Predeterminado", ["%d pt"] = "%d pt",
    ["Rage"] = "Ira", ["Energy"] = "Energía", ["Focus"] = "Enfoque", ["Runic Power"] = "Poder rúnico", ["Power"] = "Recurso",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("esMX", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "Ocurrió un error (%s). Escribe /glu debugreport y envíame el informe.",
    ["Debug report"] = "Informe de depuración",
    ["No GnomeLevelUp errors have been recorded."] = "No se han registrado errores de GnomeLevelUp.",
    ["Stat capture"] = "Captura de estadísticas",
    ["3D portrait rendering"] = "Renderizado del retrato 3D",
    ["Level-up popup"] = "Ventana de subida de nivel",
    ["Screenshot"] = "Captura de pantalla",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("esMX", function() return {
    ["Complete trainer reporting"] = "Informes completos de instructores",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "Registra todos los precios legibles de los instructores de clase en modo de depuración. Exporta los precios ofrecidos con /glu trainerreport.",
    ["Clear all"] = "Borrar todo",
} end)
