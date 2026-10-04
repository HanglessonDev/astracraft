# Ferramenta — Bake de Colliders

> **Status:** IDEIA REGISTRADA — implementação adiada de propósito.
> Fluxo atual é manual (1 polígono na nave do player + círculos).
> **Gatilho pra implementar:** quando o volume de inimigos/naves tornar o
> trabalho manual repetitivo. Aí esta nota vira a spec.

## Problema

Gerar colisores justos pra cada sprite à mão não escala: polígono manual
por nave (como o atual da `Player.tscn`, 10 pontos hardcoded) vira gargalo
quando o catálogo de naves/inimigos crescer.

## Premissas aprendidas (pesquisa 2026-10-04)

- **Corpo (física) ≠ área (dano)** — sistemas independentes, estratégias
  diferentes. Não tentar resolver os dois com a mesma forma.
- **Corpo dinâmico precisa de sólido**: `CollisionPolygon2D` em modo
  Solids ou 1 `ConvexPolygonShape2D`. Côncavo só em estático.
- **Área de dano ama círculo**: teste círculo×círculo é ~10× mais barato
  que convexo×convexo; 1 `HurtArea2D` aceita N `CollisionShape2D` filhas
  (não precisa de 1 área por círculo — salvo dano por parte do corpo,
  que é feature, não necessidade).
- **Orçamento saudável p/ corpo dinâmico**: 1–4 pedaços convexos,
  ≤ 8 vértices cada (teto do Box2D, padrão da indústria).
- **Sem pixel-perfect**: threshold de alpha + simplificação bastam;
  detalhe decorativo pequeno deve ser ignorado de propósito.
- **Catto (Box2D)**: decomposição automática é inferior a colisão feita
  à mão — a ferramenta acelera, o ajuste fino continua humano.

## Desenho da ferramenta (`tools/bake_colliders.gd`, batch headless)

1. Varre pasta de PNGs (ex.: `Assets/Images/Ships/`).
2. `BitMap.create_from_image_alpha(img, 0.5)` → máscara do alpha.
3. **Saída A (corpo):** casco convexo via `Geometry2D.convex_hull_points()`
   → salva sidecar `.tres` (`ColliderData` com `PackedVector2Array`) ao
   lado do PNG. Flag `--solid` opcional p/ decomposição côncava real.
4. **Saída B (área):** sugestão de cobertura por círculos (centro+raio,
   algoritmo guloso sobre o alpha) — o dev monta os 2–3 nós no editor
   em ~1 minuto, ajustando no olho.
5. **Relatório:** pontos por polígono, nº de pedaços; avisa se passar do
   orçamento (>4 pedaços num dinâmico).
6. **Teste gdUnit4:** bake de referência assertando polígono não-vazio,
   centrado e dentro dos bounds do sprite.

## Workflow alvo

```powershell
# após dropar PNGs novos em Assets/Images/Ships/
& "E:\Godot\Godot_v4.7.2-stable_win64.exe" --headless --path "F:\GitHub\Godot\astracraft" -s "res://tools/bake_colliders.gd" -- --src "res://Assets/Images/Ships"
# revisar os .tres gerados no git → referenciar nas cenas
```

## Referências

- Docs Godot: `Collision shapes (2D)`, `ConvexPolygonShape2D`,
  `CollisionPolygon2D` (build modes Solids/Segments).
- Box2D docs (Collision): `b2_maxPolygonVertices = 8`; broadphase
  (dynamic AABB tree) × narrowphase (SAT por par convexo).
- Thread erincatto/box2d#513 (decomposição automática × feita à mão).
