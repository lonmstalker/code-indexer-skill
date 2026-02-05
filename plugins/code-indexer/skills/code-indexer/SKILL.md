---
name: code-indexer
description: "CLI-first семантическая навигация и индексация через code-indexer. Use when you need to index a repo, find definitions/references/symbols, build call graphs, inspect imports/outline, analyze git changes, or search dependencies. Keywords/triggers: code-indexer, index, symbols, definition, references, call-graph, outline, imports, deps, stats, changed, поиск символа, найти определение, граф вызовов, кто вызывает."
---

# Code Indexer (CLI-first)

## Принцип
- **CLI-first**: всегда используй `code-indexer` CLI как основной способ.
- **MCP — только fallback**: см. раздел "References (MCP fallback)".

## Decision Tree (CLI)
```
Нужно что-то найти в коде?
├── Текст/строка/комментарий → rg (НЕ code-indexer)
├── Символ (функция/тип/класс)?
│   ├── Точное имя → code-indexer definition <NAME>
│   ├── Частичное имя → code-indexer symbols <QUERY>
│   └── Есть опечатка → code-indexer symbols <QUERY> --fuzzy
├── Ссылки/использования → code-indexer references <NAME>
│   └── Кто вызывает функцию → code-indexer references <NAME> --callers --depth N
├── Граф вызовов → code-indexer call-graph <FUNC> --direction in|out|both --depth N
├── Структура файла → code-indexer outline <FILE>
├── Импорты → code-indexer imports <FILE> [--resolve]
├── Изменённые символы (git) → code-indexer changed [--base BRANCH]
└── Символ в зависимостях → code-indexer deps find <SYMBOL> [--dep NAME]
```

## CLI Workflow (обязательный минимум)
1. **Индексация**
   - `code-indexer index` (или `code-indexer index <PATH>`)
   - При долгой работе: `--watch`
   - Для зависимостей: `--deep-deps` или `code-indexer deps index`
2. **Проверка состояния**
   - `code-indexer stats` — убедись, что индекс заполнен
3. **Запросы и анализ** (symbols/definition/references/call-graph/outline/imports/changed)

## Перед анализом спроси себя
1. **Scope**: Весь проект или конкретный модуль?
2. **Depth**: Один уровень вызовов или полный граф?
3. **Dependencies**: Нужны ли внешние библиотеки?
4. **Precision**: Достаточно ли fuzzy поиска или нужно точное имя?

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

## NEVER (анти-паттерны)
- **NEVER** используй code-indexer для строк/комментариев — tree-sitter их не индексирует → используй `rg`.
- **NEVER** запускай `--deep-deps` для быстрых сессий — это минуты вместо секунд.
- **NEVER** доверяй `possible` в call-graph без ручной проверки.
- **NEVER** смешивай индексы разных проектов в одном `--db`.
- **NEVER** забывай про `.code-index.db` — добавь в `.gitignore`.
- **NEVER** запускай queries без `code-indexer stats` — убедись что индекс существует.
- **NEVER** используй одновременный write доступ — SQLite single-writer.

## Patterns (CLI-first)

### Быстрое понимание проекта
```bash
code-indexer index
code-indexer stats
code-indexer symbols "main" --kind function
code-indexer outline src/main.rs
```

### Подготовка к рефакторингу
```bash
code-indexer call-graph "TargetFn" --direction in --depth 3
code-indexer references "TargetType" --callers
```

### Проверка изменений
```bash
code-indexer changed --base main
```

## Quick Reference (CLI)
```bash
# Индексация
code-indexer index [PATH]
code-indexer index --watch
code-indexer index --deep-deps

# Поиск
code-indexer symbols <QUERY> [--fuzzy]
code-indexer definition <NAME>
code-indexer references <NAME> [--callers --depth N]

# Анализ
code-indexer call-graph <FUNC> --direction in|out|both --depth N
code-indexer outline <FILE>
code-indexer imports <FILE> [--resolve]
code-indexer changed [--base BRANCH]

# Зависимости
code-indexer deps list
code-indexer deps index [--name NAME]
code-indexer deps find <SYMBOL> [--dep NAME]
code-indexer deps info <NAME>

# Сервис
code-indexer stats
code-indexer clear
```

## Troubleshooting
| Проблема | Причина | Решение |
|----------|---------|---------|
| Пустые результаты | Индекс не создан | `code-indexer index` |
| Устаревшие данные | Файлы изменились | `code-indexer index` (reindex) |
| База corrupted | Concurrent writes | `code-indexer clear && code-indexer index` |
| Медленный index | Большой проект | Используй `--watch` |
| `possible` вызовы | Dynamic dispatch | Проверь вручную, не доверяй слепо |

## References (MCP fallback)
**Загружать ТОЛЬКО если CLI недоступен** или требуется MCP-интеграция.
- MANDATORY: прочитай `references/mcp-fallback.md` полностью.
- Do NOT load, если CLI доступен.
