---
id: TASK-1.1
title: Materializar AtlasTextures do atlas a partir do JSON
status: To Do
assignee: []
created_date: '2026-10-04 17:33'
labels: []
dependencies: []
parent_task_id: TASK-1
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
O atlas e irregular (rects de 104x111 a 255x256) com JSON proprio de nome+rect, entao slice automatico de grade nao serve. Sem os .tres de AtlasTexture, a cena base nao tem como exibir nenhum asteroide. Nomes devem vir do JSON (asteroid_07), nao sprite_0.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Um .tres AtlasTexture por entrada do JSON, com region dentro dos bounds do PNG
- [ ] #2 Nomes dos resources batem com os nomes do JSON
- [ ] #3 filter_clip ativado para nao vazar pixel vizinho sob filtro
<!-- AC:END -->
