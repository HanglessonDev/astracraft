---
id: TASK-1.4
title: 'Dano, cracks, explosao e contrato de trauma com a camera'
status: To Do
assignee: []
created_date: '2026-10-04 17:33'
labels: []
dependencies: []
parent_task_id: TASK-1
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Sem feedback, dano e invisivel: o jogador precisa ver acerto (flash), progressao de destruicao (cracks em 66 e 33 por cento de HP) e recompensa (explosao). A camera pertence ao level, entao o asteroide emite o trauma num sinal em vez de sacudir. Placeholders procedurais com dimensoes finais para troca drop-in.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Acerto mostra hit flash branco de 2 a 3 frames via modulate
- [ ] #2 Cracks trocam nos thresholds de HP usando overlays genericos reutilizaveis
- [ ] #3 Morte dispara particulas, anel de choque e emite sinal com o trauma; nada de camera dentro do asteroide
- [ ] #4 Placeholders de crack gerados proceduralmente no tamanho e formato finais
<!-- AC:END -->
