---
id: TASK-2
title: Renomear mecanismo SpaceShip2D para SteerableBody2D
status: To Do
assignee: []
created_date: '2026-10-04 19:26'
labels: []
dependencies: []
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
A classe de fisica (thrust+giro) mente no nome: serve nave, asteroide e futuros veiculos, e ainda tem 3 grafias (SpaceShip2D, Spaceship2d, Spaceship2D). O papel nave continua no veiculo/cena (Player possui spaceship, troca de naves preservada); so o mecanismo vira generico. Escopo minimo: classe+arquivo+pasta+cena; nos das cenas e NodePaths intactos.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 class_name SteerableBody2D em arquivo e pasta com 1 grafia so
- [ ] #2 Player e Asteroid funcionam sem mudanca de wiring (mesmos NodePaths)
- [ ] #3 Zero ocorrencias de SpaceShip2D/Spaceship2d fora do historico do git
- [ ] #4 Suite 22/22 verde + smoke da Playground limpo apos o rename
<!-- AC:END -->
