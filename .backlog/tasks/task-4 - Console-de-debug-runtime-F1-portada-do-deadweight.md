---
id: TASK-4
title: Console de debug runtime (F1) portada do deadweight
status: In Progress
assignee: []
created_date: '2026-10-06 05:25'
updated_date: '2026-10-06 05:34'
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
- [ ] #1 Tecla F1 fisica abre/fecha o console sem acao no InputMap
- [ ] #2 help lista os 8 comandos v1: help, hp, damage, heal, pos, score, spawn, tags
- [ ] #3 damage passa por HurtArea2D.hurt com defesa aplicada
- [ ] #4 spawn cria asteroides em anel sem herdar transform do player
- [ ] #5 Suite headless verde e smoke Playground 120 frames limpo
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Shell adaptada do deadweight; alvos via GameConfig.PLAYER_SHIP + ASTEROIDS; sub-nos via find_child; spawn via instantiate em current_scene. FIACAO: instancia por level no Playground.tscn (modelo deadweight), sem autoload — decidido apos revisao: autoload nao compra nada tecnico aqui e estado global por conveniencia foi rejeitado.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Autoload revertido; console instanciado no Playground. Nametags fica para task futura separada.
<!-- SECTION:NOTES:END -->
