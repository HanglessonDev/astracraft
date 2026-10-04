---
tipo: moc
tags:
  - astracraft
  - index
---

# 🧭 AstraCraft — Mapa de Conteúdo

> [!abstract] Visão em 1 linha
> *"Você pilota a arma que você projetou — e morre pela arma que você projetou."*
> Detalhes em [[docs/Visão & Pilares|Visão & Pilares]] · snapshot histórico: [[Game Bible - AstraCraft|Game Bible v1 (monolítica)]]

## Documentos de Design

| Doc | Conteúdo |
|---|---|
| [[docs/Visão & Pilares]] | Visão, tagline, pilares ranqueados, core loop |
| [[docs/Sistemas (WPM-Calor-Recuo)]] | Combate, Matriz WPM, energia/calor/recuo, loop de run |
| [[docs/Arena & Level Design]] | Regras de arena, arquétipo da demo, padrões proibidos |
| [[docs/Tom & Narrativa]] | Guia de humor negro + banco de sabor |
| [[docs/HUD & UX]] | Layout da HUD (referência Magicraft traduzida) + estados + legibilidade |
| [[Decisões]] | ADR-lite: toda decisão de visão com data e porquê |
| [[✦ Dashboard]] | Agregações em tempo real do catálogo |
| [[AstraCraft - brainstorm]] | Fonte original (referência histórica) |

## Catálogo Vivo (agregado via Dataview)

### Componentes
```dataview
TABLE classe AS Classe, dano AS Dano, custo_termico AS "°C/s", status AS Status
FROM "AstraCraft/catalogo/Componentes"
SORT classe ASC, file.name ASC
```

### Módulos de Arma
```dataview
TABLE hardpoint AS Hardpoint, slots AS Slots, termico_base AS "Térmico base", recuo AS Recuo, origem_drop AS Origem, status AS Status
FROM "AstraCraft/catalogo/Modulos de Arma"
SORT file.name ASC
```

### Inimigos
```dataview
TABLE hp AS HP, dano_contato AS "Dano contato", dano_tiro AS "Dano tiro", elite AS Elite, status AS Status
FROM "AstraCraft/catalogo/Inimigos"
SORT elite DESC, hp ASC
```

### Sistemas de Bordo
```dataview
LIST efeito
FROM "AstraCraft/catalogo/Sistemas de Bordo"
SORT file.name ASC
```

## Regras desta wiki
- **Nomenclatura oficial** em [[docs/Visão & Pilares#Glossário Oficial|Glossário]] — nunca usar o termo de fantasia antigo para Módulo de Arma.
- Entidade nova = ctrl+T com template de `5 - Modelos/` → cai no MOC e no Dashboard automaticamente.
- Qualquer mudança de visão exige entrada nova em [[Decisões]] antes de editar os docs.
