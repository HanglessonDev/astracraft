---
id: TASK-3
title: Migracao HP para GameResource + trauma derivado no ScorePoint
status: Done
assignee: []
created_date: '2026-10-05 06:45'
updated_date: '2026-10-06 05:48'
labels: []
dependencies: []
ordinal: 9000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Asteroid.gd carrega logica de HP embutida (hp, _on_damaged, _die, died, exploded) que duplica o novo fluxo por sinais (HurtArea, GameResource, ScorePoint). Stats ainda tem campo trauma que virou derivado. Fonte dupla da verdade precisa morrer de um lado so.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Asteroid.gd sem logica de HP; applier injeta max_amount e points e mapeia destructible em invulnerable
- [x] #2 GameResource com flag invulnerable respeitada no decrease
- [x] #3 ScorePoint calcula trauma (formula + override) e emite scored com os dois valores; campo trauma removido do stats
- [x] #4 Suite verde e smoke limpo apos a migracao
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. GameResource: invulnerable + gate no decrease. 2. ScorePoint: trauma_override + trauma_for + scored(points, trauma); remover stub. 3. Asteroid.gd: deletar bloco HP/morte/sinais; applier injeta max_amount/points e mapeia destructible->invulnerable. 4. Stats: deletar trauma. 5. Testes: reescrever para fluxo por sinais + curva trauma_for. 6. Suite + smoke.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
AUDITORIA CHANGELOG: commits b098361 e 77b6832 sem entrada no [Unreleased]. b098361: 'Nametag segue o corpo + camadas UI centralizadas'; 77b6832: 'Debug nametags: Label por entidade + API de toggle no autoload'. Faltam entradas no CHANGELOG para estes commits.
<!-- SECTION:NOTES:END -->
