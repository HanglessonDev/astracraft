---
id: TASK-6.2
title: Grupo ENEMIES + console enxerga o Krustis
status: Done
assignee: []
created_date: '2026-10-07 19:27'
updated_date: '2026-10-07 19:32'
labels: []
dependencies:
  - TASK-6.1
parent_task_id: TASK-6
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nova const GameConfig.ENEMIES com groups no root do inimigo (ASTEROIDS e so rocha). Comandos hp e damage do console passam a resolver o Krustis; teste de pertencimento ao grupo.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Const ENEMIES em GameConfig sem literais espalhadas
- [x] #2 Root do Krustis no grupo
- [x] #3 console hp e damage funcionam no inimigo
- [x] #4 Suite verde
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Evidencia: suite 44/44 (2 casos novos em test_skotavor_krustis: grupo ENEMIES e nao ASTEROIDS; hp 10/10, damage 1 via hurt real, hp 9/10). Token enemy adicionado ao _resolve_target.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Const ENEMIES + root no grupo + console resolve hp/damage no Krustis. Verificado: suite 44/44.
<!-- SECTION:FINAL_SUMMARY:END -->
