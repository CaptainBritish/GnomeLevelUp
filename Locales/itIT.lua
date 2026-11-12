local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- itIT: Italiano. English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.

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

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("itIT", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Benvenuto in GnomeLevelUp! Dalla versione 1.4.0 non è più necessario scansionare manualmente gli istruttori: l’elenco è già incluso! Segnalami eventuali problemi su GitHub o Curseforge!",
} end)

-- Trainer-change monitoring and report export.
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

-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("itIT", function() return {
    ["Portrait pulse and starburst"] = "Impulso e bagliore del ritratto",
    ["Highlight new abilities"] = "Evidenzia nuove abilità",
    ["Emphasize stat gains"] = "Evidenzia aumenti delle statistiche",
    ["New ability"] = "Nuova abilità",
    ["Rank upgrade"] = "Aumento di grado",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("itIT", function() return {
    ["Portrait sparks"] = "Scintille del ritratto",
    ["New ability sparkles"] = "Scintille delle nuove abilità",
    ["Background embers"] = "Braci sullo sfondo",
    ["Frame edge glow"] = "Bagliore della cornice",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
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

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("itIT", function() return {
    ["Portrait and ring settle"] = "Assestamento di ritratto e cornice",
    ["Reveal dividers"] = "Comparsa dei separatori",
} end)
RegisterLocaleBuilder("itIT", function() return { ["Animated Elements"] = "Elementi animati" } end)
RegisterLocaleBuilder("itIT", function() return {
    ["Starburst opacity (%)"] = "Opacità della raggiera (%)",
    ["Portrait pulse opacity (%)"] = "Opacità dell’impulso del ritratto (%)",
    ["Frame edge glow opacity (%)"] = "Opacità del bagliore del bordo (%)",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Copy"] = "Copia",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Premi Ctrl+C per copiare. Il campo verrà poi svuotato.",
} end)

-- Profile controls and sharing messages.
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

-- Profile-sharing window.
RegisterLocaleBuilder("itIT", function() return {
    ["Profile name (optional)"] = "Nome del profilo (facoltativo)",
    ["Invalid profile string."] = "Stringa del profilo non valida.",
    ["Invalid profile settings."] = "Impostazioni del profilo non valide.",
} end)

-- Profile management.
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

-- First-run setup.
RegisterLocaleBuilder("itIT", function() return {
    ["GLU First Time Setup"] = "GLU — Configurazione iniziale",
    ["Finish setup"] = "Completa configurazione",
    ["Change these choices anytime in Options."] = "Puoi modificare queste scelte in qualsiasi momento nelle opzioni.",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("itIT", function() return {
    ["Show pet skills"] = "Mostra abilità dei famigli",
    ["Enable animations"] = "Abilita animazioni",
} end)

-- Setup heading.
RegisterLocaleBuilder("itIT", function() return { ["Welcome to GnomeLevelUp!"] = "Benvenuto in GnomeLevelUp!" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("itIT", function() return { ["Background animations"] = "Animazioni di sfondo" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("itIT", function() return { ["Horizontal layout"] = "Disposizione orizzontale" } end)
RegisterLocaleBuilder("itIT", function() return { ["Player 3D portrait"] = "Ritratto 3D del giocatore" } end)
RegisterLocaleBuilder("itIT", function() return { ["3D model rotation (degrees)"] = "Rotazione modello 3D (gradi)", ["3D model depth"] = "Profondità modello 3D", ["3D model horizontal position"] = "Posizione orizzontale modello 3D", ["3D model vertical position"] = "Posizione verticale modello 3D", ["3D model scale (%)"] = "Scala modello 3D (%)" } end)
RegisterLocaleBuilder("itIT", function() return { ["3D mask size (%)"] = "Dimensione maschera 3D (%)" } end)
RegisterLocaleBuilder("itIT", function() return { ["3D viewport size (%)"] = "Dimensione area di visualizzazione 3D (%)" } end)
RegisterLocaleBuilder("itIT", function() return { ["Milestone Animations"] = "Animazioni dei traguardi" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("itIT", function() return { ["Firework size (%)"] = "Dimensione fuochi d’artificio (%)", ["Firework opacity (%)"] = "Opacità fuochi d’artificio (%)" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("itIT", function() return { ["Frame inset (px)"] = "Margine della cornice (px)" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("itIT", function() return { ["Portrait ring glint"] = "Bagliore dell’anello del ritratto", ["Ability reveal shine"] = "Riflesso alla comparsa delle abilità", ["Milestone anticipation"] = "Anticipazione dei traguardi", ["Stat impact sparks"] = "Scintille dei miglioramenti", ["Background depth"] = "Profondità dello sfondo", ["Closing animation"] = "Animazione di chiusura", ["Milestone color transition"] = "Transizione colore dei traguardi" } end)
RegisterLocaleBuilder("itIT", function() return { ["Screenshot milestones"] = "Screenshot ai traguardi" } end)
RegisterLocaleBuilder("itIT", function() return { ["Portrait motes"] = "Particelle del ritratto", ["Background motes"] = "Particelle di sfondo" } end)
RegisterLocaleBuilder("itIT", function() return { ["3D Portraits may consume more memory."] = "I ritratti 3D possono consumare più memoria." } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("itIT", function() return {
    ["Shorten stat totals"] = "Abbrevia i totali delle statistiche",
    ["Relevant stats only"] = "Solo statistiche rilevanti",
    ["%sk"] = "%sk", ["%sm"] = "%sM", ["%sb"] = "%s mld",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("itIT", function() return { ["Uses game volume"] = "Usa il volume del gioco" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("itIT", function() return {
    ["Show faster leveling times"] = "Mostra i nuovi record di avanzamento di livello",
    ["Fastest level: %s"] = "Nuovo record: %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("itIT", function() return {
    ["Max Level Celebration"] = "Celebrazione del livello massimo",
    ["Time to max level: %s"] = "Tempo per il livello massimo: %s",
    ["%dd %02dh %02dm %02ds"] = "%dg %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Suono dell’impatto del ritratto",
    ["Starburst sound"] = "Suono del bagliore del ritratto",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("itIT", function() return {
    ["Time to Level: %s"] = "Tempo per salire di livello: %s",
    ["New fastest time!:"] = "Nuovo miglior tempo!:",
    ["New fastest time!: %s"] = "Nuovo miglior tempo!: %s",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Glint finishing spark"] = "Scintilla finale del riflesso",
    ["Portrait shine"] = "Bagliore del ritratto",
    ["Ring surges"] = "Scariche dell’anello",
    ["Max-level portrait sparks"] = "Scintille del ritratto al livello massimo",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["New Best Time!"] = "Nuovo miglior tempo!",
    ["Fastest Time: %s"] = "Miglior tempo: %s",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Abbreviate stat names"] = "Abbrevia i nomi delle statistiche",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["%sM %sk"] = "%sM %sk",
    ["Recorded level timers and best times reset for this character."] = "Tempi di livello e record salvati di questo personaggio azzerati.",
} end)

-- Classic Mode and first-time setup descriptions.
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

-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("itIT", function() return {
    ["Stat text size"] = "Dimensione del testo delle statistiche",
    ["Heading text size"] = "Dimensione dei titoli",
    ["Time to Level text size"] = "Dimensione del testo del tempo di livello",
    ["Level %d - %d"] = "Livelli %d - %d",
    ["Time for %d levels: %s"] = "Tempo per %d livelli: %s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
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

-- Shared descriptions for controller and standard Options.
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
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "Cattura una schermata quando un aumento di livello effettivo corrisponde all’intervallo dei traguardi selezionato.",
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

-- Minimap preview shortcut.
RegisterLocaleBuilder("itIT", function() return { ["Middle-click: Preview Level-Up"] = "Clic centrale: anteprima del passaggio di livello" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("itIT", function() return {
    ["Switch to secondary stats at"] = "Passa alle statistiche secondarie al",
    ["Choose the percentage of display time spent on primary stats."] = "Scegli la percentuale del tempo di visualizzazione dedicata alle statistiche principali.",
    ["Replace primary stats with secondary stats during the popup."] = "Sostituisce le statistiche principali con quelle secondarie durante l’avviso.",
    ["Right-click: Replay last level-up"] = "Clic destro: ripeti l’ultimo passaggio di livello",
    ["No recorded level-up to replay yet."] = "Nessun passaggio di livello registrato da ripetere.",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("itIT", function() return {
    ["Adjust the space between popup sections."] = "Regola lo spazio tra le sezioni dell’avviso.",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "Confronta i servizi degli istruttori con il catalogo incluso e propone un rapporto in caso di differenze.",
    ["Open saved trainer differences and instructions for exporting a report."] = "Apre le differenze salvate e le istruzioni per esportare un rapporto.",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "Include i grimori disponibili per tutti i demoni dello stregone, non solo il famiglio attivo.",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "Inserisci il percorso di un file OGG relativo all’addon per il suono personalizzato.",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "Scegli un suono personalizzato registrato da questo addon o SharedMedia.",
    ["Show advanced tuning controls, test commands and performance counters."] = "Mostra regolazioni avanzate, comandi di prova e contatori delle prestazioni.",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "Stampa i tempi misurati in chat. Attiva il debug per raccoglierli.",
    ["Clear performance counters before measuring another popup."] = "Azzera i contatori prima di misurare un altro avviso.",
    ["Choose automatic client detection or force Retail or Forever rules."] = "Scegli il rilevamento automatico del client oppure forza le regole Retail o Forever.",
    ["Update the displayed trainer-cache information."] = "Aggiorna le informazioni visualizzate sulla cache degli istruttori.",
    ["Enter a name to create a profile or rename the current one."] = "Inserisci un nome per creare un profilo o rinominare quello attuale.",
    ["Save the current options as a new profile with the entered name."] = "Salva le opzioni attuali in un nuovo profilo con il nome inserito.",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "Rinomina il profilo selezionato. Il profilo predefinito non può essere rinominato.",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "Elimina il profilo selezionato dopo conferma. Il profilo predefinito non può essere eliminato.",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "Ripristina le opzioni predefinite; conserva i tempi di livello e i rapporti salvati.",
    ["Move the 3D portrait closer to or farther from the camera."] = "Avvicina o allontana il ritratto 3D dalla telecamera.",
    ["Move the 3D portrait left or right inside its viewport."] = "Sposta il ritratto 3D a sinistra o destra nella sua area.",
    ["Move the 3D portrait up or down inside its viewport."] = "Sposta il ritratto 3D in alto o in basso nella sua area.",
    ["Turn the 3D portrait around its vertical axis."] = "Ruota il ritratto 3D intorno al suo asse verticale.",
    ["Change the size of the 3D character model."] = "Cambia le dimensioni del modello 3D del personaggio.",
    ["Change the circular mask that clips the 3D portrait."] = "Cambia la maschera circolare che ritaglia il ritratto 3D.",
    ["Change the 3D rendering area around the portrait."] = "Cambia l’area di rendering 3D intorno al ritratto.",
    ["Resize the ring artwork without resizing the portrait."] = "Ridimensiona la grafica dell’anello senza ridimensionare il ritratto.",
    ["Move the ring artwork left or right."] = "Sposta l’anello a sinistra o destra.",
    ["Move the ring artwork up or down."] = "Sposta l’anello in alto o in basso.",
    ["Adjust the empty inset between textured borders and popup content."] = "Regola il margine vuoto tra i bordi con texture e il contenuto dell’avviso.",
    ["Mirror this frame piece horizontally."] = "Specchia orizzontalmente questa parte della cornice.",
    ["Mirror this frame piece vertically."] = "Specchia verticalmente questa parte della cornice.",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "Cambia il colore dell’elemento indicato. I colori di classe possono sostituire i colori di risalto.",
    ["Tint this individual frame piece."] = "Colora solo questa singola parte della cornice.",
    ["Rotate this individual frame piece."] = "Ruota solo questa singola parte della cornice.",
    ["Set the number of particles for this effect. Zero hides them."] = "Imposta il numero di particelle dell’effetto. Zero le nasconde.",
    ["Resize this effect's particles as a percentage of their normal size."] = "Ridimensiona le particelle come percentuale delle dimensioni normali.",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "Imposta l’opacità delle particelle. Zero le rende invisibili.",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "Imposta l’opacità dell’animazione indicata. Zero la rende invisibile.",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "Riproduce un suono quando parte l’animazione. Inserisci un ID di file audio WoW; 0 disattiva questo suono.",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Celebra ogni traguardo di dieci livelli con un’anticipazione del ritratto, dettagli più luminosi ed effetti sulle statistiche. La modalità classica disattiva questi ornamenti.",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "Al livello massimo aggiunge fuochi curvi nei colori di classe, scintille sull’anello e più particelle sullo sfondo. La modalità classica disattiva questi effetti.",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "Fa pulsare l’anello e rivela una stella crescente dietro il ritratto. Traguardi e livello massimo aggiungono anche un riflesso periodico sul ritratto.",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "Aggiunge un riflesso iniziale, un bagliore e scintille alle abilità appena apprese. Gli aumenti di grado restano senza evidenziazione.",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "Anima i totali a partire dai vecchi valori, poi illumina i numeri modificati. I traguardi aggiungono scintille al termine del conteggio.",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "Rilascia piccole luci fluttuanti intorno al ritratto dopo la stella. Richiede il pulso e la stella del ritratto.",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "Mostra particelle che salgono dietro l’avviso. Traguardi e livello massimo ne aumentano la densità; al livello massimo sono anche più veloci.",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "Fa scorrere un bagliore che svanisce sui bordi con texture durante l’apertura. Non disponibile con Moderno.",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "Inizia con il ritratto leggermente ingrandito e lo riporta dolcemente alle dimensioni normali. I traguardi aggiungono un breve lampo anticipatorio.",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "Espande i divisori quando entra ogni sezione. La modalità classica mantiene le transizioni del testo, ma disattiva questo ornamento.",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "Fa scorrere una scintilla luminosa sull’anello, terminando con un bagliore più grande che svanisce. Al livello massimo la scintilla finale cresce e tremola.",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("itIT", function() return { ["Trellis"] = "Graticcio" } end)

-- Flat background selector.
RegisterLocaleBuilder("itIT", function() return { ["Solid Colour"] = "Colore uniforme" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("itIT", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "Scegli colore e trasparenza dello sfondo. Colore uniforme usa direttamente questo colore." } end)

-- Marine background selector.
RegisterLocaleBuilder("itIT", function() return { ["Coral"] = "Corallo" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("itIT", function() return { ["Scratched Stone"] = "Pietra graffiata" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("itIT", function() return { ["Reset Theme Hues"] = "Ripristina tonalità del tema", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "Ripristina le tonalità predefinite di sfondo, cornice e anello del ritratto selezionati. Conserva le altre preferenze salvate." } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("itIT", function() return { ["Background Fill Mode"] = "Modalità riempimento sfondo" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("itIT", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "Riempi mantiene le proporzioni e ritaglia gli eccessi, Allunga adatta alla cornice e Ripeti ripete il motivo." } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("itIT", function() return { ["Alliance Brick"] = "Mattoni dell’Alleanza" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("itIT", function() return { ["Memory: %s"] = "Memoria: %s", ["Memory: unavailable"] = "Memoria: non disponibile" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("itIT", function() return { ["Performance profiling enabled."] = "Profilazione prestazioni attivata.", ["Performance profiling disabled."] = "Profilazione prestazioni disattivata.", ["Profiling is off. Use /glu perf on to record measurements."] = "La profilazione è disattivata. Usa /glu perf on per registrare misurazioni." } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("itIT", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - avvia/arresta la profilazione (disattivata al ricaricamento)", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - mostra la diagnostica prestazioni registrata" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("itIT", function() return { ["Level History"] = "Cronologia livelli", ["Compare account-wide bests"] = "Confronta i record dell’account", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "Confronta i nuovi tempi con il livello più rapido registrato tra i personaggi nella stessa modalità di gioco.", ["Character"] = "Personaggio", ["Choose a character whose recorded level times you want to view."] = "Scegli il personaggio di cui consultare i tempi.", ["History mode"] = "Modalità cronologia", ["View Retail or Forever history. Records are kept separate."] = "Mostra la cronologia Retail o Forever. I dati restano separati.", ["Reset this character's times"] = "Azzera i tempi del personaggio", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "Cancella tempi e record di questo personaggio in entrambe le modalità. Conserva gli altri personaggi.", ["Fill sample times (20h)"] = "Tempi di prova (20 ore)", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "Riempie ogni livello con tempi temporanei di 20 ore. I nuovi record sostituiscono gli esempi senza sovrascrivere la cronologia esistente.", ["Clear sample history"] = "Cancella cronologia di prova", ["Remove the temporary sample times and show real records again."] = "Rimuove i tempi temporanei e mostra di nuovo i dati reali.", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "Sono elencati solo i personaggi con tempi di livello registrati. I livelli mancanti mostrano un trattino.", ["Sample history (not saved)"] = "Cronologia di prova (non salvata)", ["Recorded: %d / %d"] = "Registrati: %d / %d", ["Total: %s"] = "Totale: %s", ["Recorded time"] = "Tempo registrato", ["Personal best"] = "Record personale", ["Account best"] = "Record dell’account", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "Consulta i tempi registrati e i tuoi record tra tutti i personaggi. Passa su una riga per vedere quale personaggio ha stabilito il record personale." } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("itIT", function() return { ["Milestone interval"] = "Intervallo traguardi", ["Every 5 levels"] = "Ogni 5 livelli", ["Every 10 levels"] = "Ogni 10 livelli", ["Every 20 levels"] = "Ogni 20 livelli", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "Scegli la frequenza delle animazioni e delle schermate dei traguardi. Le animazioni del livello massimo hanno un’opzione separata.", ["Add celebration effects at the selected milestone interval."] = "Aggiunge effetti ai traguardi selezionati.", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Festeggia i traguardi selezionati con anticipazione del ritratto, accenti più luminosi ed effetti delle statistiche. La modalità classica disattiva questi effetti.", ["Choose a level up to 1000 that is a multiple of %d."] = "Scegli un livello fino a 1000 che sia multiplo di %d." } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("itIT", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "Impossibile preparare la finestra del livello. Prova /reload. Se ricapita, segnala questo errore: %s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "Impossibile riprodurre il suono scelto. Scegline un altro in Opzioni > Suono. Dettagli: %s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "Impossibile mostrare la finestra del livello. Prova /reload. Se ricapita, segnala l’errore qui sopra.", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "Il livello massimo non è disponibile. Attendi la fine del caricamento e riprova /glu maxlevel.", ["Paste the complete GLU profile export, then try again."] = "Incolla l’esportazione completa del profilo GLU e riprova.", ["Export the profile again from an up-to-date GLU installation."] = "Esporta di nuovo il profilo da un’installazione aggiornata di GLU." } end)
RegisterLocaleBuilder("itIT", function() return { ["Ability Cost Size"] = "Dimensione del costo delle abilità", ["Adjust the size of ability prices for the current layout."] = "Regola la dimensione del prezzo delle abilità nella disposizione attuale." } end)
RegisterLocaleBuilder("itIT", function() return { ["Learning cost: %s"] = "Costo di apprendimento: %s", ["%d abilities"] = "%d abilità", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "Mostra un’anteprima senza modificare la cronologia. Fai clic destro per scegliere il numero di abilità." } end)
RegisterLocaleBuilder("itIT", function() return { ["Show prices in tooltips"] = "Mostra i prezzi nei suggerimenti", ["Show full learning costs when hovering over abilities."] = "Mostra il costo completo al passaggio sulle abilità." } end)
RegisterLocaleBuilder("itIT", function() return { ["Contributors"] = "Collaboratori" } end)
RegisterLocaleBuilder("itIT", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "Acquisizione delle statistiche non riuscita: Le variazioni attese mancavano ancora dopo vari tentativi.",
    ["3D Portrait render failed: The player model did not load in time."] = "Visualizzazione del ritratto 3D non riuscita: Il modello del personaggio non si è caricato in tempo.",
    ["3D Portrait render failed: Could not assign the player model."] = "Visualizzazione del ritratto 3D non riuscita: Impossibile assegnare il modello del personaggio.",
} end)
RegisterLocaleBuilder("itIT", function() return { ["Theme sound"] = "Suono del tema" } end)
RegisterLocaleBuilder("itIT", function() return {
    ["Idle motes sound"] = "Suono delle particelle ambientali",
    ["Fireworks sound"] = "Suono dei fuochi d’artificio",
    ["Fade-in sound"] = "Suono della dissolvenza in entrata",
    ["Fade-out sound"] = "Suono della dissolvenza in uscita",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "Inserisci l’ID di un file audio di WoW per sostituire questo suono. Inserisci 0 per annullare la sostituzione.",
} end)
RegisterLocaleBuilder("itIT", function() return {
    ["Use Theme Sounds"] = "Usa i suoni del tema",
    ["Play the theme's animation sounds without changing your level-up sound."] = "Riproduce i suoni delle animazioni del tema senza cambiare il suono dell’avanzamento di livello.",
    ["Class-coloured portrait background"] = "Sfondo del ritratto con colore di classe",
    ["Fill the background behind the 3D player portrait with your class colour."] = "Colora lo sfondo dietro il ritratto 3D del personaggio con il colore della tua classe.",
} end)
RegisterLocaleBuilder("itIT", function() return { ["Stat glint sound"] = "Suono del bagliore delle statistiche" } end)
RegisterLocaleBuilder("itIT", function() return { ["Screenshot every level"] = "Schermata a ogni livello", ["Take a screenshot after every real level-up."] = "Cattura una schermata dopo ogni aumento di livello effettivo.", ["Could not save the level-up screenshot."] = "Impossibile salvare la schermata dell’aumento di livello." } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("itIT", function() return {
    ["Strength"] = "Forza", ["Agility"] = "Agilità", ["Stamina"] = "Tempra", ["Intellect"] = "Intelletto", ["Spirit"] = "Spirito",
    ["Level"] = "Livello",
    ["Health"] = "Salute", ["Mana"] = "Mana", ["Default"] = "Predefinito", ["%d pt"] = "%d pt",
    ["Rage"] = "Rabbia", ["Energy"] = "Energia", ["Focus"] = "Focus", ["Runic Power"] = "Potenza runica", ["Power"] = "Risorsa",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("itIT", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "Si è verificato un errore (%s). Digita /glu debugreport e inviami il rapporto!",
    ["Debug report"] = "Rapporto di debug",
    ["No GnomeLevelUp errors have been recorded."] = "Non sono stati registrati errori di GnomeLevelUp.",
    ["Stat capture"] = "Acquisizione delle statistiche",
    ["3D portrait rendering"] = "Rendering del ritratto 3D",
    ["Level-up popup"] = "Finestra di aumento di livello",
    ["Screenshot"] = "Screenshot",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("itIT", function() return {
    ["Complete trainer reporting"] = "Rapporti completi degli istruttori",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "Registra tutti i prezzi leggibili degli istruttori di classe in modalità debug. Esporta i prezzi offerti con /glu trainerreport.",
    ["Clear all"] = "Cancella tutto",
} end)
