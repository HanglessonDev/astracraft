---
id: TASK-2.2
title: Executar rename + suite + smoke
status: Done
assignee: []
created_date: '2026-10-04 19:26'
updated_date: '2026-10-04 19:39'
labels: []
dependencies: []
parent_task_id: TASK-2
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Aplica o rename no escopo minimo e prova que nada quebrou: suite gdUnit4 verde e smoke da fase limpo.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Rename aplicado so nos arquivos do plano aprovado
- [x] #2 Suite 100% verde e smoke sem ERROR apos o rename
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Rename executado pelo builder-glm conforme plano do scout; validacao independente do orquestrador: suite 22/22 verde, smoke limpo, grep sem leftovers fora de node names preservados.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
SpaceShip2D virou SteerableBody2D (classe+arquivo+pasta+cena, 1 grafia); nos e NodePaths intactos; verificado com suite 22/22 e smoke sem ERROR.
<!-- SECTION:FINAL_SUMMARY:END -->
