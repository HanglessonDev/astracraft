---
id: TASK-6
title: 'TRILHO 1 - Inimigo base Krustis (esqueleto, animacoes, visual)'
status: Done
assignee: []
created_date: '2026-10-07 19:14'
updated_date: '2026-10-07 19:34'
labels: []
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
TRILHO 1 de 2 (independente; Trilho 2 = sistema de AI). Traz a montagem do SkotavorKrustis da user tree para o projeto, sem AI: prefab inerte mas completo e verificado.

TRAZ (da user tree, hoje nao commitado la):
Atlas krustis + krustis_atlas.tres; biblioteca Data/Animations/SkotavorKrustis.tres; SFX com credito (CREDITS ja atualizado la); VisionArea2D + VisibleArea2D + shapes; montagem completa (SteerableBody, rig de ossos, Hurt/Hit, Health, ScorePoint, Weapon com AcidSpit, nametag); instancia no Playground.

REPAROS (obrigatorios no bring-over):
R1. HearthResource vira HealthResource (typo cega o console e quebra padrao).
R2. Remover @tool de HitArea2D/HurtArea2D (motivo desconhecido; perguntar antes se houver resistencia).
R3. Reverter config/name astrocraft-user (nao entra no merge).
R4. RandomDirection: typos RandonDirection e spreed_in_degress + docstrings.
R5. Nametag por instancia da cena (padrao do Player), nao script direto.
R6. Root no grupo ENEMIES (const nova GameConfig.ENEMIES; ASTEROIDS e so rocha — identidade nao se mistura).
R7. Deletar AnimationTree + sub-resources da state machine (peso morto; animacoes via AnimationPlayer na fase do Trilho 2).

ENTREGAVEL VERIFICAVEL: prefab carrega no Playground sem erro; console damage reduz HP passando pela defesa; HP zerado dispara depleted com queue_free + score; nametag mostra HP; suite verde + smoke limpo. Animacao parada ou idle em autoplay (driver vem no Trilho 2).

PONTAS DESTE TRILHO: tipo do Shape da VisionArea (confirmar cone); motivo do @tool; asset de som pendente de licenca (se houver); commit da user tree e PRE-REQUISITO.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Trilho 1 completo: Krustis inerte verificado (montagem, ENEMIES, sem AnimationTree, combate fiado). Suite 46/46 + smoke limpo.
<!-- SECTION:FINAL_SUMMARY:END -->
