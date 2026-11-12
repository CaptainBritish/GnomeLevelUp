local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- zhCN: 简体中文. English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.

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

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("zhCN", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "欢迎使用 GnomeLevelUp！从 1.4.0 版本起，技能列表已预先填充，无需再手动扫描训练师！如遇任何问题，请在 GitHub 或 Curseforge 上向我反馈！",
} end)

-- Trainer-change monitoring and report export.
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

-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("zhCN", function() return {
    ["Portrait pulse and starburst"] = "头像脉冲和星芒",
    ["Highlight new abilities"] = "突出显示新技能",
    ["Emphasize stat gains"] = "突出显示属性提升",
    ["New ability"] = "新技能",
    ["Rank upgrade"] = "等级提升",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("zhCN", function() return {
    ["Portrait sparks"] = "头像火花",
    ["New ability sparkles"] = "新技能闪光",
    ["Background embers"] = "背景余烬",
    ["Frame edge glow"] = "边框辉光",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
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

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("zhCN", function() return {
    ["Portrait and ring settle"] = "头像与边框收拢",
    ["Reveal dividers"] = "分隔线展开",
} end)
RegisterLocaleBuilder("zhCN", function() return { ["Animated Elements"] = "动画元素" } end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Starburst opacity (%)"] = "星芒不透明度 (%)",
    ["Portrait pulse opacity (%)"] = "头像脉冲不透明度 (%)",
    ["Frame edge glow opacity (%)"] = "边框发光不透明度 (%)",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Copy"] = "复制",
    ["Press Ctrl+C to copy. The field clears afterward."] = "按 Ctrl+C 复制，随后文本框将清空。",
} end)

-- Profile controls and sharing messages.
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

-- Profile-sharing window.
RegisterLocaleBuilder("zhCN", function() return {
    ["Profile name (optional)"] = "配置名称（可选）",
    ["Invalid profile string."] = "配置字符串无效。",
    ["Invalid profile settings."] = "配置设置无效。",
} end)

-- Profile management.
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

-- First-run setup.
RegisterLocaleBuilder("zhCN", function() return {
    ["GLU First Time Setup"] = "GLU 首次设置",
    ["Finish setup"] = "完成设置",
    ["Change these choices anytime in Options."] = "您可以随时在选项中更改这些设置。",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("zhCN", function() return {
    ["Show pet skills"] = "显示宠物技能",
    ["Enable animations"] = "启用动画",
} end)

-- Setup heading.
RegisterLocaleBuilder("zhCN", function() return { ["Welcome to GnomeLevelUp!"] = "欢迎使用 GnomeLevelUp！" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("zhCN", function() return { ["Background animations"] = "背景动画" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("zhCN", function() return { ["Horizontal layout"] = "横向布局" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Player 3D portrait"] = "玩家3D头像" } end)
RegisterLocaleBuilder("zhCN", function() return { ["3D model rotation (degrees)"] = "3D模型旋转（度）", ["3D model depth"] = "3D模型深度", ["3D model horizontal position"] = "3D模型水平位置", ["3D model vertical position"] = "3D模型垂直位置", ["3D model scale (%)"] = "3D模型缩放（%）" } end)
RegisterLocaleBuilder("zhCN", function() return { ["3D mask size (%)"] = "3D遮罩大小（%）" } end)
RegisterLocaleBuilder("zhCN", function() return { ["3D viewport size (%)"] = "3D视口大小（%）" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Milestone Animations"] = "里程碑动画" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("zhCN", function() return { ["Firework size (%)"] = "烟花大小（%）", ["Firework opacity (%)"] = "烟花不透明度（%）" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("zhCN", function() return { ["Frame inset (px)"] = "边框内边距（像素）" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("zhCN", function() return { ["Portrait ring glint"] = "头像边框闪光", ["Ability reveal shine"] = "技能出现光泽", ["Milestone anticipation"] = "里程碑预备效果", ["Stat impact sparks"] = "属性提升火花", ["Background depth"] = "背景纵深", ["Closing animation"] = "关闭动画", ["Milestone color transition"] = "里程碑颜色过渡" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Screenshot milestones"] = "里程碑等级截图" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Portrait motes"] = "头像微粒", ["Background motes"] = "背景微粒" } end)
RegisterLocaleBuilder("zhCN", function() return { ["3D Portraits may consume more memory."] = "3D头像可能占用更多内存。" } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("zhCN", function() return {
    ["Shorten stat totals"] = "缩写属性总值",
    ["Relevant stats only"] = "仅显示相关属性",
    ["%sk"] = "%s千", ["%sm"] = "%s百万", ["%sb"] = "%s十亿",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("zhCN", function() return { ["Uses game volume"] = "使用游戏音量" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("zhCN", function() return {
    ["Show faster leveling times"] = "显示升级用时新纪录",
    ["Fastest level: %s"] = "升级新纪录：%s",
    ["%dh %02dm %02ds"] = "%d小时%02d分%02d秒", ["%dm %02ds"] = "%d分%02d秒", ["%ds"] = "%d秒",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("zhCN", function() return {
    ["Max Level Celebration"] = "满级庆祝",
    ["Time to max level: %s"] = "升至满级用时：%s",
    ["%dd %02dh %02dm %02ds"] = "%d天%02d小时%02d分%02d秒",
    ["Portrait impact sound"] = "头像冲击音效",
    ["Starburst sound"] = "星芒爆发音效",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("zhCN", function() return {
    ["Time to Level: %s"] = "升级用时：%s",
    ["New fastest time!:"] = "新的最快用时！：",
    ["New fastest time!: %s"] = "新的最快用时！：%s",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Glint finishing spark"] = "闪光结束火花",
    ["Portrait shine"] = "头像流光",
    ["Ring surges"] = "圆环电涌",
    ["Max-level portrait sparks"] = "满级头像火花",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["New Best Time!"] = "新的最佳用时！",
    ["Fastest Time: %s"] = "最佳用时：%s",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Abbreviate stat names"] = "缩写属性名称",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["%sM %sk"] = "%s百万 %s千",
    ["Recorded level timers and best times reset for this character."] = "已重置此角色记录的升级计时和最佳用时。",
} end)

-- Classic Mode and first-time setup descriptions.
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

-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("zhCN", function() return {
    ["Stat text size"] = "属性文字大小",
    ["Heading text size"] = "标题文字大小",
    ["Time to Level text size"] = "升级用时文字大小",
    ["Level %d - %d"] = "等级 %d - %d",
    ["Time for %d levels: %s"] = "%d级用时：%s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
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

-- Shared descriptions for controller and standard Options.
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
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "实际升级符合所选里程碑间隔时截取屏幕截图。",
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

-- Minimap preview shortcut.
RegisterLocaleBuilder("zhCN", function() return { ["Middle-click: Preview Level-Up"] = "中键点击：预览升级提示" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("zhCN", function() return {
    ["Switch to secondary stats at"] = "切换到次要属性的时间比例",
    ["Choose the percentage of display time spent on primary stats."] = "选择主要属性占用的显示时间百分比。",
    ["Replace primary stats with secondary stats during the popup."] = "在弹窗显示期间将主要属性替换为次要属性。",
    ["Right-click: Replay last level-up"] = "右键点击：重播上次升级",
    ["No recorded level-up to replay yet."] = "尚无可重播的升级记录。",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("zhCN", function() return {
    ["Adjust the space between popup sections."] = "调整弹窗各区域之间的间距。",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "将训练师服务与内置目录比较，发现差异时提供报告。",
    ["Open saved trainer differences and instructions for exporting a report."] = "打开已保存的训练师差异及报告导出说明。",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "显示所有术士恶魔可用的魔典，而不只是当前宠物的魔典。",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "输入相对于插件目录的 OGG 文件路径，作为自定义升级音效。",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "选择由本插件或 SharedMedia 注册的自定义声音。",
    ["Show advanced tuning controls, test commands and performance counters."] = "显示高级调整项、测试命令和性能计数器。",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "在聊天中输出测得的耗时。需要启用调试模式才能收集。",
    ["Clear performance counters before measuring another popup."] = "清空性能计数器，以便测量下一个弹窗。",
    ["Choose automatic client detection or force Retail or Forever rules."] = "选择自动检测客户端，或强制使用 Retail 或 Forever 规则。",
    ["Update the displayed trainer-cache information."] = "刷新显示的训练师缓存信息。",
    ["Enter a name to create a profile or rename the current one."] = "输入名称以创建新配置或重命名当前配置。",
    ["Save the current options as a new profile with the entered name."] = "使用输入的名称将当前选项保存为新配置。",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "重命名所选配置。默认配置无法重命名。",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "确认后删除所选配置。默认配置无法删除。",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "恢复默认选项；保留已记录的升级时间和训练师报告。",
    ["Move the 3D portrait closer to or farther from the camera."] = "将3D头像拉近或远离摄像机。",
    ["Move the 3D portrait left or right inside its viewport."] = "在显示区域内左右移动3D头像。",
    ["Move the 3D portrait up or down inside its viewport."] = "在显示区域内上下移动3D头像。",
    ["Turn the 3D portrait around its vertical axis."] = "绕竖直轴旋转3D头像。",
    ["Change the size of the 3D character model."] = "调整角色3D模型的大小。",
    ["Change the circular mask that clips the 3D portrait."] = "调整裁剪3D头像的圆形遮罩。",
    ["Change the 3D rendering area around the portrait."] = "调整头像周围的3D渲染区域。",
    ["Resize the ring artwork without resizing the portrait."] = "调整圆环图案大小，不改变头像大小。",
    ["Move the ring artwork left or right."] = "左右移动圆环图案。",
    ["Move the ring artwork up or down."] = "上下移动圆环图案。",
    ["Adjust the empty inset between textured borders and popup content."] = "调整纹理边框与弹窗内容之间的空白内边距。",
    ["Mirror this frame piece horizontally."] = "水平翻转这块边框。",
    ["Mirror this frame piece vertically."] = "垂直翻转这块边框。",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "修改指定弹窗元素的颜色。职业颜色可能覆盖强调色。",
    ["Tint this individual frame piece."] = "仅为这块边框染色。",
    ["Rotate this individual frame piece."] = "仅旋转这块边框。",
    ["Set the number of particles for this effect. Zero hides them."] = "设置此效果的粒子数量。0表示隐藏。",
    ["Resize this effect's particles as a percentage of their normal size."] = "按正常大小的百分比调整此效果的粒子大小。",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "设置此效果粒子的不透明度。0表示不可见。",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "设置指定动画的不透明度。0表示不可见。",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "此动画触发时播放声音。输入 WoW 音效文件 ID；0表示关闭此声音。",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "每十级里程碑加入头像预告、亮色点缀和额外属性效果。经典模式会关闭这些装饰。",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "达到等级上限时，添加职业色曲线烟花、头像圆环火花和更浓的背景粒子。经典模式会关闭这些效果。",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "让头像圆环脉动，再在头像后显示逐渐扩大的星芒。里程碑和满级还会添加重复的头像闪光。",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "为新学会的技能图标添加出场闪光、辉光和闪烁火花。技能等级提升不会被高亮。",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "让属性总值从旧值逐步增加，再让变化的数字闪光。里程碑还会在计数结束时添加火花。",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "星芒出现后，在头像周围释放小光点。需要启用头像脉动与星芒。",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "在弹窗后方显示上升粒子。里程碑和满级会增加密度，满级还会加快速度。",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "打开时沿纹理边框扫过渐隐辉光。现代主题无法使用此效果。",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "头像开始时略微放大，再平滑恢复正常大小。里程碑还会添加短暂的预告闪光。",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "各区域进入时展开分隔线。经典模式保留文字过渡，但关闭此装饰效果。",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "亮火花绕头像圆环移动，最后变成更大并渐隐的闪光。满级时结束火花会更大并闪烁。",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("zhCN", function() return { ["Trellis"] = "格栅" } end)

-- Flat background selector.
RegisterLocaleBuilder("zhCN", function() return { ["Solid Colour"] = "纯色" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("zhCN", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "选择背景颜色和透明度。纯色直接使用此颜色。" } end)

-- Marine background selector.
RegisterLocaleBuilder("zhCN", function() return { ["Coral"] = "珊瑚" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("zhCN", function() return { ["Scratched Stone"] = "刮痕石材" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("zhCN", function() return { ["Reset Theme Hues"] = "重置主题色调", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "将所选背景、边框和头像环恢复为默认色调。保留其他已保存的色调偏好。" } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("zhCN", function() return { ["Background Fill Mode"] = "背景填充模式" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("zhCN", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "填充保持比例并裁剪超出部分，拉伸将图片调整至边框大小，平铺则重复图片。" } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("zhCN", function() return { ["Alliance Brick"] = "联盟砖墙" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("zhCN", function() return { ["Memory: %s"] = "内存：%s", ["Memory: unavailable"] = "内存：不可用" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("zhCN", function() return { ["Performance profiling enabled."] = "已启用性能分析。", ["Performance profiling disabled."] = "已禁用性能分析。", ["Profiling is off. Use /glu perf on to record measurements."] = "性能分析已关闭。使用 /glu perf on 记录测量数据。" } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("zhCN", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - 启动/停止性能分析（重载后关闭）", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - 输出已记录的性能诊断" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("zhCN", function() return { ["Level History"] = "等级历史", ["Compare account-wide bests"] = "比较账号最佳纪录", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "将新升级用时与同一游戏模式下所有角色最快的等级纪录比较。", ["Character"] = "角色", ["Choose a character whose recorded level times you want to view."] = "选择要查看升级用时的角色。", ["History mode"] = "历史模式", ["View Retail or Forever history. Records are kept separate."] = "查看正式服或 Forever 历史，两种模式的纪录分开保存。", ["Reset this character's times"] = "重置此角色的用时", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "清除此角色在两种模式下的用时和最佳纪录，保留其他角色的数据。", ["Fill sample times (20h)"] = "填充测试时间（20小时）", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "为每个等级填充临时的20小时时间。新纪录会替换测试值，不会覆盖已有历史记录。", ["Clear sample history"] = "清除测试历史", ["Remove the temporary sample times and show real records again."] = "移除临时用时并重新显示真实纪录。", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "仅列出已有升级用时纪录的角色，缺失的等级显示为横杠。", ["Sample history (not saved)"] = "测试历史（不保存）", ["Recorded: %d / %d"] = "已记录：%d / %d", ["Total: %s"] = "总计：%s", ["Recorded time"] = "记录用时", ["Personal best"] = "个人最佳", ["Account best"] = "账号最佳", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "查看记录用时及所有角色中的个人最佳用时。悬停在行上可查看创造个人最佳纪录的角色。" } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("zhCN", function() return { ["Milestone interval"] = "里程碑间隔", ["Every 5 levels"] = "每5级", ["Every 10 levels"] = "每10级", ["Every 20 levels"] = "每20级", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "选择里程碑动画和截图的触发频率。满级动画有独立的开关。", ["Add celebration effects at the selected milestone interval."] = "在所选里程碑间隔添加庆祝效果。", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "在所选间隔使用头像预备效果、更明亮的装饰和额外属性效果庆祝。经典模式禁用这些效果。", ["Choose a level up to 1000 that is a multiple of %d."] = "选择不超过1000且为%d的倍数的等级。" } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("zhCN", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "无法准备升级弹窗。请尝试 /reload。如果再次发生，请报告此错误：%s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "无法播放所选声音。请在选项 > 声音中选择其他声音。详情：%s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "无法显示升级弹窗。请尝试 /reload。如果再次发生，请报告上方的错误。", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "无法获取等级上限。请等待加载完成，再尝试 /glu maxlevel。", ["Paste the complete GLU profile export, then try again."] = "请粘贴完整的GLU配置导出字符串，然后重试。", ["Export the profile again from an up-to-date GLU installation."] = "请使用最新版GLU重新导出配置。" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Ability Cost Size"] = "技能费用字号", ["Adjust the size of ability prices for the current layout."] = "调整当前布局中的技能费用字号。" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Learning cost: %s"] = "学习费用：%s", ["%d abilities"] = "%d 个技能", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "显示测试弹窗，不改变等级记录。右键点击可选择技能数量。" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Show prices in tooltips"] = "在提示中显示价格", ["Show full learning costs when hovering over abilities."] = "悬停技能时显示完整学习费用。" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Contributors"] = "贡献者" } end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "属性采集失败：重试后仍未检测到预期的属性变化。",
    ["3D Portrait render failed: The player model did not load in time."] = "3D头像渲染失败：角色模型未能及时加载。",
    ["3D Portrait render failed: Could not assign the player model."] = "3D头像渲染失败：无法设置角色模型。",
} end)
RegisterLocaleBuilder("zhCN", function() return { ["Theme sound"] = "主题音效" } end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Idle motes sound"] = "环境微粒音效",
    ["Fireworks sound"] = "烟花音效",
    ["Fade-in sound"] = "淡入音效",
    ["Fade-out sound"] = "淡出音效",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "输入 WoW 音频文件 ID 来替换此音效。输入 0 清除替换。",
} end)
RegisterLocaleBuilder("zhCN", function() return {
    ["Use Theme Sounds"] = "使用主题音效",
    ["Play the theme's animation sounds without changing your level-up sound."] = "播放主题的动画音效，不更改升级音效。",
    ["Class-coloured portrait background"] = "职业颜色头像背景",
    ["Fill the background behind the 3D player portrait with your class colour."] = "使用职业颜色填充玩家3D头像后的背景。",
} end)
RegisterLocaleBuilder("zhCN", function() return { ["Stat glint sound"] = "属性闪光音效" } end)
RegisterLocaleBuilder("zhCN", function() return { ["Screenshot every level"] = "每次升级时截图", ["Take a screenshot after every real level-up."] = "每次实际升级后截取屏幕截图。", ["Could not save the level-up screenshot."] = "无法保存升级截图。" } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("zhCN", function() return {
    ["Strength"] = "力量", ["Agility"] = "敏捷", ["Stamina"] = "耐力", ["Intellect"] = "智力", ["Spirit"] = "精神",
    ["Level"] = "等级",
    ["Health"] = "生命值", ["Mana"] = "法力值", ["Default"] = "默认", ["%d pt"] = "%d 磅",
    ["Rage"] = "怒气", ["Energy"] = "能量", ["Focus"] = "集中值", ["Runic Power"] = "符文能量", ["Power"] = "资源",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("zhCN", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "发生错误（%s）。请输入 /glu debugreport 并将报告发送给我！",
    ["Debug report"] = "调试报告",
    ["No GnomeLevelUp errors have been recorded."] = "未记录到 GnomeLevelUp 错误。",
    ["Stat capture"] = "属性采集",
    ["3D portrait rendering"] = "3D 头像渲染",
    ["Level-up popup"] = "升级通知",
    ["Screenshot"] = "截图",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("zhCN", function() return {
    ["Complete trainer reporting"] = "完整训练师报告",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "在调试模式下记录职业训练师所有可读取的价格。使用 /glu trainerreport 导出实际报价。",
    ["Clear all"] = "全部清除",
} end)
