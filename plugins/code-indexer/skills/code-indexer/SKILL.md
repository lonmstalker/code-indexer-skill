---
name: code-indexer
description: "MCP-first семантическая навигация и индексация через code-indexer. Use when you need to prepare context, find definitions/references/symbols, build call graphs, inspect imports/outline, analyze diagnostics/stats, navigate project compass, manage file tags, or work with dependencies. Keywords/triggers: code-indexer, mcp, prepare_context, get_context_bundle, search_symbols, list_symbols, find_definitions, find_references, analyze_call_graph, get_file_outline, get_imports, get_diagnostics, get_stats, get_project_compass, get_compass, manage_tags, open_session, close_session, index_workspace, update_files, поиск символа, найти определение, граф вызовов, кто вызывает."
---

# Code Indexer (MCP-first)

## Принцип
- **MCP-first**: если доступны MCP tools code-indexer, используй их как основной интерфейс.
- **CLI — fallback**: только если MCP недоступен, либо нужен локальный сценарий (например, `code-indexer changed`).

## Decision Tree (MCP-first)
```
Нужно что-то сделать в коде?
├── MCP tools доступны?
│   ├── Да → MCP path
│   │   ├── Индексация → index_workspace / update_files
│   │   ├── AI-context → prepare_context (agent) или get_context_bundle (deterministic)
│   │   ├── Поиск symbols → search_symbols / list_symbols / get_symbol
│   │   ├── Определения → find_definitions
│   │   ├── Ссылки/вызовы → find_references
│   │   ├── Граф вызовов → analyze_call_graph
│   │   ├── Структура/импорты → get_file_outline / get_imports
│   │   ├── Диагностика/статус → get_diagnostics / get_stats / get_indexing_status
│   │   ├── Макро-навигация проекта → get_project_compass / expand_project_node / get_compass / get_project_commands
│   │   └── Теги файлов → manage_tags
│   └── Нет → CLI fallback
│       ├── Индексация → code-indexer index
│       ├── Запросы → symbols|definition|references|call-graph|outline|imports|stats
│       └── Git-изменения → changed
└── Нужен поиск по строкам/комментариям → rg (НЕ code-indexer)
```

## MCP Workflow (обязательный минимум)
1. **Индексация workspace**
   - `index_workspace` (watch/include_deps при необходимости)
2. **Проверка состояния индекса**
   - `get_stats` (+ `get_indexing_status` для long-running индексации)
3. **Запросы и анализ**
   - `search_symbols` / `find_definitions` / `find_references` / `analyze_call_graph` / `get_file_outline` / `get_imports`
4. **Контекст для агента**
   - `prepare_context` (agent-orchestrated)
   - `get_context_bundle` (deterministic summary-first)
5. **Token optimization (опционально)**
   - `open_session` -> работа в рамках `session_id` -> `close_session`

## CLI Fallback Workflow
1. `code-indexer index`
2. `code-indexer stats`
3. Нужные команды (`symbols`/`definition`/`references`/`call-graph`/`outline`/`imports`)
4. Для git-изменений: `code-indexer changed`

## Перед анализом спроси себя
1. **Context Mode**: нужен agent-orchestrated контекст (`prepare_context`) или deterministic (`get_context_bundle`)?
2. **Scope**: весь workspace или конкретный модуль/файл?
3. **Depth**: один уровень ссылок или многоуровневый граф вызовов?
4. **Dependencies**: нужны ли include_deps/dependency sources?
5. **Session**: оправдано ли открывать `open_session` для экономии токенов?

## Экспертные trade-offs

### prepare_context vs get_context_bundle
- `prepare_context` — orchestration через internal agent, быстрее для "дай контекст по задаче".
- `get_context_bundle` — deterministic/schematic выход, удобнее для контролируемых pipelines.
- **Правило**: exploratory/agent task -> `prepare_context`; строгий и воспроизводимый контекст -> `get_context_bundle`.

### search_symbols vs list_symbols
- `search_symbols` — query-driven поиск (fuzzy/regex/filters).
- `list_symbols` — обзор symbols без query (или с минимальными фильтрами).
- **Правило**: есть конкретная гипотеза по имени -> `search_symbols`; обзор модуля/файла -> `list_symbols`.

### find_references vs analyze_call_graph
- `find_references` — usages/callers (быстро и плоско).
- `analyze_call_graph` — многослойные связи вызовов с направлением и depth.
- **Правило**: impact-check 1-2 шага -> `find_references`; глубокий flow-analysis -> `analyze_call_graph`.

### get_stats vs get_indexing_status
- `get_stats` — snapshot по текущему состоянию индекса.
- `get_indexing_status` — runtime прогресс во время индексации.
- **Правило**: регулярная проверка готовности -> `get_stats`; мониторинг ongoing indexing -> `get_indexing_status`.

### MCP vs CLI for changed symbols
- MCP фокусируется на семантическом API workspace.
- `code-indexer changed` остаётся практичным git-aware локальным fallback.
- **Правило**: приоритет MCP; для git diff по локальной ветке допустим CLI fallback.

## NEVER (анти-паттерны)
- **NEVER** начинай с CLI, если MCP tools доступны и работают.
- **NEVER** используй deprecated MCP aliases, когда доступны consolidated tools.
- **NEVER** используй code-indexer для строк/комментариев — применяй `rg`.
- **NEVER** доверяй `possible` вызовам в call graph без ручной верификации.
- **NEVER** забывай закрывать long-lived session (`close_session`) после `open_session`.
- **NEVER** смешивай разные проекты в одной DB при CLI fallback (`--db`).
- **NEVER** запускай CLI queries без проверки индекса (`code-indexer stats`) при fallback сценарии.

## Patterns (MCP-first)

### Быстрый onboarding в проект
- `index_workspace`
- `get_stats`
- `get_project_compass`
- `expand_project_node`
- `get_compass`

### Task-oriented context для агента
- `prepare_context` с `query`, `file`, `task_hint`
- при необходимости follow-up через `suggested_tool_calls`

### Детерминированная контекстная выжимка
- `get_context_bundle` с budget/format
- затем точечные `find_definitions`/`find_references`

### Анализ влияния рефакторинга
- `search_symbols`
- `find_references` (include_callers/depth)
- `analyze_call_graph` (direction/depth)

### Работа с unsaved изменениями
- `update_files`
- повторные `search_symbols`/`find_definitions` для overlay-результатов

### Теги и intent слой
- `manage_tags` (add/remove/list/preview/apply/stats)

## Quick Reference

### MCP-first
```text
index_workspace
update_files
list_symbols
search_symbols
get_symbol
find_definitions
find_references
analyze_call_graph
get_file_outline
get_imports
get_diagnostics
get_stats
get_context_bundle
prepare_context
get_doc_section
get_project_commands
get_project_compass
expand_project_node
get_compass
open_session
close_session
manage_tags
get_indexing_status
```

### CLI fallback
```bash
# Индексация и сервис
code-indexer index [PATH]
code-indexer stats
code-indexer serve --transport unix --socket /tmp/code-indexer.sock

# Поиск и анализ
code-indexer symbols [QUERY] [--fuzzy]
code-indexer definition <NAME>
code-indexer references <NAME> [--callers --depth N]
code-indexer call-graph <FUNC> --direction in|out|both --depth N
code-indexer outline <FILE>
code-indexer imports <FILE> [--resolve]

# Git / deps / tags
code-indexer changed [--base REF] [--staged|--unstaged]
code-indexer deps list|index|find|source|info
code-indexer tags add-rule|remove-rule|list-rules|preview|apply|stats
```

## Troubleshooting
- MCP tools не видны: проверь конфиг MCP-клиента и доступность `code-indexer serve` endpoint.
- `prepare_context` возвращает ошибку: проверь `agent.*` в корневом `.code-indexer.yml`.
- Пустые результаты после индексирования: вызови `get_stats` и проверь scope/path.
- Overlay не учитывается: убедись, что `update_files` отправлен до query.
- Высокое потребление токенов: используй `open_session` + compact/minimal форматы.
- В fallback CLI stale данные: переиндексируй (`code-indexer index`), затем `code-indexer stats`.

## References
- Основной MCP-путь: `docs/mcp-fallback.md` (описание MCP-first и CLI fallback)
- CLI reference: `docs/usage.md`
