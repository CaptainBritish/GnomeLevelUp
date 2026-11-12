local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- deDE: Deutsch. English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.

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

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("deDE", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Willkommen bei GnomeLevelUp! Seit Version 1.4.0 musst du Lehrer nicht mehr manuell scannen: Die Liste ist bereits enthalten! Bitte melde mir alle auftretenden Probleme auf GitHub oder Curseforge!",
} end)

-- Trainer-change monitoring and report export.
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

-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("deDE", function() return {
    ["Portrait pulse and starburst"] = "Porträtpuls und Strahlenkranz",
    ["Highlight new abilities"] = "Neue Fähigkeiten hervorheben",
    ["Emphasize stat gains"] = "Attributsgewinne hervorheben",
    ["New ability"] = "Neue Fähigkeit",
    ["Rank upgrade"] = "Rangaufwertung",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("deDE", function() return {
    ["Portrait sparks"] = "Porträtfunken",
    ["New ability sparkles"] = "Funkeln neuer Fähigkeiten",
    ["Background embers"] = "Glut im Hintergrund",
    ["Frame edge glow"] = "Rahmenleuchten",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
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

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("deDE", function() return {
    ["Portrait and ring settle"] = "Porträt und Ring sanft einrasten",
    ["Reveal dividers"] = "Trennlinien einblenden",
} end)
RegisterLocaleBuilder("deDE", function() return { ["Animated Elements"] = "Animierte Elemente" } end)
RegisterLocaleBuilder("deDE", function() return {
    ["Starburst opacity (%)"] = "Deckkraft des Strahlenkranzes (%)",
    ["Portrait pulse opacity (%)"] = "Deckkraft des Porträtimpulses (%)",
    ["Frame edge glow opacity (%)"] = "Deckkraft des Rahmenleuchtens (%)",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Copy"] = "Kopieren",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Drücke Strg+C zum Kopieren. Danach wird das Feld geleert.",
} end)

-- Profile controls and sharing messages.
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

-- Profile-sharing window.
RegisterLocaleBuilder("deDE", function() return {
    ["Profile name (optional)"] = "Profilname (optional)",
    ["Invalid profile string."] = "Ungültige Profilzeichenfolge.",
    ["Invalid profile settings."] = "Ungültige Profileinstellungen.",
} end)

-- Profile management.
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

-- First-run setup.
RegisterLocaleBuilder("deDE", function() return {
    ["GLU First Time Setup"] = "GLU — Ersteinrichtung",
    ["Finish setup"] = "Einrichtung abschließen",
    ["Change these choices anytime in Options."] = "Diese Auswahl kann jederzeit in den Optionen geändert werden.",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("deDE", function() return {
    ["Show pet skills"] = "Begleiterfähigkeiten anzeigen",
    ["Enable animations"] = "Animationen aktivieren",
} end)

-- Setup heading.
RegisterLocaleBuilder("deDE", function() return { ["Welcome to GnomeLevelUp!"] = "Willkommen bei GnomeLevelUp!" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("deDE", function() return { ["Background animations"] = "Hintergrundanimationen" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("deDE", function() return { ["Horizontal layout"] = "Horizontales Layout" } end)
RegisterLocaleBuilder("deDE", function() return { ["Player 3D portrait"] = "3D-Spielerporträt" } end)
RegisterLocaleBuilder("deDE", function() return { ["3D model rotation (degrees)"] = "3D-Modelldrehung (Grad)", ["3D model depth"] = "3D-Modelltiefe", ["3D model horizontal position"] = "Horizontale 3D-Modellposition", ["3D model vertical position"] = "Vertikale 3D-Modellposition", ["3D model scale (%)"] = "3D-Modellskalierung (%)" } end)
RegisterLocaleBuilder("deDE", function() return { ["3D mask size (%)"] = "3D-Maskengröße (%)" } end)
RegisterLocaleBuilder("deDE", function() return { ["3D viewport size (%)"] = "3D-Ansichtsgröße (%)" } end)
RegisterLocaleBuilder("deDE", function() return { ["Milestone Animations"] = "Meilensteinanimationen" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("deDE", function() return { ["Firework size (%)"] = "Feuerwerksgröße (%)", ["Firework opacity (%)"] = "Feuerwerksdeckkraft (%)" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("deDE", function() return { ["Frame inset (px)"] = "Rahmeninnenabstand (px)" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("deDE", function() return { ["Portrait ring glint"] = "Glanz am Porträtring", ["Ability reveal shine"] = "Glanz beim Erscheinen von Fähigkeiten", ["Milestone anticipation"] = "Meilenstein-Vorbereitung", ["Stat impact sparks"] = "Funken bei Attributsgewinnen", ["Background depth"] = "Hintergrundtiefe", ["Closing animation"] = "Schließanimation", ["Milestone color transition"] = "Meilenstein-Farbübergang" } end)
RegisterLocaleBuilder("deDE", function() return { ["Screenshot milestones"] = "Screenshots bei Meilensteinen" } end)
RegisterLocaleBuilder("deDE", function() return { ["Portrait motes"] = "Porträtpartikel", ["Background motes"] = "Hintergrundpartikel" } end)
RegisterLocaleBuilder("deDE", function() return { ["3D Portraits may consume more memory."] = "3D-Porträts können mehr Arbeitsspeicher verbrauchen." } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("deDE", function() return {
    ["Shorten stat totals"] = "Attributsummen abkürzen",
    ["Relevant stats only"] = "Nur relevante Attribute",
    ["%sk"] = "%s Tsd.", ["%sm"] = "%s Mio.", ["%sb"] = "%s Mrd.",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("deDE", function() return { ["Uses game volume"] = "Verwendet die Spiellautstärke" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("deDE", function() return {
    ["Show faster leveling times"] = "Neue Rekordzeiten beim Stufenaufstieg anzeigen",
    ["Fastest level: %s"] = "Neue Bestzeit: %s",
    ["%dh %02dm %02ds"] = "%dStd. %02dMin. %02dSek.", ["%dm %02ds"] = "%dMin. %02dSek.", ["%ds"] = "%dSek.",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("deDE", function() return {
    ["Max Level Celebration"] = "Feier der Maximalstufe",
    ["Time to max level: %s"] = "Zeit bis zur Höchststufe: %s",
    ["%dd %02dh %02dm %02ds"] = "%dT. %02dStd. %02dMin. %02dSek.",
    ["Portrait impact sound"] = "Sound des Porträtimpulses",
    ["Starburst sound"] = "Sound des Sternenleuchtens",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("deDE", function() return {
    ["Time to Level: %s"] = "Zeit bis zum Stufenaufstieg: %s",
    ["New fastest time!:"] = "Neue Bestzeit!:",
    ["New fastest time!: %s"] = "Neue Bestzeit!: %s",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Glint finishing spark"] = "Abschließender Glanzfunke",
    ["Portrait shine"] = "Porträtglanz",
    ["Ring surges"] = "Ringentladungen",
    ["Max-level portrait sparks"] = "Porträtfunken auf Maximalstufe",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["New Best Time!"] = "Neue Bestzeit!",
    ["Fastest Time: %s"] = "Bestzeit: %s",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Abbreviate stat names"] = "Attributnamen abkürzen",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["%sM %sk"] = "%s Mio. %s Tsd.",
    ["Recorded level timers and best times reset for this character."] = "Gespeicherte Stufenzeiten und Bestzeiten dieses Charakters wurden zurückgesetzt.",
} end)

-- Classic Mode and first-time setup descriptions.
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

-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("deDE", function() return {
    ["Stat text size"] = "Attributtextgröße",
    ["Heading text size"] = "Überschriftengröße",
    ["Time to Level text size"] = "Textgröße der Stufenzeit",
    ["Level %d - %d"] = "Stufen %d - %d",
    ["Time for %d levels: %s"] = "Zeit für %d Stufen: %s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
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

-- Shared descriptions for controller and standard Options.
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
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "Erstelle einen Screenshot, wenn ein echter Stufenaufstieg dem gewählten Meilensteinintervall entspricht.",
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

-- Minimap preview shortcut.
RegisterLocaleBuilder("deDE", function() return { ["Middle-click: Preview Level-Up"] = "Mittelklick: Stufenaufstieg testen" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("deDE", function() return {
    ["Switch to secondary stats at"] = "Zu Sekundärwerten wechseln bei",
    ["Choose the percentage of display time spent on primary stats."] = "Wähle den Anteil der Anzeigedauer für die Hauptattribute.",
    ["Replace primary stats with secondary stats during the popup."] = "Ersetzt die Hauptattribute während der Anzeige durch Sekundärwerte.",
    ["Right-click: Replay last level-up"] = "Rechtsklick: letzten Stufenaufstieg erneut anzeigen",
    ["No recorded level-up to replay yet."] = "Noch kein Stufenaufstieg zum erneuten Anzeigen gespeichert.",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("deDE", function() return {
    ["Adjust the space between popup sections."] = "Passt den Abstand zwischen den Abschnitten an.",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "Vergleicht Lehrerangebote mit dem enthaltenen Katalog und bietet bei Abweichungen einen Bericht an.",
    ["Open saved trainer differences and instructions for exporting a report."] = "Öffnet gespeicherte Abweichungen und Hinweise zum Exportieren eines Berichts.",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "Zeigt verfügbare Hexenmeistergrimoires für alle Dämonen statt nur für den aktiven Begleiter.",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "Gib einen zum Addon relativen OGG-Dateipfad für den eigenen Stufenaufstiegston ein.",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "Wähle einen von diesem Addon oder SharedMedia registrierten eigenen Klang.",
    ["Show advanced tuning controls, test commands and performance counters."] = "Zeigt erweiterte Einstellungen, Testbefehle und Leistungszähler.",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "Gibt gemessene Laufzeiten im Chat aus. Zum Erfassen muss der Debugmodus aktiv sein.",
    ["Clear performance counters before measuring another popup."] = "Löscht die Leistungszähler vor der nächsten Messung.",
    ["Choose automatic client detection or force Retail or Forever rules."] = "Wähle automatische Client-Erkennung oder erzwinge Retail- beziehungsweise Forever-Regeln.",
    ["Update the displayed trainer-cache information."] = "Aktualisiert die angezeigten Informationen zum Lehrer-Cache.",
    ["Enter a name to create a profile or rename the current one."] = "Gib einen Namen für ein neues Profil oder zum Umbenennen des aktuellen Profils ein.",
    ["Save the current options as a new profile with the entered name."] = "Speichert die aktuellen Einstellungen unter dem eingegebenen Profilnamen.",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "Benennt das ausgewählte Profil um. Das Standardprofil kann nicht umbenannt werden.",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "Löscht das ausgewählte Profil nach Bestätigung. Das Standardprofil kann nicht gelöscht werden.",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "Setzt Optionen zurück; gespeicherte Stufenzeiten und Lehrerberichte bleiben erhalten.",
    ["Move the 3D portrait closer to or farther from the camera."] = "Bewegt das 3D-Porträt zur Kamera hin oder von ihr weg.",
    ["Move the 3D portrait left or right inside its viewport."] = "Verschiebt das 3D-Porträt innerhalb seines Anzeigebereichs nach links oder rechts.",
    ["Move the 3D portrait up or down inside its viewport."] = "Verschiebt das 3D-Porträt innerhalb seines Anzeigebereichs nach oben oder unten.",
    ["Turn the 3D portrait around its vertical axis."] = "Dreht das 3D-Porträt um seine senkrechte Achse.",
    ["Change the size of the 3D character model."] = "Ändert die Größe des 3D-Charaktermodells.",
    ["Change the circular mask that clips the 3D portrait."] = "Ändert die kreisförmige Maske, die das 3D-Porträt zuschneidet.",
    ["Change the 3D rendering area around the portrait."] = "Ändert den 3D-Renderbereich um das Porträt.",
    ["Resize the ring artwork without resizing the portrait."] = "Ändert die Ringgrafikgröße ohne das Porträt zu vergrößern.",
    ["Move the ring artwork left or right."] = "Verschiebt die Ringgrafik nach links oder rechts.",
    ["Move the ring artwork up or down."] = "Verschiebt die Ringgrafik nach oben oder unten.",
    ["Adjust the empty inset between textured borders and popup content."] = "Ändert den freien Innenabstand zwischen Texturrand und Inhalt.",
    ["Mirror this frame piece horizontally."] = "Spiegelt dieses Rahmenteil waagerecht.",
    ["Mirror this frame piece vertically."] = "Spiegelt dieses Rahmenteil senkrecht.",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "Ändert die Farbe des genannten Elements. Klassenfarben können Akzentfarben überschreiben.",
    ["Tint this individual frame piece."] = "Färbt nur dieses einzelne Rahmenteil ein.",
    ["Rotate this individual frame piece."] = "Dreht nur dieses einzelne Rahmenteil.",
    ["Set the number of particles for this effect. Zero hides them."] = "Legt die Partikelanzahl dieses Effekts fest. Null blendet sie aus.",
    ["Resize this effect's particles as a percentage of their normal size."] = "Ändert die Partikelgröße als Prozentsatz ihrer normalen Größe.",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "Legt die Deckkraft der Partikel fest. Null macht sie unsichtbar.",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "Legt die Deckkraft der genannten Animation fest. Null macht sie unsichtbar.",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "Spielt beim Auslösen dieser Animation einen Klang. Gib eine WoW-Sounddatei-ID ein; 0 schaltet diesen Klang aus.",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Feiert jeden Zehnerschritt mit einer Porträt-Voranimation, helleren Akzenten und zusätzlichen Werteffekten. Der klassische Modus schaltet diese Verzierungen aus.",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "Fügt auf Maximalstufe gebogene Feuerwerke in Klassenfarben, Ringfunken und stärkere Hintergrundpartikel hinzu. Der klassische Modus deaktiviert diese Effekte.",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "Lässt den Ring pulsieren und einen wachsenden Stern hinter dem Porträt erscheinen. Meilensteine und Maximalstufe erhalten außerdem wiederkehrenden Porträtglanz.",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "Verleiht neu erlernten Fähigkeiten einen Einblendglanz, Leuchten und funkelnde Partikel. Rangaufwertungen bleiben unbetont.",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "Zählt Werte vom alten Stand hoch und lässt geänderte Zahlen aufleuchten. Bei Meilensteinen erscheinen nach dem Zählen außerdem Funken.",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "Lässt nach dem Stern kleine Lichter um das Porträt schweben. Benötigt Porträtpuls und Sterneneffekt.",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "Zeigt aufsteigende Partikel hinter dem Fenster. Meilensteine und Maximalstufe erhöhen die Dichte; auf Maximalstufe steigen sie auch schneller.",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "Lässt beim Öffnen ein abklingendes Leuchten über die Texturränder laufen. Für Modern nicht verfügbar.",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "Beginnt mit einem leicht vergrößerten Porträt und verkleinert es sanft auf Normalgröße. Meilensteine ergänzen einen kurzen Vorblitz.",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "Breitet die Trennlinien beim Einblenden jedes Abschnitts aus. Der klassische Modus behält Textübergänge bei, deaktiviert aber diese Verzierung.",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "Lässt einen hellen Funken um den Porträtring laufen und mit einem größeren, verblassenden Blitz enden. Auf Maximalstufe wird der Schlussfunke größer und flackert.",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("deDE", function() return { ["Trellis"] = "Rankgitter" } end)

-- Flat background selector.
RegisterLocaleBuilder("deDE", function() return { ["Solid Colour"] = "Einfarbig" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("deDE", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "Wählt Hintergrundfarbe und Transparenz. Einfarbig verwendet diese Farbe direkt." } end)

-- Marine background selector.
RegisterLocaleBuilder("deDE", function() return { ["Coral"] = "Koralle" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("deDE", function() return { ["Scratched Stone"] = "Zerkratzter Stein" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("deDE", function() return { ["Reset Theme Hues"] = "Designfarben zurücksetzen", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "Setzt die Farben von ausgewähltem Hintergrund, Rahmen und Porträtring zurück. Andere gespeicherte Farbeinstellungen bleiben erhalten." } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("deDE", function() return { ["Background Fill Mode"] = "Hintergrundfüllmodus" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("deDE", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "Füllen erhält die Proportionen und beschneidet den Überstand, Strecken passt an den Rahmen an und Kacheln wiederholt das Bild." } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("deDE", function() return { ["Alliance Brick"] = "Allianz-Ziegel" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("deDE", function() return { ["Memory: %s"] = "Speicher: %s", ["Memory: unavailable"] = "Speicher: nicht verfügbar" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("deDE", function() return { ["Performance profiling enabled."] = "Leistungsprofilierung aktiviert.", ["Performance profiling disabled."] = "Leistungsprofilierung deaktiviert.", ["Profiling is off. Use /glu perf on to record measurements."] = "Profilierung ist aus. Mit /glu perf on werden Messungen aufgezeichnet." } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("deDE", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - Profilierung starten/stoppen (nach Neuladen aus)", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - aufgezeichnete Leistungsdiagnose anzeigen" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("deDE", function() return { ["Level History"] = "Stufenverlauf", ["Compare account-wide bests"] = "Accountrekorde vergleichen", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "Vergleicht neue Stufenzeiten mit der schnellsten aufgezeichneten Stufe deiner Charaktere im selben Spielmodus.", ["Character"] = "Charakter", ["Choose a character whose recorded level times you want to view."] = "Wähle den Charakter, dessen Stufenzeiten du ansehen möchtest.", ["History mode"] = "Verlaufsmodus", ["View Retail or Forever history. Records are kept separate."] = "Zeigt den Verlauf für Retail oder Forever. Aufzeichnungen bleiben getrennt.", ["Reset this character's times"] = "Zeiten dieses Charakters löschen", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "Löscht Zeiten und Bestzeiten dieses Charakters in beiden Modi. Andere Charaktere bleiben erhalten.", ["Fill sample times (20h)"] = "Testzeiten füllen (20 Std.)", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "Füllt jede Stufe mit vorläufigen Zeiten von 20 Stunden. Neue Rekorde ersetzen die Testzeiten; vorhandene Aufzeichnungen bleiben erhalten.", ["Clear sample history"] = "Testverlauf löschen", ["Remove the temporary sample times and show real records again."] = "Entfernt vorübergehende Testzeiten und zeigt echte Aufzeichnungen an.", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "Nur Charaktere mit erfassten Stufenzeiten werden aufgelistet. Fehlende Stufen werden als Strich angezeigt.", ["Sample history (not saved)"] = "Testverlauf (nicht gespeichert)", ["Recorded: %d / %d"] = "Erfasst: %d / %d", ["Total: %s"] = "Gesamt: %s", ["Recorded time"] = "Erfasste Zeit", ["Personal best"] = "Persönliche Bestzeit", ["Account best"] = "Accountbestzeit", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "Zeigt erfasste Stufenzeiten und deine Bestzeiten über alle Charaktere. Fahre über eine Zeile, um den Charakter mit der persönlichen Bestzeit zu sehen." } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("deDE", function() return { ["Milestone interval"] = "Meilensteinintervall", ["Every 5 levels"] = "Alle 5 Stufen", ["Every 10 levels"] = "Alle 10 Stufen", ["Every 20 levels"] = "Alle 20 Stufen", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "Wähle, wie oft Meilensteinanimationen und Screenshots ausgelöst werden. Animationen für die Maximalstufe haben eine eigene Option.", ["Add celebration effects at the selected milestone interval."] = "Fügt Feiereffekte im gewählten Meilensteinintervall hinzu.", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Feiert das gewählte Intervall mit Porträtvorbereitung, helleren Akzenten und zusätzlichen Werteffekten. Der klassische Modus deaktiviert diese Effekte.", ["Choose a level up to 1000 that is a multiple of %d."] = "Wähle eine Stufe bis 1000, die ein Vielfaches von %d ist." } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("deDE", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "Das Stufenfenster konnte nicht vorbereitet werden. Versuche /reload. Falls es erneut auftritt, melde diesen Fehler: %s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "Der gewählte Klang konnte nicht abgespielt werden. Wähle einen anderen unter Optionen > Klang. Details: %s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "Das Stufenfenster konnte nicht angezeigt werden. Versuche /reload. Falls es erneut auftritt, melde den obigen Fehler.", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "Die Höchststufe ist nicht verfügbar. Warte, bis das Laden abgeschlossen ist, und versuche /glu maxlevel erneut.", ["Paste the complete GLU profile export, then try again."] = "Füge den vollständigen GLU-Profilexport ein und versuche es erneut.", ["Export the profile again from an up-to-date GLU installation."] = "Exportiere das Profil erneut mit einer aktuellen GLU-Installation." } end)
RegisterLocaleBuilder("deDE", function() return { ["Ability Cost Size"] = "Schriftgröße der Fähigkeitskosten", ["Adjust the size of ability prices for the current layout."] = "Passt die Schriftgröße der Fähigkeitskosten im aktuellen Layout an." } end)
RegisterLocaleBuilder("deDE", function() return { ["Learning cost: %s"] = "Lernkosten: %s", ["%d abilities"] = "%d Fähigkeiten", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "Zeigt eine Testvorschau, ohne den Stufenverlauf zu ändern. Wähle die Anzahl der Fähigkeiten per Rechtsklick." } end)
RegisterLocaleBuilder("deDE", function() return { ["Show prices in tooltips"] = "Preise in Tooltips anzeigen", ["Show full learning costs when hovering over abilities."] = "Zeigt die vollständigen Lernkosten beim Überfahren der Fähigkeiten an." } end)
RegisterLocaleBuilder("deDE", function() return { ["Contributors"] = "Mitwirkende" } end)
RegisterLocaleBuilder("deDE", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "Attributserfassung fehlgeschlagen: Die erwarteten Attributsänderungen fehlten auch nach mehreren Versuchen.",
    ["3D Portrait render failed: The player model did not load in time."] = "Darstellung des 3D-Porträts fehlgeschlagen: Das Charaktermodell wurde nicht rechtzeitig geladen.",
    ["3D Portrait render failed: Could not assign the player model."] = "Darstellung des 3D-Porträts fehlgeschlagen: Das Charaktermodell konnte nicht zugewiesen werden.",
} end)
RegisterLocaleBuilder("deDE", function() return { ["Theme sound"] = "Designsound" } end)
RegisterLocaleBuilder("deDE", function() return {
    ["Idle motes sound"] = "Klang der Umgebungspartikel",
    ["Fireworks sound"] = "Feuerwerksklang",
    ["Fade-in sound"] = "Einblendklang",
    ["Fade-out sound"] = "Ausblendklang",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "Gib eine WoW-Sounddatei-ID ein, um diesen Klang zu ersetzen. Mit 0 entfernst du die Überschreibung.",
} end)
RegisterLocaleBuilder("deDE", function() return {
    ["Use Theme Sounds"] = "Designsounds verwenden",
    ["Play the theme's animation sounds without changing your level-up sound."] = "Spielt die Animationsklänge des Designs ab, ohne den Stufenaufstiegssound zu ändern.",
    ["Class-coloured portrait background"] = "Porträthintergrund in Klassenfarbe",
    ["Fill the background behind the 3D player portrait with your class colour."] = "Färbt den Hintergrund hinter dem 3D-Spielerporträt in deiner Klassenfarbe.",
} end)
RegisterLocaleBuilder("deDE", function() return { ["Stat glint sound"] = "Klang beim Attributsaufblitzen" } end)
RegisterLocaleBuilder("deDE", function() return { ["Screenshot every level"] = "Screenshot bei jeder Stufe", ["Take a screenshot after every real level-up."] = "Erstelle bei jedem echten Stufenaufstieg einen Screenshot.", ["Could not save the level-up screenshot."] = "Der Screenshot des Stufenaufstiegs konnte nicht gespeichert werden." } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("deDE", function() return {
    ["Strength"] = "Stärke", ["Agility"] = "Beweglichkeit", ["Stamina"] = "Ausdauer", ["Intellect"] = "Intelligenz", ["Spirit"] = "Willenskraft",
    ["Level"] = "Stufe",
    ["Health"] = "Gesundheit", ["Mana"] = "Mana", ["Default"] = "Standard", ["%d pt"] = "%d Pkt.",
    ["Rage"] = "Wut", ["Energy"] = "Energie", ["Focus"] = "Fokus", ["Runic Power"] = "Runenmacht", ["Power"] = "Ressource",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("deDE", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "Ein Fehler ist aufgetreten (%s). Gib bitte /glu debugreport ein und sende mir den Bericht!",
    ["Debug report"] = "Fehlerbericht",
    ["No GnomeLevelUp errors have been recorded."] = "GnomeLevelUp hat keine Fehler aufgezeichnet.",
    ["Stat capture"] = "Attributserfassung",
    ["3D portrait rendering"] = "3D-Porträtdarstellung",
    ["Level-up popup"] = "Stufenaufstiegsfenster",
    ["Screenshot"] = "Screenshot",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("deDE", function() return {
    ["Complete trainer reporting"] = "Vollständige Lehrerberichte",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "Zeichnet im Debugmodus alle lesbaren Preise von Klassenlehrern auf. Exportiere die angebotenen Preise mit /glu trainerreport.",
    ["Clear all"] = "Alles löschen",
} end)
