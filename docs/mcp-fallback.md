# MCP Fallback (только если CLI недоступен)

## Принцип
MCP — запасной маршрут. Используй его только если нельзя вызвать `code-indexer` CLI.

## CLI -> MCP mapping

- `code-indexer index` -> `index_workspace`
- `code-indexer index --watch` -> `index_workspace` with `watch=true`
- `code-indexer index --deep-deps` -> `index_workspace` with `include_deps=true`
- Инкрементальные/несохранённые изменения -> `update_files`

- `code-indexer symbols [QUERY]` -> `list_symbols` (без query) / `search_symbols` (с query)
- `code-indexer definition <NAME>` -> `find_definitions`
- `code-indexer references <NAME>` -> `find_references`
- `code-indexer call-graph <FUNC>` -> `analyze_call_graph`
- `code-indexer outline <FILE>` -> `get_file_outline`
- `code-indexer imports <FILE>` -> `get_imports`
- `code-indexer stats` -> `get_stats`
- Диагностика/мертвый код -> `get_diagnostics`

- `code-indexer prepare-context "<QUERY>"` -> `prepare_context` (agent-orchestrated)
- Deterministic контекст без agent orchestration -> `get_context_bundle`

- `code-indexer tags add-rule/remove-rule/list-rules/preview/apply/stats` -> `manage_tags` with corresponding `action`
- Прогресс длинной индексации -> `get_indexing_status`

## Project compass and commands (MCP-only)

- `get_project_compass` — макро-обзор проекта
- `expand_project_node` — детальный drill-down по узлу
- `get_compass` — task-oriented diversified search
- `get_project_commands` — извлечение run/build/test команд из конфигов

## Sessions (token optimization)

- `open_session` — открыть session и получить mapping
- `close_session` — закрыть session

Используй session, только если schema конкретных tool-вызовов позволяет передавать `session_id`.

## Notes

- Приоритет всегда у CLI: MCP не должен заменять CLI при рабочем локальном бинаре.
- Legacy MCP aliases могут работать, но используй consolidated names (`search_symbols`, `find_definitions`, etc.).
- Для `changed`-анализа предпочтителен CLI (`code-indexer changed`), так как это git-aware локальный сценарий.
