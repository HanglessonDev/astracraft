---
id: TASK-1
title: Asteroides ambiente e destruiveis com juices data-driven
status: To Do
assignee: []
created_date: '2026-10-04 17:33'
labels: []
dependencies: []
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Level design precisa de obstaculos (barreiras, rochas flutuantes) e o gameplay precisa de rochas destruiveis. Os 16 asteroides vivem num atlas PNG com JSON proprio de regions (nao grade uniforme). Decisao arquitetural: cena base unica + AsteroidStats por tipo (padrao ja usado em Weapon2D+WeaponStats), nada de 16 prefabs. Camera e responsabilidade do level: o asteroide expoe trauma do shake via sinal, nao sacode nada sozinho.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Barreiras ambiente colocadas na Playground colidem com a nave
- [ ] #2 Asteroide destruivel perde HP, mostra estagios de dano, explode com particulas e emite trauma para a camera do level
- [ ] #3 Suite gdUnit4 cobre stats, thresholds de dano e explosao; suite continua 100% verde
<!-- AC:END -->
