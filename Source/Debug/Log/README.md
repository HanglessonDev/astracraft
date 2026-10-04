# log — v1.1.0

Logging estático (sem autoload/boot order, chamável até em teste): níveis por sink, categorias livres, console humano limpo + arquivo JSONL completo com teto rotativo (nunca mais log de 9 GB).

## Uso

```gdscript
Log.info("tactic", "ordem aceita", {"para": [3, -1]})
Log.file_path = "user://logs/mygame.jsonl"  # UMA linha pra adotar (default é exemplo)
Log.recent(10)  # últimas N do buffer (console debug futuro lê daqui)
```

Categorias: `StringName` livre por sistema. `data` precisa ser JSON (sem `Vector2i` — converta no chamador). `DEBUG` retorna antes de I/O; `ERROR`/`WARN` passam por `push_*` (integração do editor).

## Isolamento em teste (padrão)

Salva os statics, aponta `file_path` pra `user://log_test/`, restaura em `after_test` — ver `tests/test_log.gd` (8 casos).

Dependências: nenhuma. Testes: `tests/test_log.gd` (gdUnit4).
