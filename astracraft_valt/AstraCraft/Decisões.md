---
tipo: decisoes
tags:
  - astracraft
  - decisoes
---

# Decisões — AstraCraft

> [!important] Regra da casa
> Toda decisão de visão entra aqui **antes** de virar edição nos docs. Formato: data, decisão, porquê, alternativa rejeitada. Nunca reescrever entradas antigas — se mudar de ideia, crie entrada nova marcada **SUPERSEDE**.

---

## D-01 · Fantasia de poder — modelo híbrido · 2026-10-02

**Decisão:** Engenharia = arco (minuto a minuto, entre e durante combates), Execução = superfície (segundo a segundo). Matriz WPM editável **a qualquer momento**, sem trava de safe room — a arena não pausa e o bullet hell disciplina naturalmente.
**Porquê:** pesquisa de mercado (Noita exige anos de tuning + wiki da comunidade; Gungeon/Hades/20MtD vendem execução legível). O diferencial de AstraCraft é a engenharia — mas combate twin-stick exige fluidez. Edição livre (estilo Magicraft, confirmado por memória de gameplay) mantém a agência do engenheiro sem pausa artificial.
**Rejeitada:** edição restrita a safe rooms (modelo Noita) — reduziria o momento-cereja "reeditar sob fogo" e aprofundaria custo de tutorialização.
**Consequência gravada:** critério de validação — edição sob fogo deve ocorrer em ≥50% das runs de playtest, mas nunca impunemente.

## D-02 · Tagline · 2026-10-02

**Decisão:** Oficial PT-BR: *"Cada bala é projeto seu. Cada morte foi culpa do engenheiro."* Alternativa EN: *"Build the gun. Break the galaxy."*
**Porquê:** a PT-BR carrega o humor negro corporativo-fatalista (D-04) — a morte como piada administrativa. Opções diretas demais ("You don't find weapons. You engineer them.") foram descartadas pelo executivo como sem graça.
**Rejeitada:** dominar mercado EN primeiro — público-alvo inicial é o próprio dev + comunidade BR.

## D-03 · Identidade vs Magicraft — diferenciais oficiais · 2026-10-02

**Decisão:** Quatro eixos de diferenciação: (1) recuo/vetor como propriedade tática dos Módulos de Arma, (2) posição/orientação de hardpoints no chassi, (3) poços gravitacionais curvando tiros, (4) juice estilo Nova Drift no vazio.
**Restrição explícita do diretor:** recuo é impulso tático (freio de emergência, deslocamento fino) — **nunca fonte de locomoção**. Quem move é propulsor + dash. Trava: recuo máx 15% da velocidade do dash; proibido "motor a bala".
**Porquê:** tradução 1:1 de Magicraft é camisa de força; o espaço oferece física vetorial que Noita/Magicraft não têm (fundamento: Osmos, Captain Forever).
**Rejeitada:** construção de chassi peça a peça (Captain Forever) — escopo inviável na demo.

## D-04 · Tom · 2026-10-02

**Decisão:** Comédia / humor negro corporativo-fatalista, estilo Magicraft: IA que zoa via estatística fria, morte com atribuição de culpa absurda, nomes de módulos sarcásticos.
**Porquê:** preferência do diretor; transforma friendly-fire da própria engenharia em feature de tom ("morrer pela própria arma é a piada central").
**Limite gravado:** a piada mira a *build*, nunca o jogador. Toda piada contém informação útil (ver [[docs/Tom & Narrativa]]).

## D-05 · Escopo da demo · 2026-10-02

**Decisão:** Demo mínima de validação (1 dev, Godot 4): 1 chassi (Vektor-9), 1 setor (Cemitério de Naves), 1 arquétipo de arena (Anel de Destroços), ~12 componentes, 2-3 Módulos de Arma, calor, dash i-frames (2 cargas / 1,5 s), 4 inimigos, 1 mini-boss de fase única, mensagens de morte.
**Cortes explícitos:** meta-progressão/Estação-Mãe, mapa FTL, naves modulares, chefes multifase, nebulosas elementares. Preservados em backlog com referência ao [[AstraCraft - brainstorm]].

## D-06 · Nomenclatura oficial (glossário) · 2026-10-02

**Decisão:** Chassi (≡ personagem) · Hardpoint · **Módulo de Arma** (≡ wand; nunca usar o termo de fantasia) · Componente (≡ spell: Emissor/Processador/Gatilho) · Sistema de Bordo (≡ relíquia) · Matriz WPM · Calor/Reator · Sucata Nanotecnológica.
**Porquê:** brainstorm original mapeou cajado↔nave de forma confusa; mapeamento correto é personagem↔chassi, wand↔módulo de arma (matriz independente por hardpoint).

## D-07 · Loop de loot e portais · 2026-10-02

**Decisão:** Componentes dropam no chão de inimigos comuns/asteroides; Módulos de Arma só de elites, mini-boss e loja; Sistemas de Bordo de salas de recompensa/baús. Pós-limpeza: 2-3 **portais tipados** (Componentes / Oficina / Loja / Reparo) — roteamento de recursos como decisão estratégica da run.
**Porquê:** modelo Magicraft (wiki + memória de gameplay) — separa execução (arena) de decisão (portal), alimentando a fantasia de engenheiro econômico.
**Pendente consciente:** magnetismo de coleta de drops — não implementar na demo.

## D-08 · Bíblia viva Obsidian-native · 2026-10-02

**Decisão:** Bíblia migra de monolito (`Game Bible - AstraCraft.md`, v1 congelada) para pasta dedicada `AstraCraft/` com MOC, dashboard Dataview/Charts, catálogo 1-nota-por-entidade e templates Templater. Nomenclatura: **MOC**, nunca "index".
**Porquê:** catálogo como dados (frontmatter) elimina tabelas manuais; wikilinks/grafo navegável; templates padronizam expansão pós-demo.

## D-09 · Confronto com Level Up! (Scott Rogers) · 2026-10-02

**Decisão:** Análise exaustiva dos 17 capítulos do resumo `level_up/` contra o design AstraCraft. **4 conflitos reais identificados e resolvidos:**

1. **Edição WPM livre × clareza de HUD/≤3 cliques (L7/L8)** → Resolvido por D-10 (barra permanente, drag&drop direto, ≤3 inputs).
2. **Humor negro na morte × "morte deve significar algo" (L3/L13)** → Sem conflito real: nossa regra "toda piada contém telemetria útil" já satisfaz Rogers — o veredito de morte **ensina**; a piada é embalagem. Reforçado no Pilar 4.
3. **Bullet hell duplo × legibilidade (L6/L8/L10)** → Regra 8 de legibilidade: efeitos do jogador nunca engolem a nave; alpha do projétil do jogador < do inimigo; magenta/quente sempre vence ciano/frio.
4. **Arenas procedurais abertas × gráfico de ritmo autoral (L4/L9)** → Equivalente procedural: arquétipos de arena com composição controlada + objetivos alternados; preenchimento aleatório só dentro da estrutura.

**Rejeitado explicitamente:** DDA/balanceamento dinâmico de dificuldade (L13) — incompatível com aprendizado-por-falha de roguelike. **Irrelevantes na fase demo:** ESRB, QTEs, cutscenes, multiplayer, música licenciada, 8-10h de conteúdo (Rogers fala de produto completo; ele próprio endossa página-única → protótipo primeiro, L17).

## D-10 · Layout de HUD — referência Magicraft · 2026-10-02

**Decisão:** Adotar o layout da HUD do Magicraft (especificado via descrição textual detalhada de screenshot, analisada por IA de visão) como base da HUD AstraCraft, traduzida: linhas numeradas = **hardpoints/WPM permanentes** (drag&drop, nunca pausa); barra azul de mana → **Calor**; coluna direita de relíquias → **Sistemas de Bordo**; contadores empilhados → economia da run; borda pontilhada da tela → canal do flash de overheat. Spec completa: [[docs/HUD & UX]].
**Porquê:** resolve o conflito 1 de D-09 com layout comprovado em título de referência; elimina a necessidade de overlay/tela de montagem; edição sob fogo passa a ser gesto de 1 segundo com risco real (fecha o círculo com D-01).
**Rejeitada:** tela de montagem com overlay translúcido (design anterior da v1) — Rogers L8: nenhuma ação crítica deve exigir mais do que gestos mínimos; overlay em bullet hell duplo obstruía a arena.
**Limite:** linha [3]/habilidade extra não existe na demo (Vektor-9 = 2 hardpoints); estrutura da HUD já prevê N linhas para chassis futuros.
