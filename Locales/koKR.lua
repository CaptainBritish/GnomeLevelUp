local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- koKR: 한국어. English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.

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

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("koKR", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "GnomeLevelUp에 오신 것을 환영합니다! 1.4.0부터는 기술 목록이 미리 포함되어 있으므로 상급자를 수동으로 스캔할 필요가 없습니다! 문제가 발생하면 GitHub 또는 Curseforge에서 제게 알려 주세요!",
} end)

-- Trainer-change monitoring and report export.
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

-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("koKR", function() return {
    ["Portrait pulse and starburst"] = "초상화 파동 및 별빛 효과",
    ["Highlight new abilities"] = "새 능력 강조",
    ["Emphasize stat gains"] = "능력치 증가 강조",
    ["New ability"] = "새 능력",
    ["Rank upgrade"] = "등급 상승",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("koKR", function() return {
    ["Portrait sparks"] = "초상화 불꽃",
    ["New ability sparkles"] = "새 능력 반짝임",
    ["Background embers"] = "배경 불씨",
    ["Frame edge glow"] = "테두리 빛",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
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

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("koKR", function() return {
    ["Portrait and ring settle"] = "초상화와 테두리 안착 효과",
    ["Reveal dividers"] = "구분선 펼치기",
} end)
RegisterLocaleBuilder("koKR", function() return { ["Animated Elements"] = "애니메이션 요소" } end)
RegisterLocaleBuilder("koKR", function() return {
    ["Starburst opacity (%)"] = "별빛 폭발 불투명도 (%)",
    ["Portrait pulse opacity (%)"] = "초상화 파동 불투명도 (%)",
    ["Frame edge glow opacity (%)"] = "테두리 발광 불투명도 (%)",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Copy"] = "복사",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Ctrl+C를 눌러 복사하세요. 복사 후 입력란이 비워집니다.",
} end)

-- Profile controls and sharing messages.
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

-- Profile-sharing window.
RegisterLocaleBuilder("koKR", function() return {
    ["Profile name (optional)"] = "프로필 이름 (선택 사항)",
    ["Invalid profile string."] = "프로필 문자열이 올바르지 않습니다.",
    ["Invalid profile settings."] = "프로필 설정이 올바르지 않습니다.",
} end)

-- Profile management.
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

-- First-run setup.
RegisterLocaleBuilder("koKR", function() return {
    ["GLU First Time Setup"] = "GLU 최초 설정",
    ["Finish setup"] = "설정 완료",
    ["Change these choices anytime in Options."] = "언제든지 옵션에서 변경할 수 있습니다.",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("koKR", function() return {
    ["Show pet skills"] = "소환수 기술 표시",
    ["Enable animations"] = "애니메이션 사용",
} end)

-- Setup heading.
RegisterLocaleBuilder("koKR", function() return { ["Welcome to GnomeLevelUp!"] = "GnomeLevelUp에 오신 것을 환영합니다!" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("koKR", function() return { ["Background animations"] = "배경 애니메이션" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("koKR", function() return { ["Horizontal layout"] = "가로 배치" } end)
RegisterLocaleBuilder("koKR", function() return { ["Player 3D portrait"] = "플레이어 3D 초상화" } end)
RegisterLocaleBuilder("koKR", function() return { ["3D model rotation (degrees)"] = "3D 모델 회전 (도)", ["3D model depth"] = "3D 모델 깊이", ["3D model horizontal position"] = "3D 모델 가로 위치", ["3D model vertical position"] = "3D 모델 세로 위치", ["3D model scale (%)"] = "3D 모델 크기 (%)" } end)
RegisterLocaleBuilder("koKR", function() return { ["3D mask size (%)"] = "3D 마스크 크기 (%)" } end)
RegisterLocaleBuilder("koKR", function() return { ["3D viewport size (%)"] = "3D 표시 영역 크기 (%)" } end)
RegisterLocaleBuilder("koKR", function() return { ["Milestone Animations"] = "주요 레벨 애니메이션" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("koKR", function() return { ["Firework size (%)"] = "불꽃놀이 크기 (%)", ["Firework opacity (%)"] = "불꽃놀이 불투명도 (%)" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("koKR", function() return { ["Frame inset (px)"] = "프레임 안쪽 여백 (px)" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("koKR", function() return { ["Portrait ring glint"] = "초상화 테두리 반짝임", ["Ability reveal shine"] = "능력 등장 광택", ["Milestone anticipation"] = "주요 레벨 사전 효과", ["Stat impact sparks"] = "능력치 증가 불꽃", ["Background depth"] = "배경 깊이", ["Closing animation"] = "닫기 애니메이션", ["Milestone color transition"] = "주요 레벨 색상 전환" } end)
RegisterLocaleBuilder("koKR", function() return { ["Screenshot milestones"] = "주요 레벨 스크린샷" } end)
RegisterLocaleBuilder("koKR", function() return { ["Portrait motes"] = "초상화 입자", ["Background motes"] = "배경 입자" } end)
RegisterLocaleBuilder("koKR", function() return { ["3D Portraits may consume more memory."] = "3D 초상화는 메모리를 더 사용할 수 있습니다." } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("koKR", function() return {
    ["Shorten stat totals"] = "능력치 총합 줄여 표시",
    ["Relevant stats only"] = "관련 능력치만 표시",
    ["%sk"] = "%s천", ["%sm"] = "%s백만", ["%sb"] = "%s십억",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("koKR", function() return { ["Uses game volume"] = "게임 음량 사용" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("koKR", function() return {
    ["Show faster leveling times"] = "레벨업 최고 기록 표시",
    ["Fastest level: %s"] = "새 최고 기록: %s",
    ["%dh %02dm %02ds"] = "%d시간 %02d분 %02d초", ["%dm %02ds"] = "%d분 %02d초", ["%ds"] = "%d초",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("koKR", function() return {
    ["Max Level Celebration"] = "최고 레벨 축하",
    ["Time to max level: %s"] = "최고 레벨까지 걸린 시간: %s",
    ["%dd %02dh %02dm %02ds"] = "%d일 %02d시간 %02d분 %02d초",
    ["Portrait impact sound"] = "초상화 충격 효과음",
    ["Starburst sound"] = "별빛 폭발 효과음",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("koKR", function() return {
    ["Time to Level: %s"] = "레벨업 소요 시간: %s",
    ["New fastest time!:"] = "새로운 최단 시간!:",
    ["New fastest time!: %s"] = "새로운 최단 시간!: %s",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Glint finishing spark"] = "반짝임 마무리 불꽃",
    ["Portrait shine"] = "초상화 광택",
    ["Ring surges"] = "테두리 전기 방전",
    ["Max-level portrait sparks"] = "최고 레벨 초상화 불꽃",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["New Best Time!"] = "새로운 최단 시간!",
    ["Fastest Time: %s"] = "최단 시간: %s",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Abbreviate stat names"] = "능력치 이름 줄이기",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["%sM %sk"] = "%s백만 %s천",
    ["Recorded level timers and best times reset for this character."] = "이 캐릭터의 저장된 레벨 시간과 최단 시간이 초기화되었습니다.",
} end)

-- Classic Mode and first-time setup descriptions.
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

-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("koKR", function() return {
    ["Stat text size"] = "능력치 글자 크기",
    ["Heading text size"] = "제목 글자 크기",
    ["Time to Level text size"] = "레벨 소요 시간 글자 크기",
    ["Level %d - %d"] = "레벨 %d - %d",
    ["Time for %d levels: %s"] = "%d레벨 소요 시간: %s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
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

-- Shared descriptions for controller and standard Options.
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
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "실제 레벨 상승이 선택한 이정표 간격에 해당할 때 스크린샷을 찍습니다.",
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

-- Minimap preview shortcut.
RegisterLocaleBuilder("koKR", function() return { ["Middle-click: Preview Level-Up"] = "가운데 클릭: 레벨 상승 미리 보기" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("koKR", function() return {
    ["Switch to secondary stats at"] = "보조 능력치로 전환하는 시점",
    ["Choose the percentage of display time spent on primary stats."] = "주요 능력치에 할당할 표시 시간의 비율을 선택합니다.",
    ["Replace primary stats with secondary stats during the popup."] = "팝업 도중 주요 능력치를 보조 능력치로 교체합니다.",
    ["Right-click: Replay last level-up"] = "오른쪽 클릭: 마지막 레벨 상승 다시 보기",
    ["No recorded level-up to replay yet."] = "다시 볼 레벨 상승 기록이 아직 없습니다.",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("koKR", function() return {
    ["Adjust the space between popup sections."] = "팝업 구역 사이의 간격을 조절합니다.",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "상급자 서비스를 내장 목록과 비교하고 차이가 있으면 보고서를 제안합니다.",
    ["Open saved trainer differences and instructions for exporting a report."] = "저장된 차이와 보고서 내보내기 안내를 엽니다.",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "현재 소환수뿐 아니라 모든 흑마법사 악마의 이용 가능한 마법서를 표시합니다.",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "사용자 지정 레벨 상승 소리에 사용할 OGG 파일의 애드온 기준 경로를 입력합니다.",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "이 애드온이나 SharedMedia에 등록된 사용자 지정 소리를 선택합니다.",
    ["Show advanced tuning controls, test commands and performance counters."] = "고급 조절 항목, 테스트 명령과 성능 카운터를 표시합니다.",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "측정한 시간을 대화창에 출력합니다. 수집하려면 디버그 모드가 필요합니다.",
    ["Clear performance counters before measuring another popup."] = "다른 팝업을 측정하기 전에 성능 카운터를 초기화합니다.",
    ["Choose automatic client detection or force Retail or Forever rules."] = "클라이언트를 자동 감지하거나 Retail 또는 Forever 규칙을 강제합니다.",
    ["Update the displayed trainer-cache information."] = "표시 중인 상급자 캐시 정보를 갱신합니다.",
    ["Enter a name to create a profile or rename the current one."] = "프로필을 만들거나 현재 프로필의 이름을 바꿀 이름을 입력합니다.",
    ["Save the current options as a new profile with the entered name."] = "입력한 이름의 새 프로필에 현재 설정을 저장합니다.",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "선택한 프로필의 이름을 바꿉니다. 기본 프로필은 이름을 바꿀 수 없습니다.",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "확인 후 선택한 프로필을 삭제합니다. 기본 프로필은 삭제할 수 없습니다.",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "설정을 기본값으로 되돌립니다. 기록된 레벨 시간과 보고서는 유지됩니다.",
    ["Move the 3D portrait closer to or farther from the camera."] = "3D 초상화를 카메라 쪽으로 또는 반대쪽으로 움직입니다.",
    ["Move the 3D portrait left or right inside its viewport."] = "표시 영역 안에서 3D 초상화를 좌우로 움직입니다.",
    ["Move the 3D portrait up or down inside its viewport."] = "표시 영역 안에서 3D 초상화를 위아래로 움직입니다.",
    ["Turn the 3D portrait around its vertical axis."] = "3D 초상화를 세로축을 중심으로 회전합니다.",
    ["Change the size of the 3D character model."] = "캐릭터 3D 모델의 크기를 변경합니다.",
    ["Change the circular mask that clips the 3D portrait."] = "3D 초상화를 자르는 원형 마스크를 변경합니다.",
    ["Change the 3D rendering area around the portrait."] = "초상화 주변의 3D 렌더링 영역을 변경합니다.",
    ["Resize the ring artwork without resizing the portrait."] = "초상화 크기는 유지하고 테두리 그림의 크기를 바꿉니다.",
    ["Move the ring artwork left or right."] = "테두리 그림을 좌우로 움직입니다.",
    ["Move the ring artwork up or down."] = "테두리 그림을 위아래로 움직입니다.",
    ["Adjust the empty inset between textured borders and popup content."] = "텍스처 테두리와 팝업 내용 사이의 빈 여백을 조절합니다.",
    ["Mirror this frame piece horizontally."] = "이 프레임 조각을 좌우로 뒤집습니다.",
    ["Mirror this frame piece vertically."] = "이 프레임 조각을 상하로 뒤집습니다.",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "해당 요소의 색을 바꿉니다. 직업 색상이 강조 색상을 덮어쓸 수 있습니다.",
    ["Tint this individual frame piece."] = "이 프레임 조각만 색을 입힙니다.",
    ["Rotate this individual frame piece."] = "이 프레임 조각만 회전합니다.",
    ["Set the number of particles for this effect. Zero hides them."] = "효과의 입자 수를 설정합니다. 0이면 숨깁니다.",
    ["Resize this effect's particles as a percentage of their normal size."] = "효과 입자의 크기를 기본 크기에 대한 백분율로 설정합니다.",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "효과 입자의 불투명도를 설정합니다. 0이면 보이지 않습니다.",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "해당 애니메이션의 불투명도를 설정합니다. 0이면 보이지 않습니다.",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "애니메이션이 시작될 때 소리를 재생합니다. WoW 소리 파일 ID를 입력하며, 0이면 이 소리를 끕니다.",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "10레벨 단위마다 초상화 예고 효과, 더 밝은 강조와 추가 능력치 효과로 축하합니다. 클래식 모드에서는 이 장식을 끕니다.",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "최고 레벨에서 직업 색상의 곡선 불꽃, 초상화 테두리의 불꽃과 강한 배경 입자를 추가합니다. 클래식 모드에서는 끕니다.",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "초상화 테두리를 맥동시킨 뒤 뒤쪽에 커지는 별빛을 표시합니다. 이정표와 최고 레벨에서는 초상화에 반복되는 광택도 추가합니다.",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "새로 배운 능력 아이콘에 등장 광택, 빛과 반짝이는 불꽃을 추가합니다. 등급 상승은 강조하지 않습니다.",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "기존 값에서 새 값까지 능력치를 올려 표시한 뒤 바뀐 숫자를 빛냅니다. 이정표에서는 계산이 끝날 때 불꽃도 추가합니다.",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "별빛 이후 초상화 주변에 작은 빛을 띄웁니다. 초상화 맥동 및 별빛 효과가 필요합니다.",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "팝업 뒤쪽에 올라가는 입자를 표시합니다. 이정표와 최고 레벨에서는 밀도가 늘고, 최고 레벨에서는 속도도 빨라집니다.",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "열릴 때 텍스처 테두리를 따라 사라지는 빛을 표시합니다. 모던 테마에서는 사용할 수 없습니다.",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "초상화를 조금 크게 시작한 뒤 기본 크기로 부드럽게 줄입니다. 이정표에서는 짧은 예고 섬광도 추가합니다.",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "각 구역이 등장할 때 구분선을 펼칩니다. 클래식 모드는 글자 전환을 유지하지만 이 장식 효과는 끕니다.",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "밝은 불꽃이 초상화 테두리를 돌고 끝에서 크게 빛난 뒤 사라집니다. 최고 레벨에서는 마지막 불꽃이 더 커지고 깜박입니다.",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("koKR", function() return { ["Trellis"] = "격자" } end)

-- Flat background selector.
RegisterLocaleBuilder("koKR", function() return { ["Solid Colour"] = "단색" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("koKR", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "배경 색상과 투명도를 선택합니다. 단색은 이 색상을 그대로 사용합니다." } end)

-- Marine background selector.
RegisterLocaleBuilder("koKR", function() return { ["Coral"] = "산호" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("koKR", function() return { ["Scratched Stone"] = "긁힌 돌" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("koKR", function() return { ["Reset Theme Hues"] = "테마 색조 초기화", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "선택한 배경, 테두리, 초상화 고리의 기본 색조를 복원합니다. 다른 저장된 색조 설정은 유지합니다." } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("koKR", function() return { ["Background Fill Mode"] = "배경 채우기 모드" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("koKR", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "채우기는 비율을 유지하고 넘치는 부분을 자릅니다. 늘이기는 테두리에 맞추고 바둑판은 이미지를 반복합니다." } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("koKR", function() return { ["Alliance Brick"] = "얼라이언스 벽돌" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("koKR", function() return { ["Memory: %s"] = "메모리: %s", ["Memory: unavailable"] = "메모리: 사용 불가" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("koKR", function() return { ["Performance profiling enabled."] = "성능 측정이 활성화되었습니다.", ["Performance profiling disabled."] = "성능 측정이 비활성화되었습니다.", ["Profiling is off. Use /glu perf on to record measurements."] = "성능 측정이 꺼져 있습니다. /glu perf on으로 측정을 시작하세요." } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("koKR", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - 성능 측정 시작/중지 (재접속 시 꺼짐)", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - 기록된 성능 진단 출력" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("koKR", function() return { ["Level History"] = "레벨 기록", ["Compare account-wide bests"] = "계정 최고 기록 비교", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "새 레벨 소요 시간을 같은 게임 모드의 모든 캐릭터 중 가장 빠른 레벨 기록과 비교합니다.", ["Character"] = "캐릭터", ["Choose a character whose recorded level times you want to view."] = "레벨 소요 시간을 확인할 캐릭터를 선택합니다.", ["History mode"] = "기록 모드", ["View Retail or Forever history. Records are kept separate."] = "리테일 또는 Forever 기록을 봅니다. 기록은 별도로 보관됩니다.", ["Reset this character's times"] = "이 캐릭터의 시간 초기화", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "이 캐릭터의 두 모드 시간과 최고 기록을 지웁니다. 다른 캐릭터는 유지됩니다.", ["Fill sample times (20h)"] = "시험 시간 채우기 (20시간)", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "모든 레벨에 임시 20시간 기록을 채웁니다. 새 기록은 시험 값을 대체하며 기존 기록은 덮어쓰지 않습니다.", ["Clear sample history"] = "테스트 기록 지우기", ["Remove the temporary sample times and show real records again."] = "임시 시간을 제거하고 실제 기록을 다시 표시합니다.", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "레벨 소요 시간이 기록된 캐릭터만 표시됩니다. 기록이 없는 레벨은 대시로 표시됩니다.", ["Sample history (not saved)"] = "테스트 기록 (저장되지 않음)", ["Recorded: %d / %d"] = "기록: %d / %d", ["Total: %s"] = "합계: %s", ["Recorded time"] = "소요 시간", ["Personal best"] = "개인 최고", ["Account best"] = "계정 최고", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "기록된 시간과 모든 캐릭터의 개인 최고 기록을 확인합니다. 행 위에 마우스를 올리면 최고 기록을 세운 캐릭터가 표시됩니다." } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("koKR", function() return { ["Milestone interval"] = "기념 레벨 간격", ["Every 5 levels"] = "5레벨마다", ["Every 10 levels"] = "10레벨마다", ["Every 20 levels"] = "20레벨마다", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "이정표 애니메이션과 스크린샷의 실행 간격을 선택합니다. 최고 레벨 애니메이션에는 별도 설정이 있습니다.", ["Add celebration effects at the selected milestone interval."] = "선택한 레벨 간격에 축하 효과를 추가합니다.", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "선택한 간격마다 초상화 예고, 밝은 장식 및 추가 능력치 효과로 축하합니다. 클래식 모드에서는 이 효과가 꺼집니다.", ["Choose a level up to 1000 that is a multiple of %d."] = "%d의 배수인 1000 이하 레벨을 선택하세요." } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("koKR", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "레벨 팝업을 준비하지 못했습니다. /reload를 시도하세요. 다시 발생하면 다음 오류를 제보하세요: %s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "선택한 소리를 재생하지 못했습니다. 옵션 > 소리에서 다른 소리를 선택하세요. 자세한 내용: %s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "레벨 팝업을 표시하지 못했습니다. /reload를 시도하세요. 다시 발생하면 위 오류를 제보하세요.", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "최고 레벨을 확인할 수 없습니다. 로딩이 끝난 후 /glu maxlevel을 다시 시도하세요.", ["Paste the complete GLU profile export, then try again."] = "GLU 프로필 내보내기 문자열 전체를 붙여 넣고 다시 시도하세요.", ["Export the profile again from an up-to-date GLU installation."] = "최신 GLU 설치본에서 프로필을 다시 내보내세요." } end)
RegisterLocaleBuilder("koKR", function() return { ["Ability Cost Size"] = "기술 비용 글자 크기", ["Adjust the size of ability prices for the current layout."] = "현재 배치에서 기술 비용의 글자 크기를 조절합니다." } end)
RegisterLocaleBuilder("koKR", function() return { ["Learning cost: %s"] = "학습 비용: %s", ["%d abilities"] = "기술 %d개", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "레벨 기록을 변경하지 않고 미리 봅니다. 오른쪽 클릭으로 기술 개수를 선택하세요." } end)
RegisterLocaleBuilder("koKR", function() return { ["Show prices in tooltips"] = "툴팁에 가격 표시", ["Show full learning costs when hovering over abilities."] = "기술에 마우스를 올리면 전체 학습 비용을 표시합니다." } end)
RegisterLocaleBuilder("koKR", function() return { ["Contributors"] = "기여자" } end)
RegisterLocaleBuilder("koKR", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "능력치 수집 실패: 다시 시도한 후에도 예상된 능력치 변화가 확인되지 않았습니다.",
    ["3D Portrait render failed: The player model did not load in time."] = "3D 초상화 표시 실패: 캐릭터 모델을 제때 불러오지 못했습니다.",
    ["3D Portrait render failed: Could not assign the player model."] = "3D 초상화 표시 실패: 캐릭터 모델을 지정하지 못했습니다.",
} end)
RegisterLocaleBuilder("koKR", function() return { ["Theme sound"] = "테마 소리" } end)
RegisterLocaleBuilder("koKR", function() return {
    ["Idle motes sound"] = "주변 입자 소리",
    ["Fireworks sound"] = "불꽃놀이 소리",
    ["Fade-in sound"] = "페이드 인 소리",
    ["Fade-out sound"] = "페이드 아웃 소리",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "이 효과음을 바꾸려면 WoW 소리 파일 ID를 입력하세요. 0을 입력하면 설정을 지웁니다.",
} end)
RegisterLocaleBuilder("koKR", function() return {
    ["Use Theme Sounds"] = "테마 소리 사용",
    ["Play the theme's animation sounds without changing your level-up sound."] = "레벨 상승 소리를 바꾸지 않고 테마의 애니메이션 소리를 재생합니다.",
    ["Class-coloured portrait background"] = "직업 색상 초상화 배경",
    ["Fill the background behind the 3D player portrait with your class colour."] = "플레이어 3D 초상화 뒤의 배경을 직업 색상으로 채웁니다.",
} end)
RegisterLocaleBuilder("koKR", function() return { ["Stat glint sound"] = "능력치 반짝임 소리" } end)
RegisterLocaleBuilder("koKR", function() return { ["Screenshot every level"] = "레벨이 오를 때마다 스크린샷", ["Take a screenshot after every real level-up."] = "실제 레벨이 오를 때마다 스크린샷을 찍습니다.", ["Could not save the level-up screenshot."] = "레벨 상승 스크린샷을 저장하지 못했습니다." } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("koKR", function() return {
    ["Strength"] = "힘", ["Agility"] = "민첩성", ["Stamina"] = "체력", ["Intellect"] = "지능", ["Spirit"] = "정신력",
    ["Level"] = "레벨",
    ["Health"] = "생명력", ["Mana"] = "마나", ["Default"] = "기본값", ["%d pt"] = "%d pt",
    ["Rage"] = "분노", ["Energy"] = "기력", ["Focus"] = "집중", ["Runic Power"] = "룬 마력", ["Power"] = "자원",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("koKR", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "오류가 발생했습니다(%s). /glu debugreport를 입력하고 보고서를 보내 주세요!",
    ["Debug report"] = "디버그 보고서",
    ["No GnomeLevelUp errors have been recorded."] = "기록된 GnomeLevelUp 오류가 없습니다.",
    ["Stat capture"] = "능력치 수집",
    ["3D portrait rendering"] = "3D 초상화 렌더링",
    ["Level-up popup"] = "레벨 상승 창",
    ["Screenshot"] = "스크린샷",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("koKR", function() return {
    ["Complete trainer reporting"] = "직업 전문가 전체 보고서",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "디버그 모드에서 확인할 수 있는 직업 전문가의 모든 훈련 비용을 기록합니다. /glu trainerreport로 비용을 내보낼 수 있습니다.",
    ["Clear all"] = "모두 지우기",
} end)
