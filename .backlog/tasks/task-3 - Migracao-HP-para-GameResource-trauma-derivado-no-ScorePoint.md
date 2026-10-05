---
id: TASK-3
title: Migracao HP para GameResource + trauma derivado no ScorePoint
status: In Progress
assignee: []
created_date: '2026-10-05 06:45'
updated_date: '2026-10-05 06:46'
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
- [ ] #1 Asteroid.gd sem logica de HP; applier injeta max_amount e points e mapeia destructible em invulnerable
- [ ] #2 GameResource com flag invulnerable respeitada no decrease
- [ ] #3 ScorePoint calcula trauma (formula + override) e emite scored com os dois valores; campo trauma removido do stats
- [ ] #4 Suite verde e smoke limpo apos a migracao
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. GameResource: invulnerable + gate no decrease. 2. ScorePoint: trauma_override + trauma_for + scored(points, trauma); remover stub. 3. Asteroid.gd: deletar bloco HP/morte/sinais; applier injeta max_amount/points e mapeia destructible->invulnerable. 4. Stats: deletar trauma. 5. Testes: reescrever para fluxo por sinais + curva trauma_for. 6. Suite + smoke.
<!-- SECTION:PLAN:END -->
