# MCP Fallback (только если CLI недоступен)

## Принцип
MCP — запасной маршрут. Используй его, только если нельзя вызвать `code-indexer` CLI.

## CLI → MCP mapping
- `code-indexer index` → `index_workspace`
- `code-indexer index --watch` → `index_workspace` with watch/auto-update (см. schema)
- Инкрементальные обновления → `update_files`
- `symbols` → `list_symbols` / `search_symbols`
- `definition` → `find_definitions`
- `references` → `find_references`
- `call-graph` → `analyze_call_graph`
- `outline` → `get_file_outline`
- `imports` → `get_imports`
- `stats` → `get_stats`
- `diagnostics` → `get_diagnostics`

## Project compass и docs (MCP-only)
- `get_project_compass` — макро-обзор проекта
- `expand_project_node` — детальный drill-down
- `get_compass` — task-oriented поиск по разным типам сущностей
- `get_project_commands` — извлечение run/build/test команд

## Sessions (token optimization)
- `open_session` → открывает session и отдаёт dictionary mapping
- `close_session` → закрывает session
Используй session только если tool schema позволяет передавать `session_id` в последующие вызовы.
