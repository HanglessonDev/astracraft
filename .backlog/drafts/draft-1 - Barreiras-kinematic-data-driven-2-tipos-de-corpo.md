---
id: DRAFT-1
title: Barreiras kinematic data-driven (2 tipos de corpo)
status: Draft
assignee: []
created_date: '2026-10-05 05:02'
updated_date: '2026-10-05 05:02'
labels: []
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Taxonomia fechada: 2 tipos de corpo, nao 3. RIGID (RigidBody2D dinamico: deriva, gira, morre, explode) para rochas destruiveis TypeA e TypeB. KINEMATIC (AnimatableBody2D: nunca empurrado; parado ou movido por codigo e animacao) para barreiras como TypeC e derivantes futuros. Sem freeze e sem lock: imunidade a empurrao vira propriedade do tipo. Os mesmos .tres servem as duas cenas (dado nao sabe que corpo o consome); kinematic ignora HP e dano hoje, com flag destructible ja paga para um kinematic-destrutivel futuro. Metodos de aplicacao visual (_apply_visual e _apply_collision) migrar para AsteroidStats, eliminando duplicacao entre consumidores; HP e morte ficam so no consumidor rigid. Derivante com patrulha e classe futura separada (kinematic movido por codigo), nao extensao de flag.
<!-- SECTION:DESCRIPTION:END -->
