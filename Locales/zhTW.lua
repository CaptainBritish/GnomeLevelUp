local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- zhTW: 繁體中文. English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.

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
RegisterLocaleBuilder("zhTW", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "歡迎使用 GnomeLevelUp！從 1.4.0 版本起，技能清單已預先填入，無須再手動掃描訓練師！如遇任何問題，請在 GitHub 或 Curseforge 上向我回報！",
} end)

-- Trainer-change monitoring and report export.
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
RegisterLocaleBuilder("zhTW", function() return {
    ["Portrait pulse and starburst"] = "頭像脈衝與星芒",
    ["Highlight new abilities"] = "醒目顯示新技能",
    ["Emphasize stat gains"] = "醒目顯示屬性提升",
    ["New ability"] = "新技能",
    ["Rank upgrade"] = "等級提升",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("zhTW", function() return {
    ["Portrait sparks"] = "頭像火花",
    ["New ability sparkles"] = "新技能閃光",
    ["Background embers"] = "背景餘燼",
    ["Frame edge glow"] = "邊框光暈",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
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
RegisterLocaleBuilder("zhTW", function() return {
    ["Portrait and ring settle"] = "頭像與邊框收攏",
    ["Reveal dividers"] = "分隔線展開",
} end)
RegisterLocaleBuilder("zhTW", function() return { ["Animated Elements"] = "動畫元素" } end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Starburst opacity (%)"] = "星芒不透明度 (%)",
    ["Portrait pulse opacity (%)"] = "頭像脈衝不透明度 (%)",
    ["Frame edge glow opacity (%)"] = "邊框發光不透明度 (%)",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Copy"] = "複製",
    ["Press Ctrl+C to copy. The field clears afterward."] = "按 Ctrl+C 複製，隨後文字框將清空。",
} end)

-- Profile controls and sharing messages.
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
RegisterLocaleBuilder("zhTW", function() return {
    ["Profile name (optional)"] = "設定檔名稱（選填）",
    ["Invalid profile string."] = "設定檔字串無效。",
    ["Invalid profile settings."] = "設定檔設定無效。",
} end)

-- Profile management.
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
RegisterLocaleBuilder("zhTW", function() return {
    ["GLU First Time Setup"] = "GLU 首次設定",
    ["Finish setup"] = "完成設定",
    ["Change these choices anytime in Options."] = "您可以隨時在選項中變更這些設定。",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("zhTW", function() return {
    ["Show pet skills"] = "顯示寵物技能",
    ["Enable animations"] = "啟用動畫",
} end)

-- Setup heading.
RegisterLocaleBuilder("zhTW", function() return { ["Welcome to GnomeLevelUp!"] = "歡迎使用 GnomeLevelUp！" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("zhTW", function() return { ["Background animations"] = "背景動畫" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("zhTW", function() return { ["Horizontal layout"] = "橫向配置" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Player 3D portrait"] = "玩家3D頭像" } end)
RegisterLocaleBuilder("zhTW", function() return { ["3D model rotation (degrees)"] = "3D模型旋轉（度）", ["3D model depth"] = "3D模型深度", ["3D model horizontal position"] = "3D模型水平位置", ["3D model vertical position"] = "3D模型垂直位置", ["3D model scale (%)"] = "3D模型縮放（%）" } end)
RegisterLocaleBuilder("zhTW", function() return { ["3D mask size (%)"] = "3D遮罩大小（%）" } end)
RegisterLocaleBuilder("zhTW", function() return { ["3D viewport size (%)"] = "3D視口大小（%）" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Milestone Animations"] = "里程碑動畫" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("zhTW", function() return { ["Firework size (%)"] = "煙火大小（%）", ["Firework opacity (%)"] = "煙火不透明度（%）" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("zhTW", function() return { ["Frame inset (px)"] = "邊框內距（像素）" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("zhTW", function() return { ["Portrait ring glint"] = "頭像邊框閃光", ["Ability reveal shine"] = "技能出現光澤", ["Milestone anticipation"] = "里程碑預備效果", ["Stat impact sparks"] = "屬性提升火花", ["Background depth"] = "背景縱深", ["Closing animation"] = "關閉動畫", ["Milestone color transition"] = "里程碑顏色過渡" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Screenshot milestones"] = "里程碑等級截圖" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Portrait motes"] = "頭像微粒", ["Background motes"] = "背景微粒" } end)
RegisterLocaleBuilder("zhTW", function() return { ["3D Portraits may consume more memory."] = "3D頭像可能佔用更多記憶體。" } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("zhTW", function() return {
    ["Shorten stat totals"] = "縮寫屬性總值",
    ["Relevant stats only"] = "僅顯示相關屬性",
    ["%sk"] = "%s千", ["%sm"] = "%s百萬", ["%sb"] = "%s十億",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("zhTW", function() return { ["Uses game volume"] = "使用遊戲音量" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("zhTW", function() return {
    ["Show faster leveling times"] = "顯示升級用時新紀錄",
    ["Fastest level: %s"] = "升級新紀錄：%s",
    ["%dh %02dm %02ds"] = "%d小時%02d分%02d秒", ["%dm %02ds"] = "%d分%02d秒", ["%ds"] = "%d秒",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("zhTW", function() return {
    ["Max Level Celebration"] = "滿級慶祝",
    ["Time to max level: %s"] = "升至滿級用時：%s",
    ["%dd %02dh %02dm %02ds"] = "%d天%02d小時%02d分%02d秒",
    ["Portrait impact sound"] = "頭像衝擊音效",
    ["Starburst sound"] = "星芒爆發音效",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("zhTW", function() return {
    ["Time to Level: %s"] = "升級用時：%s",
    ["New fastest time!:"] = "新的最快用時！：",
    ["New fastest time!: %s"] = "新的最快用時！：%s",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Glint finishing spark"] = "閃光結束火花",
    ["Portrait shine"] = "頭像流光",
    ["Ring surges"] = "圓環電湧",
    ["Max-level portrait sparks"] = "滿級頭像火花",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["New Best Time!"] = "新的最佳用時！",
    ["Fastest Time: %s"] = "最佳用時：%s",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Abbreviate stat names"] = "縮寫屬性名稱",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["%sM %sk"] = "%s百萬 %s千",
    ["Recorded level timers and best times reset for this character."] = "已重設此角色記錄的升級計時和最佳用時。",
} end)

-- Classic Mode and first-time setup descriptions.
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

-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("zhTW", function() return {
    ["Stat text size"] = "屬性文字大小",
    ["Heading text size"] = "標題文字大小",
    ["Time to Level text size"] = "升級用時文字大小",
    ["Level %d - %d"] = "等級 %d - %d",
    ["Time for %d levels: %s"] = "%d級用時：%s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
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

-- Shared descriptions for controller and standard Options.
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
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "實際升級符合所選里程碑間隔時擷取螢幕畫面。",
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

-- Minimap preview shortcut.
RegisterLocaleBuilder("zhTW", function() return { ["Middle-click: Preview Level-Up"] = "中鍵點擊：預覽升級提示" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("zhTW", function() return {
    ["Switch to secondary stats at"] = "切換至次要屬性的時間比例",
    ["Choose the percentage of display time spent on primary stats."] = "選擇主要屬性佔用的顯示時間百分比。",
    ["Replace primary stats with secondary stats during the popup."] = "在彈窗顯示期間將主要屬性替換為次要屬性。",
    ["Right-click: Replay last level-up"] = "右鍵點擊：重播上次升級",
    ["No recorded level-up to replay yet."] = "尚無可重播的升級紀錄。",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("zhTW", function() return {
    ["Adjust the space between popup sections."] = "調整彈窗各區域之間的間距。",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "將訓練師服務與內建目錄比較，發現差異時提供報告。",
    ["Open saved trainer differences and instructions for exporting a report."] = "開啟已儲存的訓練師差異及報告匯出說明。",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "顯示所有術士惡魔可用的魔典，而不只是目前寵物的魔典。",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "輸入相對於插件目錄的 OGG 檔案路徑，作為自訂升級音效。",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "選擇由本插件或 SharedMedia 註冊的自訂音效。",
    ["Show advanced tuning controls, test commands and performance counters."] = "顯示進階調整項目、測試指令與效能計數器。",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "在聊天中輸出測得的耗時。必須啟用除錯模式才能收集。",
    ["Clear performance counters before measuring another popup."] = "清空效能計數器，以便測量下一個彈窗。",
    ["Choose automatic client detection or force Retail or Forever rules."] = "選擇自動偵測客戶端，或強制使用 Retail 或 Forever 規則。",
    ["Update the displayed trainer-cache information."] = "更新顯示的訓練師快取資訊。",
    ["Enter a name to create a profile or rename the current one."] = "輸入名稱以建立新設定檔或重新命名目前設定檔。",
    ["Save the current options as a new profile with the entered name."] = "使用輸入的名稱將目前選項儲存為新設定檔。",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "重新命名所選設定檔。預設設定檔無法重新命名。",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "確認後刪除所選設定檔。預設設定檔無法刪除。",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "還原預設選項；保留已記錄的升級時間與訓練師報告。",
    ["Move the 3D portrait closer to or farther from the camera."] = "將3D頭像拉近或遠離攝影機。",
    ["Move the 3D portrait left or right inside its viewport."] = "在顯示區域內左右移動3D頭像。",
    ["Move the 3D portrait up or down inside its viewport."] = "在顯示區域內上下移動3D頭像。",
    ["Turn the 3D portrait around its vertical axis."] = "繞垂直軸旋轉3D頭像。",
    ["Change the size of the 3D character model."] = "調整角色3D模型的大小。",
    ["Change the circular mask that clips the 3D portrait."] = "調整裁切3D頭像的圓形遮罩。",
    ["Change the 3D rendering area around the portrait."] = "調整頭像周圍的3D繪製區域。",
    ["Resize the ring artwork without resizing the portrait."] = "調整圓環圖案大小，不改變頭像大小。",
    ["Move the ring artwork left or right."] = "左右移動圓環圖案。",
    ["Move the ring artwork up or down."] = "上下移動圓環圖案。",
    ["Adjust the empty inset between textured borders and popup content."] = "調整紋理邊框與彈窗內容之間的空白內距。",
    ["Mirror this frame piece horizontally."] = "水平翻轉這塊邊框。",
    ["Mirror this frame piece vertically."] = "垂直翻轉這塊邊框。",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "修改指定彈窗元素的顏色。職業顏色可能覆蓋強調色。",
    ["Tint this individual frame piece."] = "僅為這塊邊框染色。",
    ["Rotate this individual frame piece."] = "僅旋轉這塊邊框。",
    ["Set the number of particles for this effect. Zero hides them."] = "設定此效果的粒子數量。0表示隱藏。",
    ["Resize this effect's particles as a percentage of their normal size."] = "以正常大小的百分比調整此效果的粒子大小。",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "設定此效果粒子的不透明度。0表示不可見。",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "設定指定動畫的不透明度。0表示不可見。",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "此動畫觸發時播放音效。輸入 WoW 音效檔案 ID；0表示關閉此音效。",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "每十級里程碑加入頭像預告、明亮點綴與額外屬性效果。經典模式會關閉這些裝飾。",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "達到等級上限時，加入職業色曲線煙火、頭像圓環火花與更濃的背景粒子。經典模式會關閉這些效果。",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "讓頭像圓環脈動，再在頭像後顯示逐漸擴大的星芒。里程碑與滿級還會加入重複的頭像閃光。",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "為新學會的技能圖示加入出場閃光、輝光與閃爍火花。技能等級提升不會被高亮。",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "讓屬性總值從舊值逐步增加，再讓變動的數字閃光。里程碑還會在計數結束時加入火花。",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "星芒出現後，在頭像周圍釋放小光點。需要啟用頭像脈動與星芒。",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "在彈窗後方顯示上升粒子。里程碑與滿級會增加密度，滿級還會加快速度。",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "開啟時沿紋理邊框掃過漸隱輝光。現代主題無法使用此效果。",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "頭像開始時略微放大，再平滑恢復正常大小。里程碑還會加入短暫的預告閃光。",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "各區域進入時展開分隔線。經典模式保留文字過渡，但關閉此裝飾效果。",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "明亮火花繞頭像圓環移動，最後變成更大並漸隱的閃光。滿級時結尾火花會更大並閃爍。",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("zhTW", function() return { ["Trellis"] = "格柵" } end)

-- Flat background selector.
RegisterLocaleBuilder("zhTW", function() return { ["Solid Colour"] = "純色" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("zhTW", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "選擇背景顏色和透明度。純色直接使用此顏色。" } end)

-- Marine background selector.
RegisterLocaleBuilder("zhTW", function() return { ["Coral"] = "珊瑚" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("zhTW", function() return { ["Scratched Stone"] = "刮痕石材" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("zhTW", function() return { ["Reset Theme Hues"] = "重設主題色調", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "將所選背景、邊框和頭像環恢復為預設色調。保留其他已儲存的色調偏好。" } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("zhTW", function() return { ["Background Fill Mode"] = "背景填滿模式" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("zhTW", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "填滿保持比例並裁切超出部分，延展將圖片調整至邊框大小，平鋪則重複圖片。" } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("zhTW", function() return { ["Alliance Brick"] = "聯盟磚牆" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("zhTW", function() return { ["Memory: %s"] = "記憶體：%s", ["Memory: unavailable"] = "記憶體：無法取得" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("zhTW", function() return { ["Performance profiling enabled."] = "已啟用效能分析。", ["Performance profiling disabled."] = "已停用效能分析。", ["Profiling is off. Use /glu perf on to record measurements."] = "效能分析已關閉。使用 /glu perf on 記錄測量資料。" } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("zhTW", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - 啟動/停止效能分析（重新載入後關閉）", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - 輸出已記錄的效能診斷" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("zhTW", function() return { ["Level History"] = "等級歷史", ["Compare account-wide bests"] = "比較帳號最佳紀錄", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "將新升級用時與同一遊戲模式下所有角色最快的等級紀錄比較。", ["Character"] = "角色", ["Choose a character whose recorded level times you want to view."] = "選擇要查看升級用時的角色。", ["History mode"] = "歷史模式", ["View Retail or Forever history. Records are kept separate."] = "查看正式服或 Forever 歷史，兩種模式的紀錄分開儲存。", ["Reset this character's times"] = "重設此角色的用時", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "清除此角色在兩種模式下的用時和最佳紀錄，保留其他角色的資料。", ["Fill sample times (20h)"] = "填入測試時間（20小時）", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "為每個等級填入暫時的20小時時間。新紀錄會取代測試值，不會覆寫既有歷史紀錄。", ["Clear sample history"] = "清除測試歷史", ["Remove the temporary sample times and show real records again."] = "移除暫時用時並重新顯示真實紀錄。", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "僅列出已有升級用時紀錄的角色，缺少的等級顯示為橫線。", ["Sample history (not saved)"] = "測試歷史（不儲存）", ["Recorded: %d / %d"] = "已記錄：%d / %d", ["Total: %s"] = "總計：%s", ["Recorded time"] = "記錄用時", ["Personal best"] = "個人最佳", ["Account best"] = "帳號最佳", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "查看記錄用時及所有角色中的個人最佳用時。將滑鼠移到列上可查看創下個人最佳紀錄的角色。" } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("zhTW", function() return { ["Milestone interval"] = "里程碑間隔", ["Every 5 levels"] = "每5級", ["Every 10 levels"] = "每10級", ["Every 20 levels"] = "每20級", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "選擇里程碑動畫和螢幕擷取的觸發頻率。滿級動畫有獨立的開關。", ["Add celebration effects at the selected milestone interval."] = "在所選里程碑間隔加入慶祝效果。", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "在所選間隔使用頭像預備效果、更明亮的裝飾和額外屬性效果慶祝。經典模式停用這些效果。", ["Choose a level up to 1000 that is a multiple of %d."] = "選擇不超過1000且為%d的倍數的等級。" } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("zhTW", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "無法準備升級彈窗。請嘗試 /reload。如果再次發生，請回報此錯誤：%s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "無法播放所選音效。請在選項 > 音效中選擇其他音效。詳細資訊：%s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "無法顯示升級彈窗。請嘗試 /reload。如果再次發生，請回報上方的錯誤。", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "無法取得等級上限。請等待載入完成，再嘗試 /glu maxlevel。", ["Paste the complete GLU profile export, then try again."] = "請貼上完整的GLU設定匯出字串，然後重試。", ["Export the profile again from an up-to-date GLU installation."] = "請使用最新版GLU重新匯出設定。" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Ability Cost Size"] = "技能費用字級", ["Adjust the size of ability prices for the current layout."] = "調整目前版面配置中的技能費用字級。" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Learning cost: %s"] = "學習費用：%s", ["%d abilities"] = "%d 個技能", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "顯示測試彈窗，不變更等級記錄。按右鍵可選擇技能數量。" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Show prices in tooltips"] = "在提示中顯示價格", ["Show full learning costs when hovering over abilities."] = "游標移至技能時顯示完整學習費用。" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Contributors"] = "貢獻者" } end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "屬性擷取失敗：重試後仍未偵測到預期的屬性變化。",
    ["3D Portrait render failed: The player model did not load in time."] = "3D頭像繪製失敗：角色模型未能及時載入。",
    ["3D Portrait render failed: Could not assign the player model."] = "3D頭像繪製失敗：無法設定角色模型。",
} end)
RegisterLocaleBuilder("zhTW", function() return { ["Theme sound"] = "主題音效" } end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Idle motes sound"] = "環境微粒音效",
    ["Fireworks sound"] = "煙火音效",
    ["Fade-in sound"] = "淡入音效",
    ["Fade-out sound"] = "淡出音效",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "輸入 WoW 音訊檔案 ID 以替換此音效。輸入 0 清除替換。",
} end)
RegisterLocaleBuilder("zhTW", function() return {
    ["Use Theme Sounds"] = "使用主題音效",
    ["Play the theme's animation sounds without changing your level-up sound."] = "播放主題的動畫音效，不更改升級音效。",
    ["Class-coloured portrait background"] = "職業顏色頭像背景",
    ["Fill the background behind the 3D player portrait with your class colour."] = "使用職業顏色填滿玩家3D頭像後方的背景。",
} end)
RegisterLocaleBuilder("zhTW", function() return { ["Stat glint sound"] = "屬性閃光音效" } end)
RegisterLocaleBuilder("zhTW", function() return { ["Screenshot every level"] = "每次升級時擷取畫面", ["Take a screenshot after every real level-up."] = "每次實際升級後擷取螢幕畫面。", ["Could not save the level-up screenshot."] = "無法儲存升級螢幕擷取。" } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("zhTW", function() return {
    ["Strength"] = "力量", ["Agility"] = "敏捷", ["Stamina"] = "耐力", ["Intellect"] = "智力", ["Spirit"] = "精神",
    ["Level"] = "等級",
    ["Health"] = "生命力", ["Mana"] = "法力", ["Default"] = "預設", ["%d pt"] = "%d 點",
    ["Rage"] = "怒氣", ["Energy"] = "能量", ["Focus"] = "集中值", ["Runic Power"] = "符能", ["Power"] = "資源",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("zhTW", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "發生錯誤（%s）。請輸入 /glu debugreport 並將報告傳送給我！",
    ["Debug report"] = "偵錯報告",
    ["No GnomeLevelUp errors have been recorded."] = "未記錄到 GnomeLevelUp 錯誤。",
    ["Stat capture"] = "屬性擷取",
    ["3D portrait rendering"] = "3D 頭像算繪",
    ["Level-up popup"] = "升級通知",
    ["Screenshot"] = "螢幕擷取",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("zhTW", function() return {
    ["Complete trainer reporting"] = "完整訓練師報告",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "在偵錯模式下記錄職業訓練師所有可讀取的價格。使用 /glu trainerreport 匯出實際報價。",
    ["Clear all"] = "全部清除",
} end)
