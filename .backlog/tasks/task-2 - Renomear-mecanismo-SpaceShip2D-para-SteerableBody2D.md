---
id: TASK-2
title: Renomear mecanismo SpaceShip2D para SteerableBody2D
status: Done
assignee: []
created_date: '2026-10-04 19:26'
updated_date: '2026-10-04 20:38'
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
- [x] #1 class_name SteerableBody2D em arquivo e pasta com 1 grafia so
- [x] #2 Player e Asteroid funcionam sem mudanca de wiring (mesmos NodePaths)
- [x] #3 Zero ocorrencias de SpaceShip2D/Spaceship2d fora do historico do git
- [x] #4 Suite 22/22 verde + smoke da Playground limpo apos o rename
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Merge bf46353 na main; suite 22/22 + smoke limpos pos-merge. Restos do nome antigo so em docs historicos (CHANGELOG, tasks do backlog) e node names de cena preservados de proposito.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Mecanismo virou SteerableBody2D (1 grafia); Player continua possuindo spaceship; verificado com suite, smoke e grep.
<!-- SECTION:FINAL_SUMMARY:END -->
