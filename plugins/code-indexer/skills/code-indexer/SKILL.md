---
name: code-indexer
description: "CLI-first семантическая навигация и индексация через code-indexer. Use when you need to index a repo, collect AI-ready context, find definitions/references/symbols, build call graphs, inspect imports/outline, analyze git changes, search dependency symbols/sources, or manage tag inference rules. Keywords/triggers: code-indexer, index, prepare-context, symbols, definition, references, call-graph, outline, imports, deps, tags, stats, changed, поиск символа, найти определение, граф вызовов, кто вызывает."
---

# Code Indexer (CLI-first)

## Принцип
- **CLI-first**: всегда используй `code-indexer` CLI как основной способ.
- **MCP — только fallback**: см. раздел "References (MCP fallback)".

## Decision Tree (CLI)
```
Нужно что-то сделать в коде?
├── Текст/строка/комментарий → rg (НЕ code-indexer)
├── Нужен AI-ready контекст по NL-запросу → code-indexer prepare-context "<QUERY>" [--file ... --task-hint ...]
├── Символ (функция/тип/класс)?
│   ├── Точное имя → code-indexer definition <NAME>
│   ├── Частичное имя / список → code-indexer symbols <QUERY>
│   └── Есть опечатка → code-indexer symbols <QUERY> --fuzzy
├── Ссылки/использования → code-indexer references <NAME>
│   └── Кто вызывает функцию → code-indexer references <NAME> --callers --depth N
├── Граф вызовов → code-indexer call-graph <FUNC> --direction in|out|both --depth N
├── Структура файла → code-indexer outline <FILE> [--start-line N --end-line M --scopes]
├── Импорты → code-indexer imports <FILE> [--resolve]
├── Изменённые символы (git) → code-indexer changed [--base HEAD|BRANCH] [--staged|--unstaged]
├── Зависимости
│   ├── Найти символ → code-indexer deps find <SYMBOL> [--dep NAME]
│   └── Показать исходник символа → code-indexer deps source <SYMBOL> [--dep NAME --context N]
└── Теги/intent слой файлов → code-indexer tags <subcommand>
```

## CLI Workflow (обязательный минимум)
1. **Индексация**
   - `code-indexer index` (или `code-indexer index <PATH>`)
   - При долгой работе: `--watch`
   - Для зависимостей: `--deep-deps` или `code-indexer deps index`
   - Тюнинг индексации: `--profile eco|balanced|max`, `--durability safe|fast`, `--threads N`, `--throttle-ms N`
2. **Проверка состояния**
   - `code-indexer stats` — убедись, что индекс заполнен
3. **Запросы и анализ**
   - symbols/definition/references/call-graph/outline/imports/changed/prepare-context
4. **(Опционально) daemon-режим**
   - `code-indexer serve --transport unix --socket /tmp/code-indexer.sock`
   - затем query-команды с `--remote /tmp/code-indexer.sock`

## Перед анализом спроси себя
1. **Scope**: Весь проект или конкретный модуль?
2. **Depth**: Один уровень вызовов или полный граф?
3. **Dependencies**: Нужны ли внешние библиотеки?
4. **Precision**: Достаточно ли fuzzy поиска или нужно точное имя?
5. **Task Context**: Нужен ли orchestrated контекст (`prepare-context`) вместо ручного набора команд?

## Производительность vs grep
| Операция | code-indexer | grep | Ускорение |
|----------|--------------|------|-----------|
| Поиск определения | 0.007 сек | 0.539 сек | **77x** |
| Граф вызовов | 0.007 сек | 0.380 сек | **54x** |
| Cross-module поиск | 0.011 сек | 0.363 сек | **33x** |

## Экспертные trade-offs

### call-graph vs references --callers
- `references --callers` — плоский список вызовов (1 уровень).
- `call-graph` — граф с глубиной (много уровней).
- **Правило**: 1 уровень → `references --callers`, глубже → `call-graph --depth N`.

### prepare-context vs ручные запросы
- `prepare-context` — один NL-вход и готовый AI-context envelope (agent-orchestrated сбор).
- Ручные команды (`symbols`/`definition`/`references`) — полный контроль и предсказуемость на каждом шаге.
- **Правило**: нужен быстрый agent-ready snapshot → `prepare-context`; нужен точный forensic разбор → ручные команды.

### index profile + durability
- `--profile eco` — минимальная нагрузка, медленнее.
- `--profile balanced` — default, безопасный компромисс.
- `--profile max` — максимум параллелизма, быстрее, но горячее CPU.
- `--durability safe` — надёжнее на длительных/важных индексах.
- `--durability fast` — быстрее bulk-запись (лучше для short-lived локальных прогонов).

### fuzzy-threshold
- `0.7` (default) — баланс точности и шума.
- `0.8-0.9` — меньше шума, хуже для опечаток.
- `0.5-0.6` — максимум совпадений, много мусора.

### dependencies: include_deps vs deps find
- `definition --include-deps` — быстрый поиск определения в deps.
- `deps find` — общий поиск по индексированным зависимостям.
- **Правило**: точная цель → `definition --include-deps`; исследование → `deps find`.

### --deep-deps
- Включает индекс зависимостей вместе с проектом.
- **Trade-off**: +контекст, но индекс растёт в 10–50x и медленнее строится.

### changed: staged/unstaged
- Без `--staged/--unstaged` команда показывает все uncommitted изменения.
- `--staged` / `--unstaged` — когда нужно строго разделить индекс/рабочее дерево.
- **Правило**: быстрый обзор текущей ветки → без флагов; подготовка commit/review → включай нужный флаг явно.

## NEVER (анти-паттерны)
- **NEVER** используй code-indexer для строк/комментариев — tree-sitter их не индексирует → используй `rg`.
- **NEVER** запускай `--deep-deps` для быстрых сессий — это минуты вместо секунд.
- **NEVER** доверяй `possible` в call-graph без ручной проверки.
- **NEVER** смешивай индексы разных проектов в одном `--db`.
- **NEVER** забывай про `.code-index.db` — добавь в `.gitignore`.
- **NEVER** запускай queries без `code-indexer stats` — убедись что индекс существует.
- **NEVER** используй одновременный write доступ — SQLite single-writer.
- **NEVER** используй legacy `code-indexer query ...` в новых сценариях — команда deprecated.
- **NEVER** запускай `prepare-context` без валидного `agent.*` в корневом `.code-indexer.yml`.

## Patterns (CLI-first)

### Быстрое понимание проекта
```bash
code-indexer index
code-indexer stats
code-indexer symbols "main" --kind function
code-indexer outline src/main.rs
```

### AI-ready context для внешнего агента
```bash
code-indexer prepare-context "where is auth token validated?" \
  --file src/auth/middleware.rs \
  --task-hint debugging \
  --agent-timeout-sec 60 \
  --agent-max-steps 6
```

### Подготовка к рефакторингу
```bash
code-indexer call-graph "TargetFn" --direction in --depth 3
code-indexer references "TargetType" --callers
```

### Проверка изменений
```bash
code-indexer changed --base HEAD
code-indexer changed --staged
code-indexer changed --unstaged
```

### Исследование символа в зависимостях
```bash
code-indexer deps find "Serialize" --dep "serde"
code-indexer deps source "Serialize" --dep "serde" --context 15
```

### Правила тегов (intent layer)
```bash
code-indexer tags add-rule "domain:auth" --pattern "**/auth/**" --confidence 0.8
code-indexer tags list-rules --format json
code-indexer tags preview src/auth/service.rs
code-indexer tags apply
```

## Quick Reference (CLI)
```bash
# Индексация
code-indexer index [PATH]
code-indexer index --watch
code-indexer index --deep-deps
code-indexer index --profile eco|balanced|max --durability safe|fast
code-indexer index --threads N --throttle-ms N

# MCP server / daemon
code-indexer serve
code-indexer serve --transport unix --socket /tmp/code-indexer.sock

# Agent context
code-indexer prepare-context "<QUERY>" [--file FILE --task-hint HINT --remote SOCK]

# Поиск и навигация
code-indexer symbols <QUERY> [--fuzzy]
code-indexer symbols [--kind function|type|all --limit N --language LANG --pattern GLOB]
code-indexer definition <NAME>
code-indexer references <NAME> [--callers --depth N]

# Анализ
code-indexer call-graph <FUNC> --direction in|out|both --depth N
code-indexer outline <FILE> [--start-line N --end-line M --scopes]
code-indexer imports <FILE> [--resolve]
code-indexer changed [--base HEAD|BRANCH] [--staged|--unstaged]

# Зависимости
code-indexer deps list [PATH] [--dev] [--format text|json]
code-indexer deps index [PATH] [--name NAME] [--dev]
code-indexer deps find <SYMBOL> [--dep NAME]
code-indexer deps source <SYMBOL> [--dep NAME --context N]
code-indexer deps info <NAME> [PATH]

# Tags / intent layer
code-indexer tags add-rule <TAG> --pattern "<GLOB>" [PATH]
code-indexer tags remove-rule --pattern "<GLOB>" [PATH]
code-indexer tags list-rules [--format text|json] [PATH]
code-indexer tags preview <FILE> [PATH]
code-indexer tags apply [PATH]
code-indexer tags stats

# Сервис
code-indexer stats [--remote SOCK]
code-indexer clear
```

## Troubleshooting
- Пустые результаты: индекс не создан → `code-indexer index`.
- Устаревшие данные: файлы изменились → переиндексируй (`code-indexer index`), затем `code-indexer stats`.
- База corrupted: concurrent writes → `code-indexer clear && code-indexer index`.
- Медленный index / высокая температура CPU: используй `--profile eco` и `--throttle-ms`.
- `prepare-context` падает: проверь `agent.*` в корневом `.code-indexer.yml` (provider/model/endpoint/auth).
- Ошибка `--remote`: убедись, что daemon запущен и `--socket` путь совпадает.
- `possible` вызовы в call-graph: это uncertain edges, проверяй вручную.

## References (MCP fallback)
**Загружать ТОЛЬКО если CLI недоступен** или требуется MCP-интеграция.
- MANDATORY: прочитай `docs/mcp-fallback.md` полностью (если доступен в репозитории).
- Do NOT load, если CLI доступен.
