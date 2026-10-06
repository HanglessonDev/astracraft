---
id: TASK-4
title: Console de debug runtime (F1) portada do deadweight
status: Done
assignee: []
created_date: '2026-10-06 05:25'
updated_date: '2026-10-06 05:41'
labels: []
dependencies: []
type: feature
ordinal: 10000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Criar input no InputMap para cada necessidade de debug nao escala; cada toggle novo custa acao, fiação e teste. Um console runtime com comandos registrados resolve depuracao crescente sem tocar no InputMap.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Tecla F1 fisica abre/fecha o console sem acao no InputMap
- [x] #2 help lista os 8 comandos v1: help, hp, damage, heal, pos, score, spawn, tags
- [x] #3 damage passa por HurtArea2D.hurt com defesa aplicada
- [x] #4 spawn cria asteroides em anel sem herdar transform do player
- [x] #5 Suite headless verde e smoke Playground 120 frames limpo
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Shell adaptada do deadweight; alvos via GameConfig.PLAYER_SHIP + ASTEROIDS; sub-nos via find_child; spawn via instantiate em current_scene. FIACAO: instancia por level no Playground.tscn (modelo deadweight), sem autoload — decidido apos revisao: autoload nao compra nada tecnico aqui e estado global por conveniencia foi rejeitado.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Autoload revertido; console instanciado no Playground. Nametags fica para task futura separada.

Evidencia: suite 42/42 verde (8 casos test_debug_console: run/parse/help/uso/sem-alvo/toggle-com-pause); toggle cobre expand/collapse + tree.paused; damage usa HurtArea2D.hurt com defesa (mesma funcao do teste letal existente); F1 fisico sem InputMap por leitura de codigo + [input] com so as 4 acoes; smoke Playground 120 frames limpo com console instanciado. Commits: eab3c39, 6c0f288, 5a32f6e, 4349d26.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Console F1 portado do deadweight como instancia por level (sem autoload, decisao revisada). 8 comandos v1 via hurt() real e ScoreSingleton; PLAYER_SHIP identifica a nave. Verificado: suite 42/42 + smoke limpo.
<!-- SECTION:FINAL_SUMMARY:END -->
