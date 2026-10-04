---
tipo: doc
secao: hud
tags:
  - astracraft
  - doc
---

# HUD & UX

> [!abstract]+ Premissa
> A HUD segue o layout comprovado do Magicraft ([[Decisões#D-10 · Layout de HUD — referência Magicraft|D-10]]): **a Matriz WPM vive permanentemente na tela como linhas numeradas por hardpoint** — nenhuma tela de pausa, nenhum overlay bloqueante. A arena nunca é obstruída; a ação nunca para ([[Decisões#D-01 · Fantasia de poder — modelo híbrido|D-01]]).

---

## 1. Wireframe oficial AstraCraft (ASCII)

```text
+--------------------------------------------------------------------------------------------------+
| ESQ-SUP:                                                          DIR-SUP:        ║ COLUNA DIR  |
|  [◈ mochila][⚙][□][□][□][□][□][□][□]                            [núcleo do        ║ SISTEMAS DE |
|                                                                   objetivo /      ║ BORDO       |
|  (1) [◉ CANHÃO FRONTAL]                                           mini-boss:      ║ (passivos   |
|      [Em][Prc][Gat][Efe]   ← WPM · drag&drop                      fio de energia  ║ coletados,  |
|      °C/s 22 · 4,2s→OH                                            + brilho        ║ c/ nível xN)║
|  (2) [◉ TORRE TRASEIRA]                                           pulsante ]      ║             |
|      [Em][Prc][ ][ ]       ← WPM · drag&drop                                      ║ [S1]        |
|      °C/s 10 · 9,8s→OH                                                            ║ [S2]        |
|                                                                                   ║ [S3]        |
|                                                                                   ║ ...         |
|                        ARENA 100% LIMPA — ação nunca obstruída                    ║ [S12]       |
|                                                                                   ║             |
| ESQ-INF:                                                          DIR-INF:        ║             |
|  ◆120 sucata   ◈2 módulos   ⬡7 peças                              [Z] dash        ║ [S15]       |
|  HP    ▓▓▓▓▓▓▓▓░░░░ 82 (~40% largura)                             [X] interagir   ║             |
|  CALOR ▓▓▓▓▓▓▓▓▓░░░ 74°/100 (~30% largura, laranja)               v0.1.0          ║             |
+--------------------------------------------------------------------------------------------------+
```

## 2. Tradução região-por-região (Magicraft → AstraCraft)

| Região | No Magicraft | Em AstraCraft |
|---|---|---|
| Topo-esq, linha de atributos | Bolsa + habilidades passivas rápidas + engrenagem | Mochila de Componentes não equipados + engrenagem (config; na demo é placeholder) |
| Topo-esq, linhas numeradas 1-3 | 1 círculo de arma + slots de modificadores | **1 linha por hardpoint do Chassi**: círculo = Módulo de Arma equipado; slots quadrados = cadeia WPM (Emissor→Processador→Gatilho→Efeito). Borda da linha mostra °C/s e tempo até overheat |
| Topo-dir, objeto pendurado | Coração/boss com fio amarelo e aura | Indicador do objetivo da arena: núcleo do mini-boss, nós de sabotagem restantes, timer de sobrevivência. Fio/aurora em neon, não orgânico |
| Coluna direita vertical | Relíquias/artefatos (12-15 ícones, nível amarelo subscrito) | **Sistemas de Bordo** coletados (passivos irremovíveis), numeração de nível/quantidade igual |
| Inferior-esq, contadores | Gemas/moedas/chaves x15/x143… | ◆ Sucata Nanotecnológica (moeda de run) · ◈ Módulos de Arma carregados · ⬡ Componentes na mochila |
| Inferior-esq, barra vermelha | HP: 229 | HP — idêntica em espírito; vermelho #FF2A2A |
| Inferior-esq, barra azul | Mana/XP: 208 | **CALOR 0-100** — laranja→vermelho; número sempre legível; inverte para faísca animada durante desarme (2,5s) |
| Inferior-dir, teclas | [Z] [X] [espaço] | [Z] dash · [X] interagir · versão do build |
| Moldura da tela | Borda escura pontilhada/texturizada | Borda industrial pontilhada — **é o canal do flash de overheat** (pulsa laranja antes do desarme; regra de juice 6) |
| Rodapé-esq | v1.0.44f2 | versão do build da demo |

## 3. Regras de interação (travadas)

> [!important]+ WPM = drag & drop na linha numerada
> - **Arrastar** Componente da mochila/contador → soltar no slot da linha. 2 ações, sem submenu.
> - **Arrastar para fora / clique** no slot preenchido → devolve à mochila.
> - **Slot vazio no meio da cadeia** → execução fail-soft: a cadeia roda até ali, sem erro, sem popup.
> - **Linhas crescem com hardpoints futuros** (demo: 2 linhas no [[Vektor-9]]; backlog Hivemind: 3-4).
> - **A ação nunca pausa.** Editar sob fogo = decisão com risco real e piada garantida ([[docs/Tom & Narrativa]]).
> - **Simulador holográfico** e estatísticas expandidas existem apenas na **Oficina** (sala tipada), nunca na HUD de combate.

## 4. Estados da HUD

| Estado | Comportamento |
|---|---|
| Normal | Layout padrão; readouts térmicos atualizando por frame |
| Overheat-warning (>80°) | Borda pontilhada da tela pulsa laranja + som de válvula; número de °C vira texto grande |
| Overheat (100) | Linhas WPM dos hardpoints desarmados ficam escuras com faíscas por 2,5 s; barra de calor vira animação de ventilação; Gatilhos [[On-Overheat]] disparam nesta janela |
| Edição sob fogo | HUD idêntica à normal (não há "modo edição" — apenas o cursor arrastando). A arena continua letal atrás |
| Morte | Tela escurece → veredito de morte com piada ([[docs/Tom & Narrativa#Banco — 8 mensagens de morte|banco]]) + telemetria (o que matou, qual Componente/Gatilho causou) |

## 5. Regras de legibilidade (Pilar 2 + confronto Level Up, [[Decisões#D-09 · Confronto com Level Up!|D-09]])

1. Arena central **sempre limpa**: nenhum elemento fixo de HUD invade a área de jogo.
2. Alpha/intensidade dos projéteis do jogador **menor** que projéteis inimigos (magenta/quente vence ciano/frio na hierarquia).
3. O personagem **nunca** é engolido visualmente pelos próprios efeitos — explosões do jogador têm core transparente.
4. Qualquer ação crítica (dash, interagir, soltar componente) em **≤3 cliques/inputs** (Rogers).
5. Contadores e barras fora do centro: olho sempre volta pra nave em <0,3 s.

---

## 6. Referência-fonte (preservada)

> [!cite]- Descrição original da HUD de referência — Magicraft/Magic Survival (via análise de screenshot por IA, texto integral)
> **Estrutura geral:** HUD fantástica/dark com molduras e botões estilizados; área central limpa; moldura fina escura pontilhada/texturizada envolvendo toda a tela.
>
> **Canto superior esquerdo:** barra de inventário rápido (painel horizontal cinza-escuro, contorno bege: ícone de bolsa, fileira de slots circulares com habilidades, slots vazios pretos, engrenagem no extremo). Abaixo, 3 linhas numeradas de habilidades equipadas: círculo maior com número e arma (1=espada azul, 2=cajado, 3=esfera azul) + slots secundários sequenciais com modificadores (9, 5 e 6 ícones respectivamente).
>
> **Canto inferior esquerdo:** contadores empilhados (rubi x15, essência roxa x143, chave prata x2, moeda dourada x45, orbe roxo) e duas barras (~40% e ~30% da largura): HP vermelho intenso (`229`) e Mana/XP azul elétrico (`208`), cada uma com orbe colorido à esquerda. Versão em fonte minúscula (`v1.0.44f2`).
>
> **Coluna direita:** painel vertical cinza-escuro com textura de pedra/pergaminho, ~12-15 medalhões de relíquias empilhados de cima a baixo, alguns com numeração amarela subscrita (nível/quantidade).
>
> **Canto superior direito:** coração orgânico com olho central amarelo (boss/objetivo), suspenso por linha amarela brilhante, com aura circular laranja/vermelha.
>
> **Canto inferior direito:** teclas simuladas `[Z] [X] [ ]` + marca d'água `THEGAMER`.
>
> **Wireframe ASCII original e diagramas Mermaid (grid layout + mindmap de cores/propriedades):** fornecidos pelo diretor do projeto como blueprint textual para IAs sem visão — ver histórico da sessão de design (2026-10-02). Mindmap original: atributos (fundo cinza escuro/bordas bege), HP #FF0000 ~40%, MP #0088FF ~30%, coluna relíquias ~15 ícones, boss tracker suspenso por linha amarela.

> [!note]+ Adaptações de identidade aplicadas
> Molduras industriais sci-fi em vez de pedra/pergaminho · ícones neon ciano/magenta (Pilar 2) · fonte monoespaçada tática nos readouts °C/s · boss tracker numérico/energético em vez de orgânico.
