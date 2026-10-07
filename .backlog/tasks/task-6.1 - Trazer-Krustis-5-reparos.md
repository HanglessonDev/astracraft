---
id: TASK-6.1
title: Trazer Krustis + 5 reparos
status: Done
assignee: []
created_date: '2026-10-07 19:27'
updated_date: '2026-10-07 19:30'
labels: []
dependencies: []
parent_task_id: TASK-6
ordinal: 12000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bring-over seletivo da branch task-krustis-enemy-base para a branch de trabalho: montagem, atlas, animacoes, sons, vfx, Vision areas, AcidSpit. Aplica os reparos R1-R5 (HearthResource vira HealthResource, @tool fora, nome do projeto revertido, typos e docstrings no RandomDirection, nametag por instancia de cena). Nao traz @tool nem config/name.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Arquivos do inimigo presentes na branch de trabalho
- [x] #2 HearthResource renomeado em todas as ocorrencias
- [x] #3 Sem @tool em HitArea/HurtArea
- [x] #4 config/name intacto
- [x] #5 Suite verde
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Evidencia: bring-over de task-krustis-enemy-base; grep zero HearthResource/typos/@tool em HitArea/HurtArea; diff vazio em project.godot e combat; suite 42/42; smoke 120 frames limpo apos --import (UIDs do atlas e cenas registrados, ctex gerado).
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Krustis trazido com 5 reparos (rename HealthResource, nametag por cena, RandomDirection reescrito, sem @tool, sem rename do projeto). Verificado: suite 42/42 + smoke limpo.
<!-- SECTION:FINAL_SUMMARY:END -->
