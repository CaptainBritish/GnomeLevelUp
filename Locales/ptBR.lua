local _, ns = ...
local RegisterLocaleBuilder = ns.RegisterLocaleBuilder

-- ptBR: Português (Brasil). English UI strings are the keys; keep format arguments unchanged.
-- Every new UI string needs an entry here and in the other non-English files.

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

-- Register the startup message before selecting the initial language.
-- Core applies the saved choice at ADDON_LOADED.
RegisterLocaleBuilder("ptBR", function() return {
    ["Welcome to GnomeLevelUp! As of 1.4.0 you no longer need to scan trainers manually, the list is pre-populated! Please report any issues you encounter to me on GitHub or Curseforge!"] = "Boas-vindas ao GnomeLevelUp! A partir da versão 1.4.0, você não precisa mais verificar os instrutores manualmente: a lista já está preenchida! Relate qualquer problema que encontrar para mim no GitHub ou Curseforge!",
} end)

-- Trainer-change monitoring and report export.
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

-- Level-up visual effects and ability classification.
RegisterLocaleBuilder("ptBR", function() return {
    ["Portrait pulse and starburst"] = "Pulso e clarão do retrato",
    ["Highlight new abilities"] = "Destacar novas habilidades",
    ["Emphasize stat gains"] = "Destacar ganhos de atributos",
    ["New ability"] = "Nova habilidade",
    ["Rank upgrade"] = "Melhoria de grau",
} end)

-- Optional texture effects, shared by both Animation menus.
RegisterLocaleBuilder("ptBR", function() return {
    ["Portrait sparks"] = "Faíscas do retrato",
    ["New ability sparkles"] = "Brilhos nas novas habilidades",
    ["Background embers"] = "Brasas no fundo",
    ["Frame edge glow"] = "Brilho da moldura",
} end)

-- Debug-only particle tuning. Counts, size and peak opacity are independent.
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

-- Portrait settle, fixed-position stat counters and centre-out dividers.
RegisterLocaleBuilder("ptBR", function() return {
    ["Portrait and ring settle"] = "Acomodar retrato e aro",
    ["Reveal dividers"] = "Revelar divisórias",
} end)
RegisterLocaleBuilder("ptBR", function() return { ["Animated Elements"] = "Elementos animados" } end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Starburst opacity (%)"] = "Opacidade do clarão radial (%)",
    ["Portrait pulse opacity (%)"] = "Opacidade do pulso do retrato (%)",
    ["Frame edge glow opacity (%)"] = "Opacidade do brilho da borda (%)",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Copy"] = "Copiar",
    ["Press Ctrl+C to copy. The field clears afterward."] = "Pressione Ctrl+C para copiar. O campo será limpo em seguida.",
} end)

-- Profile controls and sharing messages.
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

-- Profile-sharing window.
RegisterLocaleBuilder("ptBR", function() return {
    ["Profile name (optional)"] = "Nome do perfil (opcional)",
    ["Invalid profile string."] = "Texto de perfil inválido.",
    ["Invalid profile settings."] = "Configurações de perfil inválidas.",
} end)

-- Profile management.
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

-- First-run setup.
RegisterLocaleBuilder("ptBR", function() return {
    ["GLU First Time Setup"] = "GLU — Configuração inicial",
    ["Finish setup"] = "Concluir configuração",
    ["Change these choices anytime in Options."] = "Você pode alterar estas escolhas a qualquer momento nas opções.",
} end)

-- Setup shortcuts for pet training and motion.
RegisterLocaleBuilder("ptBR", function() return {
    ["Show pet skills"] = "Mostrar habilidades dos ajudantes",
    ["Enable animations"] = "Ativar animações",
} end)

-- Setup heading.
RegisterLocaleBuilder("ptBR", function() return { ["Welcome to GnomeLevelUp!"] = "Boas-vindas ao GnomeLevelUp!" } end)

-- Decorative effects master switch.
RegisterLocaleBuilder("ptBR", function() return { ["Background animations"] = "Animações de fundo" } end)

-- Popup orientation, independent of Compact Layout.
RegisterLocaleBuilder("ptBR", function() return { ["Horizontal layout"] = "Layout horizontal" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Player 3D portrait"] = "Retrato 3D do jogador" } end)
RegisterLocaleBuilder("ptBR", function() return { ["3D model rotation (degrees)"] = "Rotação do modelo 3D (graus)", ["3D model depth"] = "Profundidade do modelo 3D", ["3D model horizontal position"] = "Posição horizontal do modelo 3D", ["3D model vertical position"] = "Posição vertical do modelo 3D", ["3D model scale (%)"] = "Escala do modelo 3D (%)" } end)
RegisterLocaleBuilder("ptBR", function() return { ["3D mask size (%)"] = "Tamanho da máscara 3D (%)" } end)
RegisterLocaleBuilder("ptBR", function() return { ["3D viewport size (%)"] = "Tamanho da área de visualização 3D (%)" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Milestone Animations"] = "Animações de marcos" } end)

-- Milestone firework debug tuning.
RegisterLocaleBuilder("ptBR", function() return { ["Firework size (%)"] = "Tamanho dos fogos de artifício (%)", ["Firework opacity (%)"] = "Opacidade dos fogos de artifício (%)" } end)

-- Non-Modern content inset debug control.
RegisterLocaleBuilder("ptBR", function() return { ["Frame inset (px)"] = "Margem da moldura (px)" } end)

-- Optional popup finishing effects.
RegisterLocaleBuilder("ptBR", function() return { ["Portrait ring glint"] = "Brilho do anel do retrato", ["Ability reveal shine"] = "Brilho ao revelar habilidades", ["Milestone anticipation"] = "Antecipação de marcos", ["Stat impact sparks"] = "Faíscas de ganho de atributos", ["Background depth"] = "Profundidade do fundo", ["Closing animation"] = "Animação de fechamento", ["Milestone color transition"] = "Transição de cor dos marcos" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Screenshot milestones"] = "Capturas de tela nos marcos" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Portrait motes"] = "Partículas do retrato", ["Background motes"] = "Partículas de fundo" } end)
RegisterLocaleBuilder("ptBR", function() return { ["3D Portraits may consume more memory."] = "Retratos 3D podem consumir mais memória." } end)

-- Retail stat preferences and abbreviated number units.
RegisterLocaleBuilder("ptBR", function() return {
    ["Shorten stat totals"] = "Abreviar totais de atributos",
    ["Relevant stats only"] = "Apenas atributos relevantes",
    ["%sk"] = "%s mil", ["%sm"] = "%s mi", ["%sb"] = "%s bi",
} end)

-- Sound choices without an independent volume override.
RegisterLocaleBuilder("ptBR", function() return { ["Uses game volume"] = "Usa o volume do jogo" } end)

-- Personal-best level time comparison.
RegisterLocaleBuilder("ptBR", function() return {
    ["Show faster leveling times"] = "Mostrar novos recordes ao subir de nível",
    ["Fastest level: %s"] = "Novo recorde: %s",
    ["%dh %02dm %02ds"] = "%dh %02dmin %02ds", ["%dm %02ds"] = "%dmin %02ds", ["%ds"] = "%ds",
} end)

-- Max-level celebration and experimental animation audio.
RegisterLocaleBuilder("ptBR", function() return {
    ["Max Level Celebration"] = "Celebração do nível máximo",
    ["Time to max level: %s"] = "Tempo até o nível máximo: %s",
    ["%dd %02dh %02dm %02ds"] = "%dd %02dh %02dmin %02ds",
    ["Portrait impact sound"] = "Som do impacto do retrato",
    ["Starburst sound"] = "Som do clarão do retrato",
} end)

-- Level-time clock and record replacement.
RegisterLocaleBuilder("ptBR", function() return {
    ["Time to Level: %s"] = "Tempo para subir de nível: %s",
    ["New fastest time!:"] = "Novo melhor tempo!:",
    ["New fastest time!: %s"] = "Novo melhor tempo!: %s",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Glint finishing spark"] = "Faísca final do reflexo",
    ["Portrait shine"] = "Brilho do retrato",
    ["Ring surges"] = "Descargas do anel",
    ["Max-level portrait sparks"] = "Faíscas do retrato no nível máximo",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["New Best Time!"] = "Novo melhor tempo!",
    ["Fastest Time: %s"] = "Melhor tempo: %s",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Abbreviate stat names"] = "Abreviar nomes dos atributos",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["%sM %sk"] = "%s mi %s mil",
    ["Recorded level timers and best times reset for this character."] = "Tempos de nível e recordes salvos deste personagem foram redefinidos.",
} end)

-- Classic Mode and first-time setup descriptions.
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

-- Independent typography and combined level-up summaries.
RegisterLocaleBuilder("ptBR", function() return {
    ["Stat text size"] = "Tamanho do texto dos atributos",
    ["Heading text size"] = "Tamanho dos títulos",
    ["Time to Level text size"] = "Tamanho do texto de tempo de nível",
    ["Level %d - %d"] = "Níveis %d - %d",
    ["Time for %d levels: %s"] = "Tempo para %d níveis: %s",
} end)

-- Optional secondary-stat page. Values come from the selected client flavour.
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

-- Shared descriptions for controller and standard Options.
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
    ["Take a screenshot when a real level-up matches the selected milestone interval."] = "Tire uma captura de tela quando uma subida de nível real corresponder ao intervalo de marcos selecionado.",
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

-- Minimap preview shortcut.
RegisterLocaleBuilder("ptBR", function() return { ["Middle-click: Preview Level-Up"] = "Botão do meio: prévia de subida de nível" } end)

-- Version 1.5.2 timing and replay controls.
RegisterLocaleBuilder("ptBR", function() return {
    ["Switch to secondary stats at"] = "Mudar para atributos secundários em",
    ["Choose the percentage of display time spent on primary stats."] = "Escolha a porcentagem do tempo de exibição dedicada aos atributos principais.",
    ["Replace primary stats with secondary stats during the popup."] = "Substitui os atributos principais pelos secundários durante o aviso.",
    ["Right-click: Replay last level-up"] = "Botão direito: repetir a última subida de nível",
    ["No recorded level-up to replay yet."] = "Nenhuma subida de nível registrada para repetir.",
} end)

-- Complete main-menu help and expanded animation descriptions.
RegisterLocaleBuilder("ptBR", function() return {
    ["Adjust the space between popup sections."] = "Ajusta o espaço entre as seções do aviso.",
    ["Compare trainer services with the bundled catalogue and offer a report when they differ."] = "Compara serviços dos treinadores com o catálogo incluído e oferece um relatório quando há diferenças.",
    ["Open saved trainer differences and instructions for exporting a report."] = "Abre as diferenças salvas e as instruções de exportação do relatório.",
    ["Include available Warlock grimoires for every demon instead of only the active pet."] = "Inclui grimórios disponíveis para todos os demônios do bruxo, não apenas o ajudante ativo.",
    ["Enter an addon-relative OGG file path for the custom level-up sound."] = "Digite o caminho de um arquivo OGG relativo ao addon para o som personalizado.",
    ["Choose a custom sound registered by this addon or SharedMedia."] = "Escolha um som personalizado registrado por este addon ou SharedMedia.",
    ["Show advanced tuning controls, test commands and performance counters."] = "Mostra ajustes avançados, comandos de teste e contadores de desempenho.",
    ["Print measured addon timings in chat. Debug mode must be enabled to collect them."] = "Exibe os tempos medidos no bate-papo. Ative a depuração para coletá-los.",
    ["Clear performance counters before measuring another popup."] = "Limpa os contadores antes de medir outro aviso.",
    ["Choose automatic client detection or force Retail or Forever rules."] = "Escolha detecção automática do cliente ou force as regras Retail ou Forever.",
    ["Update the displayed trainer-cache information."] = "Atualiza as informações exibidas sobre o cache de treinadores.",
    ["Enter a name to create a profile or rename the current one."] = "Digite um nome para criar um perfil ou renomear o atual.",
    ["Save the current options as a new profile with the entered name."] = "Salva as opções atuais em um novo perfil com o nome informado.",
    ["Rename the selected profile. The Default profile cannot be renamed."] = "Renomeia o perfil selecionado. O perfil padrão não pode ser renomeado.",
    ["Delete the selected profile after confirmation. The Default profile cannot be deleted."] = "Exclui o perfil selecionado após confirmação. O perfil padrão não pode ser excluído.",
    ["Restore all options to their defaults; recorded level times and trainer reports remain."] = "Restaura as opções padrão; mantém tempos de nível e relatórios salvos.",
    ["Move the 3D portrait closer to or farther from the camera."] = "Aproxima ou afasta o retrato 3D da câmera.",
    ["Move the 3D portrait left or right inside its viewport."] = "Move o retrato 3D para a esquerda ou direita dentro da área.",
    ["Move the 3D portrait up or down inside its viewport."] = "Move o retrato 3D para cima ou para baixo dentro da área.",
    ["Turn the 3D portrait around its vertical axis."] = "Gira o retrato 3D em torno do eixo vertical.",
    ["Change the size of the 3D character model."] = "Altera o tamanho do modelo 3D do personagem.",
    ["Change the circular mask that clips the 3D portrait."] = "Altera a máscara circular que recorta o retrato 3D.",
    ["Change the 3D rendering area around the portrait."] = "Altera a área de renderização 3D ao redor do retrato.",
    ["Resize the ring artwork without resizing the portrait."] = "Redimensiona a arte do aro sem redimensionar o retrato.",
    ["Move the ring artwork left or right."] = "Move o aro para a esquerda ou direita.",
    ["Move the ring artwork up or down."] = "Move o aro para cima ou para baixo.",
    ["Adjust the empty inset between textured borders and popup content."] = "Ajusta a margem vazia entre as bordas com textura e o conteúdo do aviso.",
    ["Mirror this frame piece horizontally."] = "Espelha esta peça da moldura horizontalmente.",
    ["Mirror this frame piece vertically."] = "Espelha esta peça da moldura verticalmente.",
    ["Change the colour of the named popup element. Class colours may override accent colours."] = "Altera a cor do elemento indicado. Cores de classe podem substituir as cores de destaque.",
    ["Tint this individual frame piece."] = "Tinge apenas esta peça da moldura.",
    ["Rotate this individual frame piece."] = "Gira apenas esta peça da moldura.",
    ["Set the number of particles for this effect. Zero hides them."] = "Define a quantidade de partículas deste efeito. Zero as oculta.",
    ["Resize this effect's particles as a percentage of their normal size."] = "Redimensiona as partículas como porcentagem do tamanho normal.",
    ["Set how opaque this effect's particles appear. Zero makes them invisible."] = "Define a opacidade das partículas. Zero as torna invisíveis.",
    ["Set the opacity of the named animation. Zero makes it invisible."] = "Define a opacidade da animação indicada. Zero a torna invisível.",
    ["Play a sound when this animation fires. Enter a WoW sound file ID; 0 silences this cue."] = "Toca um som quando esta animação dispara. Digite um ID de arquivo sonoro do WoW; 0 silencia este som.",
    ["Celebrate each ten-level milestone with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Celebra cada marco de dez níveis com antecipação do retrato, detalhes mais brilhantes e efeitos de atributos. O modo clássico desativa esses enfeites.",
    ["At the level cap, add curved class-coloured fireworks, portrait-ring sparks and stronger background motes. Classic Mode disables these effects."] = "No nível máximo, adiciona fogos curvos nas cores de classe, faíscas no aro e mais partículas de fundo. O modo clássico desativa esses efeitos.",
    ["Pulse the portrait ring, then reveal a growing starburst behind the portrait. Milestones and max level also add a repeating portrait shine."] = "Faz o aro pulsar e revela uma estrela crescente atrás do retrato. Marcos e nível máximo também adicionam um brilho periódico no retrato.",
    ["Add a reveal shine, glow and twinkling sparks to newly learned ability icons. Rank upgrades remain unhighlighted."] = "Adiciona brilho de entrada, resplendor e faíscas às habilidades recém-aprendidas. Melhorias de grau não recebem destaque.",
    ["Count stat totals up from their old values, then flash the changed numbers. Milestones also add sparks when counting finishes."] = "Anima os totais a partir dos valores anteriores e depois ilumina os números alterados. Marcos também adicionam faíscas ao terminar a contagem.",
    ["Release small drifting lights around the portrait after its starburst. Requires Portrait pulse and starburst."] = "Libera pequenas luzes flutuantes ao redor do retrato após a estrela. Requer pulso e estrela do retrato.",
    ["Show rising particles behind the popup. Milestones and max level increase their density; max level also speeds them up."] = "Mostra partículas subindo atrás do aviso. Marcos e nível máximo aumentam sua densidade; o nível máximo também as acelera.",
    ["Sweep a fading glow along textured frame edges during the opening. This effect is unavailable with Modern."] = "Move um brilho que desaparece pelas bordas com textura durante a abertura. Indisponível com Moderno.",
    ["Start the portrait slightly enlarged, then ease it back to normal size. Milestones also add a brief anticipation flash."] = "Começa com o retrato um pouco ampliado e retorna suavemente ao tamanho normal. Marcos adicionam um breve clarão de antecipação.",
    ["Expand the section divider lines as each section enters. Classic Mode keeps the text transitions but disables this decorative reveal."] = "Expande os divisores quando cada seção entra. O modo clássico mantém as transições de texto, mas desativa esse enfeite.",
    ["Sweep a bright spark around the portrait ring, ending in a larger fading flare. Max level enlarges and flickers the finishing spark."] = "Move uma faísca brilhante pelo aro e termina com um clarão maior que desaparece. No nível máximo, a faísca final cresce e pisca.",
} end)

-- Trellis theme and independent frame selector.
RegisterLocaleBuilder("ptBR", function() return { ["Trellis"] = "Treliça" } end)

-- Flat background selector.
RegisterLocaleBuilder("ptBR", function() return { ["Solid Colour"] = "Cor sólida" } end)

-- Background colour/alpha picker help.
RegisterLocaleBuilder("ptBR", function() return { ["Choose the background colour and transparency. Solid Colour uses this colour directly."] = "Escolha a cor e a transparência do fundo. Cor sólida usa essa cor diretamente." } end)

-- Marine background selector.
RegisterLocaleBuilder("ptBR", function() return { ["Coral"] = "Coral" } end)

-- Scratched stone background selector.
RegisterLocaleBuilder("ptBR", function() return { ["Scratched Stone"] = "Pedra riscada" } end)

-- Independent asset hue preferences and selected-theme reset.
RegisterLocaleBuilder("ptBR", function() return { ["Reset Theme Hues"] = "Redefinir cores do tema", ["Restore the selected background, frame and portrait ring to their default hues. Other saved hue preferences are kept."] = "Restaura as cores padrão do fundo, moldura e aro do retrato selecionados. Mantém as outras preferências salvas." } end)

-- Atlas background and fill mode label.
RegisterLocaleBuilder("ptBR", function() return { ["Background Fill Mode"] = "Modo de preenchimento do fundo" } end)

-- Describe the distinct fill behaviours.
RegisterLocaleBuilder("ptBR", function() return { ["Choose Fill to preserve proportions and crop excess, Stretch to resize to the frame, or Tile to repeat the artwork."] = "Preencher preserva as proporções e corta o excesso, Esticar adapta à moldura e Repetir repete a imagem." } end)

-- Background-only names; faction theme/frame names remain unchanged.
RegisterLocaleBuilder("ptBR", function() return { ["Alliance Brick"] = "Tijolos da Aliança" } end)

-- Debug-only Options memory readout.
RegisterLocaleBuilder("ptBR", function() return { ["Memory: %s"] = "Memória: %s", ["Memory: unavailable"] = "Memória: indisponível" } end)

-- Profiling is independent of debug commands and disabled after reload.
RegisterLocaleBuilder("ptBR", function() return { ["Performance profiling enabled."] = "Medição de desempenho ativada.", ["Performance profiling disabled."] = "Medição de desempenho desativada.", ["Profiling is off. Use /glu perf on to record measurements."] = "A medição está desativada. Use /glu perf on para registrar medições." } end)

-- Profiling command help retains literal slash commands.
RegisterLocaleBuilder("ptBR", function() return { ["  /glu perf on|off   - start or stop performance profiling (off after reload)"] = "  /glu perf on|off   - iniciar/parar a medição (desativada ao recarregar)", ["  /glu perf          - print recorded performance diagnostics"] = "  /glu perf          - mostrar os diagnósticos de desempenho registrados" } end)

-- Level history, account comparisons and temporary debug samples.
RegisterLocaleBuilder("ptBR", function() return { ["Level History"] = "Histórico de níveis", ["Compare account-wide bests"] = "Comparar recordes da conta", ["Compare new level times with your fastest recorded level across characters in the same game mode."] = "Compara novos tempos com o nível mais rápido registrado entre seus personagens no mesmo modo de jogo.", ["Character"] = "Personagem", ["Choose a character whose recorded level times you want to view."] = "Escolha o personagem cujos tempos deseja consultar.", ["History mode"] = "Modo do histórico", ["View Retail or Forever history. Records are kept separate."] = "Veja o histórico de Retail ou Forever. Os registros ficam separados.", ["Reset this character's times"] = "Redefinir tempos deste personagem", ["Clear this character's recorded times and bests in both game modes. Other characters are kept."] = "Apaga tempos e recordes deste personagem nos dois modos. Mantém os outros personagens.", ["Fill sample times (20h)"] = "Tempos de teste (20 h)", ["Fill every level with temporary 20-hour times. New records replace the samples; existing history is not overwritten."] = "Preenche cada nível com tempos temporários de 20 horas. Novos recordes substituem os exemplos sem sobrescrever o histórico existente.", ["Clear sample history"] = "Limpar histórico de teste", ["Remove the temporary sample times and show real records again."] = "Remove os tempos temporários e volta a mostrar os registros reais.", ["Only characters with recorded level times are listed. Missing levels are shown as a dash."] = "Apenas personagens com tempos de nível registrados são listados. Níveis sem dados mostram um traço.", ["Sample history (not saved)"] = "Histórico de teste (não salvo)", ["Recorded: %d / %d"] = "Registrados: %d / %d", ["Total: %s"] = "Total: %s", ["Recorded time"] = "Tempo registrado", ["Personal best"] = "Recorde pessoal", ["Account best"] = "Recorde da conta", ["Review recorded level times and your best times across characters. Hover a row to see which character set the personal best."] = "Veja os tempos registrados e seus melhores tempos entre personagens. Passe sobre uma linha para ver qual personagem definiu o recorde pessoal." } end)

-- Configurable milestone intervals.
RegisterLocaleBuilder("ptBR", function() return { ["Milestone interval"] = "Intervalo dos marcos", ["Every 5 levels"] = "A cada 5 níveis", ["Every 10 levels"] = "A cada 10 níveis", ["Every 20 levels"] = "A cada 20 níveis", ["Choose how often milestone animations and screenshots trigger. Max-level animations use their own toggle."] = "Escolha a frequência das animações e capturas de tela de marcos. As animações de nível máximo têm uma opção própria.", ["Add celebration effects at the selected milestone interval."] = "Adiciona efeitos no intervalo de marcos selecionado.", ["Celebrate the selected milestone interval with portrait anticipation, brighter accents and extra stat effects. Classic Mode disables this flair."] = "Celebra os marcos selecionados com antecipação do retrato, detalhes mais brilhantes e efeitos de atributos. O modo clássico desativa esses efeitos.", ["Choose a level up to 1000 that is a multiple of %d."] = "Escolha um nível até 1000 que seja múltiplo de %d." } end)

-- Recovery instructions for popup, audio and profile-sharing failures.
RegisterLocaleBuilder("ptBR", function() return { ["Could not prepare the level-up popup. Try /reload. If it happens again, report this error: %s"] = "Não foi possível preparar a janela de nível. Tente /reload. Se acontecer novamente, informe este erro: %s", ["Could not play the selected sound. Choose another sound in Options > Sound. Details: %s"] = "Não foi possível tocar o som escolhido. Escolha outro em Opções > Som. Detalhes: %s", ["The level-up popup could not be shown. Try /reload. If it happens again, report the error above."] = "Não foi possível mostrar a janela de nível. Tente /reload. Se acontecer novamente, informe o erro acima.", ["The level cap is unavailable. Wait for loading to finish, then try /glu maxlevel again."] = "O nível máximo está indisponível. Aguarde o carregamento terminar e tente /glu maxlevel novamente.", ["Paste the complete GLU profile export, then try again."] = "Cole a exportação completa do perfil GLU e tente novamente.", ["Export the profile again from an up-to-date GLU installation."] = "Exporte o perfil novamente a partir de uma instalação atualizada do GLU." } end)
RegisterLocaleBuilder("ptBR", function() return { ["Ability Cost Size"] = "Tamanho do custo das habilidades", ["Adjust the size of ability prices for the current layout."] = "Ajusta o tamanho do preço das habilidades no layout atual." } end)
RegisterLocaleBuilder("ptBR", function() return { ["Learning cost: %s"] = "Custo de aprendizado: %s", ["%d abilities"] = "%d habilidades", ["Show a test popup without changing level history. Right-click to choose the number of abilities."] = "Exibe uma prévia sem alterar o histórico. Clique com o botão direito para escolher o número de habilidades." } end)
RegisterLocaleBuilder("ptBR", function() return { ["Show prices in tooltips"] = "Mostrar preços nas dicas", ["Show full learning costs when hovering over abilities."] = "Mostra o custo completo ao passar sobre as habilidades." } end)
RegisterLocaleBuilder("ptBR", function() return { ["Contributors"] = "Colaboradores" } end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Stat capture failed: Expected stat changes were still missing after retrying."] = "Falha ao capturar atributos: As alterações esperadas ainda não apareceram após várias tentativas.",
    ["3D Portrait render failed: The player model did not load in time."] = "Falha ao exibir o retrato 3D: O modelo do personagem não carregou a tempo.",
    ["3D Portrait render failed: Could not assign the player model."] = "Falha ao exibir o retrato 3D: Não foi possível atribuir o modelo do personagem.",
} end)
RegisterLocaleBuilder("ptBR", function() return { ["Theme sound"] = "Som do tema" } end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Idle motes sound"] = "Som de partículas ambientes",
    ["Fireworks sound"] = "Som de fogos de artifício",
    ["Fade-in sound"] = "Som da transição de entrada",
    ["Fade-out sound"] = "Som da transição de saída",
    ["Enter a WoW sound file ID to override this cue. Enter 0 to clear the override."] = "Informe um ID de arquivo de som do WoW para substituir este som. Informe 0 para remover a substituição.",
} end)
RegisterLocaleBuilder("ptBR", function() return {
    ["Use Theme Sounds"] = "Usar sons do tema",
    ["Play the theme's animation sounds without changing your level-up sound."] = "Reproduz os sons das animações do tema sem alterar o som de subida de nível.",
    ["Class-coloured portrait background"] = "Fundo do retrato na cor da classe",
    ["Fill the background behind the 3D player portrait with your class colour."] = "Preenche o fundo atrás do retrato 3D do personagem com a cor da sua classe.",
} end)
RegisterLocaleBuilder("ptBR", function() return { ["Stat glint sound"] = "Som do brilho de atributos" } end)
RegisterLocaleBuilder("ptBR", function() return { ["Screenshot every level"] = "Captura de tela a cada nível", ["Take a screenshot after every real level-up."] = "Tire uma captura de tela após cada subida de nível real.", ["Could not save the level-up screenshot."] = "Não foi possível salvar a captura de tela da subida de nível." } end)

-- Core stat names and shared option values.
RegisterLocaleBuilder("ptBR", function() return {
    ["Strength"] = "Força", ["Agility"] = "Agilidade", ["Stamina"] = "Vigor", ["Intellect"] = "Intelecto", ["Spirit"] = "Espírito",
    ["Level"] = "Nível",
    ["Health"] = "Vida", ["Mana"] = "Mana", ["Default"] = "Padrão", ["%d pt"] = "%d pt",
    ["Rage"] = "Raiva", ["Energy"] = "Energia", ["Focus"] = "Concentração", ["Runic Power"] = "Poder Rúnico", ["Power"] = "Recurso",
} end)

-- Debug reports stay available to players with debug mode off.
RegisterLocaleBuilder("ptBR", function() return {
    ["%s error has occurred, please type /glu debugreport and send the information to me!"] = "Ocorreu um erro (%s). Digite /glu debugreport e me envie o relatório!",
    ["Debug report"] = "Relatório de depuração",
    ["No GnomeLevelUp errors have been recorded."] = "Nenhum erro do GnomeLevelUp foi registrado.",
    ["Stat capture"] = "Captura de atributos",
    ["3D portrait rendering"] = "Renderização do retrato 3D",
    ["Level-up popup"] = "Janela de subida de nível",
    ["Screenshot"] = "Captura de tela",
} end)

-- Complete trainer price reporting and clearing saved reports.
RegisterLocaleBuilder("ptBR", function() return {
    ["Complete trainer reporting"] = "Relatórios completos de instrutores",
    ["Record every readable class trainer price while debug mode is enabled. Export the offered prices with /glu trainerreport."] = "Registra todos os preços legíveis dos instrutores de classe no modo de depuração. Exporte os preços oferecidos com /glu trainerreport.",
    ["Clear all"] = "Limpar tudo",
} end)
