---
id: TASK-5
title: Remover autoload DebugNametags (estaticos em DebugNametag)
status: Done
assignee: []
created_date: '2026-10-06 06:55'
updated_date: '2026-10-06 06:58'
labels: []
dependencies: []
type: task
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Autoload para guardar um booleano de visibilidade e repassar call_group: estado global por conveniencia, com acoplamento de boot. As operacoes em massa viram funcoes estaticas na classe que ja tem class_name; cada tag se esconde em release sozinha.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 project.godot sem o autoload DebugNametags
- [x] #2 show/hide/toggle/is_showing como estaticos em DebugNametag
- [x] #3 Tags escondidas em build release sem global
- [x] #4 Teste de toggle e comando tags do console funcionando
- [x] #5 Suite headless verde e smoke Playground limpo
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Estaticos show_all/hide_all/toggle/is_showing em DebugNametag.gd; release-hide no _ready da tag; deletar DebugNametags.gd; atualizar teste, console, GameConfig, project.godot.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Evidencia: suite 42/42 verde (toggle via estaticos no teste); comando tags compila e suite verde; release-hide por leitura de codigo (OS.is_debug_build no _ready da tag); smoke Playground 120 frames limpo sem o autoload. Commit a9689b5.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Autoload deletado; bulk em estaticos de DebugNametag, release-hide na tag, set_entity_visible morto junto. Verificado: suite 42/42 + smoke limpo.
<!-- SECTION:FINAL_SUMMARY:END -->
