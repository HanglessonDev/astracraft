---
tipo: dashboard
tags:
  - astracraft
---

# ✦ Dashboard — AstraCraft

> [!warning] Uso
> Este painel lê o frontmatter das notas do catálogo. Rebalancear = editar frontmatter da nota, **nunca** editar tabelas aqui.

## Perfil térmico do catálogo (custo °C/s por componente)

```dataviewjs
const pages = dv.pages('"AstraCraft/catalogo/Componentes"').where(p => p.custo_termico != null);
dv.paragraph("```chart\ntype: bar\nlabels: [" + pages.map(p => `"${p.file.name}"`).join(",") + "]\nseries:\n  - title: custo °C/s\n    data: [" + pages.map(p => p.custo_termico).join(",") + "]\n```");
```

## Contagem por classe de componente

```dataview
TABLE length(rows) AS Total
FROM "AstraCraft/catalogo/Componentes"
GROUP BY classe AS Classe
```

## DPS bruto estimado (Emissores)

> [!info] DPS = dano × cadência, assumindo acerto total, sem processadores.

```dataviewjs
const pages = dv.pages('"AstraCraft/catalogo/Componentes"')
  .where(p => p.classe === "emissor" && p.dano != null);
const dps = pages.map(p => {
  const cad = parseFloat(String(p.cadencia).replace("/s","").replace(",","."));
  return { name: p.file.name, dps: isNaN(cad) ? p.dano : +(p.dano * cad).toFixed(1) };
});
dv.table(["Emissor", "DPS estimado"], dps.map(d => [d.name, d.dps]));
```

## Saúde do catálogo

```dataview
TABLE length(rows) AS Quantidade
FROM "AstraCraft/catalogo"
GROUP BY tipo AS Tipo
SORT Quantidade DESC
```

## Checagens de balanceamento (regras da bíblia)

> [!check] Gatilhos
> - [ ] Todo Gatilho tem pelo menos 2 Emissores compatíveis documentados em Sinergias
> - [ ] Nenhum Componente isolado custa mais de 15 °C/s (governor do Reator, ver [[docs/Sistemas (WPM-Calor-Recuo)]])

> [!check] Build inicial
> - [ ] Build inicial (Canhão Vektor + E1) zera enxame mas NÃO zera arena sem dash (regra de validação §11 da v1)
