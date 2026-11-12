local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- ruRU: Русский. English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.

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

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("ruRU", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Добро пожаловать в GnomeLevelUp! Начиная с версии 1.4.0 больше не нужно сканировать учителей вручную: список уже заполнен! Пожалуйста, сообщайте мне о любых проблемах на GitHub или Curseforge!",
} end)

-- Trainer-change monitoring and report export.
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

-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("ruRU", function() return {
    ["Portrait pulse and starburst"] = "Импульс и сияние портрета",
    ["Highlight new abilities"] = "Выделять новые способности",
    ["Emphasize stat gains"] = "Выделять прирост характеристик",
    ["New ability"] = "Новая способность",
    ["Rank upgrade"] = "Повышение ранга",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("ruRU", function() return {
    ["Portrait sparks"] = "Искры портрета",
    ["New ability sparkles"] = "Искры новых способностей",
    ["Background embers"] = "Угольки на фоне",
    ["Frame edge glow"] = "Свечение рамки",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
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

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("ruRU", function() return {
    ["Portrait and ring settle"] = "Плавная посадка портрета и кольца",
    ["Reveal dividers"] = "Появление разделителей",
} end)
RegisterLocaleBuilder("ruRU", function() return { ["Animated Elements"] = "Анимированные элементы" } end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Starburst opacity (%)"] = "Непрозрачность звёздного сияния (%)",
    ["Portrait pulse opacity (%)"] = "Непрозрачность импульса портрета (%)",
    ["Frame edge glow opacity (%)"] = "Непрозрачность свечения рамки (%)",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Copy"] = "Копировать",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Нажмите Ctrl+C для копирования. После этого поле очистится.",
} end)

-- Profile controls and sharing messages.
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

-- Profile-sharing window.
RegisterLocaleBuilder("ruRU", function() return {
    ["Profile name (optional)"] = "Название профиля (необязательно)",
    ["Invalid profile string."] = "Недопустимая строка профиля.",
    ["Invalid profile settings."] = "Недопустимые настройки профиля.",
} end)

-- Profile management.
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

-- First-run setup.
RegisterLocaleBuilder("ruRU", function() return {
    ["GLU First Time Setup"] = "GLU — Первоначальная настройка",
    ["Finish setup"] = "Завершить настройку",
    ["Change these choices anytime in Options."] = "Эти настройки можно изменить в любое время в меню параметров.",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("ruRU", function() return {
    ["Show pet skills"] = "Показывать умения питомцев",
    ["Enable animations"] = "Включить анимации",
} end)

-- Setup heading.
RegisterLocaleBuilder("ruRU", function() return { ["Welcome to GnomeLevelUp!"] = "Добро пожаловать в GnomeLevelUp!" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("ruRU", function() return { ["Background animations"] = "Фоновые анимации" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("ruRU", function() return { ["Horizontal layout"] = "Горизонтальная компоновка" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Player 3D portrait"] = "3D-портрет игрока" } end)
RegisterLocaleBuilder("ruRU", function() return { ["3D model rotation (degrees)"] = "Поворот 3D-модели (градусы)", ["3D model depth"] = "Глубина 3D-модели", ["3D model horizontal position"] = "Горизонтальное положение 3D-модели", ["3D model vertical position"] = "Вертикальное положение 3D-модели", ["3D model scale (%)"] = "Масштаб 3D-модели (%)" } end)
RegisterLocaleBuilder("ruRU", function() return { ["3D mask size (%)"] = "Размер 3D-маски (%)" } end)
RegisterLocaleBuilder("ruRU", function() return { ["3D viewport size (%)"] = "Размер области 3D-модели (%)" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Milestone Animations"] = "Анимации юбилейных уровней" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("ruRU", function() return { ["Firework size (%)"] = "Размер фейерверков (%)", ["Firework opacity (%)"] = "Непрозрачность фейерверков (%)" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("ruRU", function() return { ["Frame inset (px)"] = "Отступ рамки (пкс)" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("ruRU", function() return { ["Portrait ring glint"] = "Блик на кольце портрета", ["Ability reveal shine"] = "Блик при появлении способностей", ["Milestone anticipation"] = "Подготовка юбилейного эффекта", ["Stat impact sparks"] = "Искры прироста характеристик", ["Background depth"] = "Глубина фона", ["Closing animation"] = "Анимация закрытия", ["Milestone color transition"] = "Смена цвета юбилейного эффекта" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Screenshot milestones"] = "Скриншоты на юбилейных уровнях" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Portrait motes"] = "Частицы портрета", ["Background motes"] = "Фоновые частицы" } end)
RegisterLocaleBuilder("ruRU", function() return { ["3D Portraits may consume more memory."] = "3D-портреты могут потреблять больше памяти." } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("ruRU", function() return {
    ["Shorten stat totals"] = "Сокращать значения характеристик",
    ["Relevant stats only"] = "Только актуальные характеристики",
    ["%sk"] = "%s тыс.", ["%sm"] = "%s млн", ["%sb"] = "%s млрд",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("ruRU", function() return { ["Uses game volume"] = "Используется громкость игры" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("ruRU", function() return {
    ["Show faster leveling times"] = "Показывать новые рекорды получения уровня",
    ["Fastest level: %s"] = "Новый рекорд: %s",
    ["%dh %02dm %02ds"] = "%dч %02dмин %02dс", ["%dm %02ds"] = "%dмин %02dс", ["%ds"] = "%dс",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("ruRU", function() return {
    ["Max Level Celebration"] = "Празднование максимального уровня",
    ["Time to max level: %s"] = "Время до максимального уровня: %s",
    ["%dd %02dh %02dm %02ds"] = "%dд %02dч %02dмин %02dс",
    ["Portrait impact sound"] = "Звук импульса портрета",
    ["Starburst sound"] = "Звук звёздной вспышки",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("ruRU", function() return {
    ["Time to Level: %s"] = "Время до уровня: %s",
    ["New fastest time!:"] = "Новое лучшее время!:",
    ["New fastest time!: %s"] = "Новое лучшее время!: %s",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Glint finishing spark"] = "Завершающая искра блика",
    ["Portrait shine"] = "Сияние портрета",
    ["Ring surges"] = "Разряды кольца",
    ["Max-level portrait sparks"] = "Искры портрета на максимальном уровне",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["New Best Time!"] = "Новое лучшее время!",
    ["Fastest Time: %s"] = "Лучшее время: %s",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Abbreviate stat names"] = "Сокращать названия характеристик",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["%sM %sk"] = "%s млн %s тыс.",
    ["Recorded level timers and best times reset for this character."] = "Сохранённые времена уровней и рекорды этого персонажа сброшены.",
} end)

-- Classic Mode and first-time setup descriptions.
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

-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("ruRU", function() return {
    ["Stat text size"] = "Размер текста характеристик",
    ["Heading text size"] = "Размер заголовков",
    ["Time to Level text size"] = "Размер текста времени уровня",
    ["Level %d - %d"] = "Уровни %d - %d",
    ["Time for %d levels: %s"] = "Время за %d уровней: %s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
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

-- Shared descriptions for controller and standard Options.
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
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "Делать снимок экрана при получении уровня, соответствующего выбранному интервалу этапов.",
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

-- Minimap preview shortcut.
RegisterLocaleBuilder("ruRU", function() return { ["Middle-click: Preview Level-Up"] = "Средняя кнопка мыши: предпросмотр повышения уровня" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("ruRU", function() return {
    ["Switch to secondary stats at"] = "Перейти к вторичным характеристикам на",
    ["Choose the percentage of display time spent on primary stats."] = "Выберите долю времени показа основных характеристик.",
    ["Replace primary stats with secondary stats during the popup."] = "Заменяет основные характеристики вторичными во время показа окна.",
    ["Right-click: Replay last level-up"] = "Правая кнопка мыши: повтор последнего повышения уровня",
    ["No recorded level-up to replay yet."] = "Пока нет записанного повышения уровня для повтора.",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("ruRU", function() return {
    ["Adjust the space between popup sections."] = "Настраивает расстояние между разделами окна.",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "Сравнивает услуги учителей со встроенным каталогом и предлагает отчёт при расхождениях.",
    ["Open saved trainer differences and instructions for exporting a report."] = "Открывает сохранённые расхождения и инструкции по экспорту отчёта.",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "Показывает доступные гримуары чернокнижника для всех демонов, а не только активного питомца.",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "Введите путь к файлу OGG относительно папки аддона для своего звука повышения уровня.",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "Выберите свой звук, зарегистрированный этим аддоном или SharedMedia.",
    ["Show advanced tuning controls, test commands and performance counters."] = "Показывает расширенные настройки, тестовые команды и счётчики производительности.",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "Выводит измеренные длительности в чат. Для сбора измерений нужен режим отладки.",
    ["Clear performance counters before measuring another popup."] = "Сбрасывает счётчики перед измерением следующего окна.",
    ["Choose automatic client detection or force Retail or Forever rules."] = "Выберите автоматическое определение клиента или принудительные правила Retail либо Forever.",
    ["Update the displayed trainer-cache information."] = "Обновляет показанные сведения о кэше учителей.",
    ["Enter a name to create a profile or rename the current one."] = "Введите имя для создания профиля или переименования текущего.",
    ["Save the current options as a new profile with the entered name."] = "Сохраняет текущие настройки в новом профиле с указанным именем.",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "Переименовывает выбранный профиль. Стандартный профиль переименовать нельзя.",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "Удаляет выбранный профиль после подтверждения. Стандартный профиль удалить нельзя.",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "Восстанавливает стандартные настройки; сохраняет записанные времена уровней и отчёты.",
    ["Move the 3D portrait closer to or farther from the camera."] = "Приближает 3D-портрет к камере или отдаляет от неё.",
    ["Move the 3D portrait left or right inside its viewport."] = "Сдвигает 3D-портрет влево или вправо внутри области отображения.",
    ["Move the 3D portrait up or down inside its viewport."] = "Сдвигает 3D-портрет вверх или вниз внутри области отображения.",
    ["Turn the 3D portrait around its vertical axis."] = "Поворачивает 3D-портрет вокруг вертикальной оси.",
    ["Change the size of the 3D character model."] = "Меняет размер 3D-модели персонажа.",
    ["Change the circular mask that clips the 3D portrait."] = "Меняет круглую маску обрезки 3D-портрета.",
    ["Change the 3D rendering area around the portrait."] = "Меняет область 3D-отрисовки вокруг портрета.",
    ["Resize the ring artwork without resizing the portrait."] = "Меняет размер изображения кольца, не меняя портрет.",
    ["Move the ring artwork left or right."] = "Сдвигает изображение кольца влево или вправо.",
    ["Move the ring artwork up or down."] = "Сдвигает изображение кольца вверх или вниз.",
    ["Adjust the empty inset between textured borders and popup content."] = "Настраивает пустой отступ между текстурной рамкой и содержимым окна.",
    ["Mirror this frame piece horizontally."] = "Отражает эту часть рамки по горизонтали.",
    ["Mirror this frame piece vertically."] = "Отражает эту часть рамки по вертикали.",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "Меняет цвет указанного элемента. Цвета класса могут заменять цвета акцентов.",
    ["Tint this individual frame piece."] = "Окрашивает только эту часть рамки.",
    ["Rotate this individual frame piece."] = "Поворачивает только эту часть рамки.",
    ["Set the number of particles for this effect. Zero hides them."] = "Задаёт число частиц эффекта. Ноль скрывает их.",
    ["Resize this effect's particles as a percentage of their normal size."] = "Меняет размер частиц в процентах от обычного размера.",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "Задаёт непрозрачность частиц. Ноль делает их невидимыми.",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "Задаёт непрозрачность указанной анимации. Ноль делает её невидимой.",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "Воспроизводит звук при запуске анимации. Введите ID звукового файла WoW; 0 отключает этот звук.",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Отмечает каждый десятый уровень предварительной вспышкой портрета, яркими акцентами и эффектами характеристик. Классический режим отключает эти украшения.",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "На максимальном уровне добавляет изогнутые фейерверки цвета класса, искры на кольце и усиленные фоновые частицы. Классический режим отключает эти эффекты.",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "Кольцо пульсирует, затем за портретом появляется растущая звезда. Вехи и максимальный уровень также добавляют повторяющийся блик на портрете.",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "Добавляет блик появления, свечение и искры к новым способностям. Улучшения ранга не выделяются.",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "Плавно увеличивает значения от старых к новым, затем подсвечивает изменённые числа. На вехах добавляет искры после завершения счёта.",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "Выпускает небольшие плавающие огоньки вокруг портрета после звезды. Требуется пульсация и звезда портрета.",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "Показывает поднимающиеся частицы за окном. Вехи и максимальный уровень увеличивают плотность; на максимальном уровне они также ускоряются.",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "При открытии проводит затухающую подсветку по текстурным краям рамки. Недоступно для современной темы.",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "Портрет сначала немного увеличен, затем плавно возвращается к обычному размеру. На вехах добавляется короткая предварительная вспышка.",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "Разворачивает разделительные линии при появлении разделов. Классический режим сохраняет переходы текста, но отключает это украшение.",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "Проводит яркую искру по кольцу портрета, завершая большим затухающим бликом. На максимальном уровне конечная искра увеличивается и мерцает.",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("ruRU", function() return { ["Trellis"] = "Решётка" } end)

-- Flat background selector.
RegisterLocaleBuilder("ruRU", function() return { ["Solid Colour"] = "Сплошной цвет" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("ruRU", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "Выберите цвет и прозрачность фона. Сплошной цвет использует этот цвет напрямую." } end)

-- Marine background selector.
RegisterLocaleBuilder("ruRU", function() return { ["Coral"] = "Коралл" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("ruRU", function() return { ["Scratched Stone"] = "Поцарапанный камень" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("ruRU", function() return { ["Reset Theme Hues"] = "Сбросить оттенки темы", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "Восстанавливает стандартные оттенки выбранных фона, рамки и кольца портрета. Остальные сохранённые настройки сохраняются." } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("ruRU", function() return { ["Background Fill Mode"] = "Режим заполнения фона" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("ruRU", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "Заполнение сохраняет пропорции и обрезает лишнее, растяжение подгоняет под рамку, а мозаика повторяет изображение." } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("ruRU", function() return { ["Alliance Brick"] = "Кирпич Альянса" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("ruRU", function() return { ["Memory: %s"] = "Память: %s", ["Memory: unavailable"] = "Память: недоступно" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("ruRU", function() return { ["Performance profiling enabled."] = "Профилирование производительности включено.", ["Performance profiling disabled."] = "Профилирование производительности выключено.", ["Profiling is off. Use /glu perf on to record measurements."] = "Профилирование выключено. Используйте /glu perf on для записи измерений." } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("ruRU", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - запустить/остановить профилирование (выключено после перезагрузки)", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - показать записанную диагностику производительности" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("ruRU", function() return { ["Level History"] = "История уровней", ["Compare account-wide bests"] = "Сравнивать рекорды аккаунта", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "Сравнивать новое время с самым быстрым уровнем среди персонажей в том же режиме игры.", ["Character"] = "Персонаж", ["Choose a character whose recorded level times you want to view."] = "Выберите персонажа для просмотра времени уровней.", ["History mode"] = "Режим истории", ["View Retail or Forever history. Records are kept separate."] = "Показать историю Retail или Forever. Записи хранятся отдельно.", ["Reset this character's times"] = "Сбросить время этого персонажа", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "Удалить время и рекорды этого персонажа в обоих режимах. Другие персонажи сохраняются.", ["Fill sample times (20h)"] = "Тестовые времена (20 ч)", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "Заполняет все уровни временными результатами по 20 часов. Новые рекорды заменяют тестовые значения, не перезаписывая существующую историю.", ["Clear sample history"] = "Очистить тестовую историю", ["Remove the temporary sample times and show real records again."] = "Удалить временные данные и снова показать настоящие записи.", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "В списке только персонажи с записанным временем уровней. Пропуски обозначены тире.", ["Sample history (not saved)"] = "Тестовая история (не сохраняется)", ["Recorded: %d / %d"] = "Записано: %d / %d", ["Total: %s"] = "Всего: %s", ["Recorded time"] = "Записанное время", ["Personal best"] = "Личный рекорд", ["Account best"] = "Рекорд аккаунта", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "Просмотр записанного времени и лучших результатов среди ваших персонажей. Наведите курсор на строку, чтобы увидеть персонажа, установившего личный рекорд." } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("ruRU", function() return { ["Milestone interval"] = "Интервал этапов", ["Every 5 levels"] = "Каждые 5 уровней", ["Every 10 levels"] = "Каждые 10 уровней", ["Every 20 levels"] = "Каждые 20 уровней", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "Выберите, как часто запускаются анимации и делаются снимки экрана для этапов. Анимации максимального уровня имеют отдельную настройку.", ["Add celebration effects at the selected milestone interval."] = "Добавить эффекты на выбранных этапах.", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Отмечать выбранные этапы подготовкой портрета, яркими акцентами и эффектами характеристик. Классический режим отключает эти эффекты.", ["Choose a level up to 1000 that is a multiple of %d."] = "Выберите уровень до 1000, кратный %d." } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("ruRU", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "Не удалось подготовить окно уровня. Попробуйте /reload. Если ошибка повторится, сообщите о ней: %s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "Не удалось воспроизвести выбранный звук. Выберите другой в Настройки > Звук. Подробности: %s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "Не удалось показать окно уровня. Попробуйте /reload. Если ошибка повторится, сообщите об указанной выше ошибке.", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "Максимальный уровень недоступен. Дождитесь завершения загрузки и повторите /glu maxlevel.", ["Paste the complete GLU profile export, then try again."] = "Вставьте полную строку экспорта профиля GLU и повторите попытку.", ["Export the profile again from an up-to-date GLU installation."] = "Повторно экспортируйте профиль из актуальной версии GLU." } end)
RegisterLocaleBuilder("ruRU", function() return { ["Ability Cost Size"] = "Размер текста стоимости способностей", ["Adjust the size of ability prices for the current layout."] = "Меняет размер текста стоимости способностей в текущей компоновке." } end)
RegisterLocaleBuilder("ruRU", function() return { ["Learning cost: %s"] = "Стоимость обучения: %s", ["%d abilities"] = "Количество способностей: %d", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "Показывает тестовое окно без изменений истории. Щёлкните правой кнопкой, чтобы выбрать число способностей." } end)
RegisterLocaleBuilder("ruRU", function() return { ["Show prices in tooltips"] = "Показывать цены в подсказках", ["Show full learning costs when hovering over abilities."] = "Показывает полную стоимость при наведении на способности." } end)
RegisterLocaleBuilder("ruRU", function() return { ["Contributors"] = "Участники" } end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "Сбой при считывании характеристик: Ожидаемые изменения не появились после повторных попыток.",
    ["3D Portrait render failed: The player model did not load in time."] = "Сбой отрисовки 3D-портрета: Модель персонажа не загрузилась вовремя.",
    ["3D Portrait render failed: Could not assign the player model."] = "Сбой отрисовки 3D-портрета: Не удалось назначить модель персонажа.",
} end)
RegisterLocaleBuilder("ruRU", function() return { ["Theme sound"] = "Звук темы" } end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Idle motes sound"] = "Звук фоновых частиц",
    ["Fireworks sound"] = "Звук фейерверков",
    ["Fade-in sound"] = "Звук появления",
    ["Fade-out sound"] = "Звук исчезновения",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "Введите ID звукового файла WoW, чтобы заменить этот звук. Введите 0, чтобы отменить замену.",
} end)
RegisterLocaleBuilder("ruRU", function() return {
    ["Use Theme Sounds"] = "Использовать звуки темы",
    ["Play the theme's animation sounds without changing your level-up sound."] = "Воспроизводит звуки анимации темы без изменения звука повышения уровня.",
    ["Class-coloured portrait background"] = "Фон портрета цвета класса",
    ["Fill the background behind the 3D player portrait with your class colour."] = "Окрашивает фон за 3D-портретом персонажа в цвет вашего класса.",
} end)
RegisterLocaleBuilder("ruRU", function() return { ["Stat glint sound"] = "Звук вспышки характеристики" } end)
RegisterLocaleBuilder("ruRU", function() return { ["Screenshot every level"] = "Снимок при каждом повышении уровня", ["Take a screenshot after every real level-up."] = "Делать снимок экрана при каждом получении уровня.", ["Could not save the level-up screenshot."] = "Не удалось сохранить снимок экрана повышения уровня." } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("ruRU", function() return {
    ["Strength"] = "Сила", ["Agility"] = "Ловкость", ["Stamina"] = "Выносливость", ["Intellect"] = "Интеллект", ["Spirit"] = "Дух",
    ["Level"] = "Уровень",
    ["Health"] = "Здоровье", ["Mana"] = "Мана", ["Default"] = "По умолчанию", ["%d pt"] = "%d пт",
    ["Rage"] = "Ярость", ["Energy"] = "Энергия", ["Focus"] = "Концентрация", ["Runic Power"] = "Сила рун", ["Power"] = "Ресурс",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("ruRU", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "Произошла ошибка (%s). Введите /glu debugreport и пришлите мне отчёт!",
    ["Debug report"] = "Отчёт об ошибках",
    ["No GnomeLevelUp errors have been recorded."] = "Ошибки GnomeLevelUp не зарегистрированы.",
    ["Stat capture"] = "Считывание характеристик",
    ["3D portrait rendering"] = "Отрисовка 3D-портрета",
    ["Level-up popup"] = "Окно повышения уровня",
    ["Screenshot"] = "Снимок экрана",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("ruRU", function() return {
    ["Complete trainer reporting"] = "Полные отчёты об учителях",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "Записывает все доступные цены учителей классов в режиме отладки. Экспорт цен выполняется командой /glu trainerreport.",
    ["Clear all"] = "Очистить всё",
} end)
