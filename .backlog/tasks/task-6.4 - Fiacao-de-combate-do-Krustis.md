---
id: TASK-6.4
title: Fiacao de combate do Krustis
status: Done
assignee: []
created_date: '2026-10-07 19:27'
updated_date: '2026-10-07 19:34'
labels: []
dependencies:
  - TASK-6.3
parent_task_id: TASK-6
ordinal: 15000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
HP zerado dispara depleted com queue_free e score (padrao Asteroid); nametag mostra HP; teste de cena matando o inimigo via hurt real.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Morte pontua e libera o no
- [x] #2 Nametag exibe HP do inimigo
- [x] #3 Teste de cena da morte passando
- [x] #4 Suite verde e smoke limpo
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Evidencia: 2 casos novos (nametag mostra HP; dano letal libera o no e soma placar, placar restaurado). Suite 46/46, smoke limpo.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Morte via depleted com score + nametag com HP, ambos testados. Verificado: suite 46/46 + smoke limpo.
<!-- SECTION:FINAL_SUMMARY:END -->
