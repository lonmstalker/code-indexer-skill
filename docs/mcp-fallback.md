# MCP-first Guide (с CLI fallback)

## Принцип
Используй MCP tools `code-indexer` как основной интерфейс.
CLI — только fallback, если MCP недоступен или нужен локальный git-aware сценарий.

## Project MCP setup reference (Codex, Claude)

### Codex (project-level)

Создай в корне проекта `.codex/config.toml`:

```toml
[mcp_servers.code-indexer]
command = "docker"
args = [
  "run",
  "--rm",
  "-i",
  "-v",
  ".:/workspace",
  "-w",
  "/workspace",
  "-e",
  "OPENAI_API_KEY",
  "-e",
  "ANTHROPIC_API_KEY",
  "-e",
  "OPENROUTER_API_KEY",
  "lonmstalkerd/code-indexer:latest",
  "--db",
  "/workspace/.code-index.db",
  "serve",
]
```

Проверка:

```bash
codex mcp list
```

### Claude Code (project-level)

Вариант 1: через CLI (из корня проекта):

```bash
claude mcp add -s project code-indexer -- \
  docker run --rm -i \
  -v "$PWD:/workspace" \
  -w /workspace \
  -e OPENAI_API_KEY \
  -e ANTHROPIC_API_KEY \
  -e OPENROUTER_API_KEY \
  lonmstalkerd/code-indexer:latest \
  --db /workspace/.code-index.db \
  serve
```

Вариант 2: через `.mcp.json` в корне проекта:

```json
{
  "mcpServers": {
    "code-indexer": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        ".:/workspace",
        "-w",
        "/workspace",
        "-e",
        "OPENAI_API_KEY",
        "-e",
        "ANTHROPIC_API_KEY",
        "-e",
        "OPENROUTER_API_KEY",
        "lonmstalkerd/code-indexer:latest",
        "--db",
        "/workspace/.code-index.db",
        "serve"
      ]
    }
  }
}
```

Проверка:

```bash
claude mcp list
```

## MCP-first: рекомендуемый порядок

1. `index_workspace` — индексация workspace
2. `get_stats` / `get_indexing_status` — проверка готовности индекса
3. Основные запросы:
   - `search_symbols` / `list_symbols` / `get_symbol`
   - `find_definitions`
   - `find_references`
   - `analyze_call_graph`
   - `get_file_outline`
   - `get_imports`
4. Контекст для агента:
   - `prepare_context` (agent orchestrated)
   - `get_context_bundle` (deterministic summary-first)
5. Макро-навигация:
   - `get_project_compass`
   - `expand_project_node`
   - `get_compass`
   - `get_project_commands`
6. При длительных сессиях:
   - `open_session` -> работа -> `close_session`

## CLI fallback mapping (если MCP недоступен)

- `index_workspace` -> `code-indexer index`
- `index_workspace (watch=true)` -> `code-indexer index --watch`
- `index_workspace (include_deps=true)` -> `code-indexer index --deep-deps`
- `get_stats` -> `code-indexer stats`

- `search_symbols` / `list_symbols` -> `code-indexer symbols [QUERY]`
- `find_definitions` -> `code-indexer definition <NAME>`
- `find_references` -> `code-indexer references <NAME>`
- `analyze_call_graph` -> `code-indexer call-graph <FUNC>`
- `get_file_outline` -> `code-indexer outline <FILE>`
- `get_imports` -> `code-indexer imports <FILE>`

- `prepare_context` -> `code-indexer prepare-context "<QUERY>"`
- `manage_tags` -> `code-indexer tags <subcommand>`

- Для changed symbols используй `code-indexer changed` (локальный git-aware fallback).

## Notes

- При работающем MCP не переключайся на CLI без причины.
- Предпочитай consolidated tool names (не legacy aliases).
- Для несохранённых изменений используй `update_files` до поисковых запросов.
