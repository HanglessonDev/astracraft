---
tipo: inimigo
hp: 900
dano_contato: 20
dano_tiro: 12
elite: true
status: ativo
tags:
  - astracraft
  - inimigo
  - mini_boss
---

# Contador de Estoque

> [!info] Comportamento — mini-boss da demo, FASE ÚNICA (regra travada)
> Hivemind parcial: corpo central lento que gira emitindo espiral dupla de balas (12/s) + cospe 2 [[Caça Sucata]] a cada 15 s. Sem troca de fase; abaixo de 30% HP, cadência +20% (enfurecer numérico, não fase nova).

## Resposta de engenharia (deve ser vencível por ≥2 arquétipos — critério de validação 7)
- **Espiral curva:** [[Lente de Trajetória Curva]] + poço gravitacional para acertar por tabela entre espirais.
- **Mina + On-Hit:** [[Semeador de Mina Proximidade]] na órbita do boss + [[On-Hit]] em cadeia.

## Drops
- **Módulo de Arma garantido:** [[Lança-Singularidade Freio de Mão]] + 2 Componentes.
