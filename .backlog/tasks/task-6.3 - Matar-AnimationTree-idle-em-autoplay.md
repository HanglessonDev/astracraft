---
id: TASK-6.3
title: 'Matar AnimationTree, idle em autoplay'
status: Done
assignee: []
created_date: '2026-10-07 19:27'
updated_date: '2026-10-07 19:33'
labels: []
dependencies:
  - TASK-6.2
parent_task_id: TASK-6
ordinal: 14000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Deleta o no AnimationTree e os sub-resources da state machine do Krustis (peso morto, active=false sem driver). Animacao idle ou moving em autoplay para o prefab nao ficar estatico. Biblioteca .tres preservada para o driver do Trilho 2.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Sem no AnimationTree nem sub-resources de state machine na cena
- [x] #2 Cena carrega sem erro e smoke limpo
- [x] #3 Biblioteca de animacoes intacta
- [x] #4 Suite verde
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Arvore + 16 sub-resources removidos do tscn; autoplay idle pre-existente no Animations preservado com a .tres. Suite 44/44, smoke limpo.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
AnimationTree morta; idle em autoplay via player. Verificado: suite 44/44 + smoke limpo.
<!-- SECTION:FINAL_SUMMARY:END -->
