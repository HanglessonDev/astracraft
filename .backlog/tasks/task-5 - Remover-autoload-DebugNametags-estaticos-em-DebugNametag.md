---
id: TASK-5
title: Remover autoload DebugNametags (estaticos em DebugNametag)
status: In Progress
assignee: []
created_date: '2026-10-06 06:55'
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
- [ ] #1 project.godot sem o autoload DebugNametags
- [ ] #2 show/hide/toggle/is_showing como estaticos em DebugNametag
- [ ] #3 Tags escondidas em build release sem global
- [ ] #4 Teste de toggle e comando tags do console funcionando
- [ ] #5 Suite headless verde e smoke Playground limpo
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Estaticos show_all/hide_all/toggle/is_showing em DebugNametag.gd; release-hide no _ready da tag; deletar DebugNametags.gd; atualizar teste, console, GameConfig, project.godot.
<!-- SECTION:PLAN:END -->
