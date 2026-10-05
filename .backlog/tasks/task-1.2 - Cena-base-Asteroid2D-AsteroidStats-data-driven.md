---
id: TASK-1.2
title: Cena base Asteroid2D + AsteroidStats data-driven
status: Done
assignee: []
created_date: '2026-10-04 17:33'
updated_date: '2026-10-05 05:09'
labels: []
dependencies: []
parent_task_id: TASK-1
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Um tipo novo de asteroide deve custar 1 arquivo de dados, nao 16 cenas. Segue o padrao Weapon2D+WeaponStats que o projeto ja usa: logica na cena base, variacao no resource.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 AsteroidStats expoe textura, raio do colisor, HP, dano, score e parametros de explosao incluindo trauma
- [x] #2 Instanciar a base com dois stats diferentes produz visuais e HPs diferentes
- [x] #3 Asteroide ambiente (sem HP) colide como StaticBody sem rodar logica de dano
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Base + stats entregues: campos visuais, shapes, gameplay e trauma; TypeA/B/C com visuais e HPs distintos; ambiente via destructible=false (desvio documentado do StaticBody original).
<!-- SECTION:FINAL_SUMMARY:END -->
