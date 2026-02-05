# Code-Indexer Skill

Agent skill для семантической индексации и навигации по коду с использованием [code-indexer](https://github.com/USER/code-indexer) CLI.

## Возможности

- **17 языков программирования** с полной поддержкой синтаксиса
- **12 MCP tools** для AI-агентов (Claude, GPT и др.)
- **77x быстрее grep** для поиска определений
- **Semantic analysis** — scope resolution, import resolution, FQDN
- **Call graph с confidence** — различие между certain и possible вызовами
- **Fuzzy search** с терпимостью к опечаткам
- **Git integration** — отслеживание изменённых символов

## Производительность

Бенчмарк на проекте с 2160 файлами:

| Операция | code-indexer | grep | Ускорение |
|----------|--------------|------|-----------|
| Поиск определения | 0.007 сек | 0.539 сек | **77x** |
| Граф вызовов | 0.007 сек | 0.380 сек | **54x** |
| Cross-module поиск | 0.011 сек | 0.363 сек | **33x** |

---

## Часть 1: Установка CLI

### Системные требования

- **OS**: macOS, Linux, Windows (WSL2)
- **Rust**: 1.70+ (для сборки из исходников)
- **RAM**: 512+ MB

### Способ 1: Из исходников (рекомендуется)

```bash
# Клонирование репозитория
git clone https://github.com/USER/code-indexer
cd code-indexer

# Сборка release версии
cargo build --release

# Установка в PATH
sudo cp target/release/code-indexer /usr/local/bin/

# Или через symlink
ln -s $(pwd)/target/release/code-indexer /usr/local/bin/code-indexer
```

### Способ 2: Cargo install

```bash
cargo install --git https://github.com/USER/code-indexer
```

### Проверка установки

```bash
code-indexer --version
code-indexer --help
```

### Быстрый старт CLI

```bash
# Индексация текущего проекта
code-indexer index

# Проверка состояния индекса
code-indexer stats

# Поиск символов
code-indexer symbols "MyClass"

# Найти определение
code-indexer definition "UserService"

# Граф вызовов
code-indexer call-graph "main" --depth 3
```

---

## Часть 2: MCP настройка

Добавьте в `~/.config/claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "code-indexer": {
      "command": "/usr/local/bin/code-indexer",
      "args": ["serve"],
      "cwd": "/path/to/your/project"
    }
  }
}
```

---

## Часть 3: Установка скилла

### Способ 1: Локальная установка (рекомендуется)

```bash
# Клонировать репозиторий скилла
git clone https://github.com/USER/code-indexer-skill.git

# Глобально (для всех проектов)
cp -r code-indexer-skill ~/.claude/skills/code-indexer

# Или для конкретного проекта
mkdir -p .claude/skills
cp -r code-indexer-skill .claude/skills/code-indexer
```

### Способ 2: Прямое копирование файлов

```bash
# Глобально
mkdir -p ~/.claude/skills/code-indexer
cp SKILL.md ~/.claude/skills/code-indexer/
cp -r references ~/.claude/skills/code-indexer/

# Для проекта
mkdir -p .claude/skills/code-indexer
cp SKILL.md .claude/skills/code-indexer/
cp -r references .claude/skills/code-indexer/
```

### Проверка установки скилла

После установки скилл активируется по триггерам:
- "найти определение", "поиск символа", "граф вызовов"
- "find symbol", "call graph", "imports", "outline"
- "code-indexer", "index", "references", "changed symbols"

### Структура скилла

```
code-indexer/
├── SKILL.md                 # Основной файл скилла
└── references/
    └── mcp-fallback.md      # MCP fallback (только если CLI недоступен)
```

---

## Troubleshooting

### CLI проблемы

| Проблема | Решение |
|----------|---------|
| `command not found` | Проверь PATH: `which code-indexer` |
| Ошибки сборки Rust | Обнови Rust: `rustup update` |
| Missing tree-sitter | `cargo clean && cargo build --release` |

### Индексация проблемы

| Проблема | Причина | Решение |
|----------|---------|---------|
| Пустые результаты | Индекс не создан | `code-indexer index` |
| Устаревшие данные | Файлы изменились | `code-indexer index` (reindex) |
| База corrupted | Concurrent writes | `code-indexer clear && code-indexer index` |
| Медленный index | Большой проект | Используй `--watch` |

### Важные замечания

- **Добавь `.code-index.db` в `.gitignore`** — база создаётся в корне проекта
- **Не используй `--deep-deps` для быстрых сессий** — это минуты вместо секунд
- **SQLite single-writer** — не запускай параллельную запись в индекс

---

## Поддерживаемые языки (17)

| Язык | Расширения |
|------|-----------|
| Rust | `.rs` |
| Java | `.java` |
| Kotlin | `.kt`, `.kts` |
| TypeScript | `.ts`, `.tsx`, `.js`, `.jsx` |
| Python | `.py`, `.pyi` |
| Go | `.go` |
| C# | `.cs` |
| C++ | `.cpp`, `.cc`, `.hpp`, `.h` |
| SQL | `.sql` |
| Bash | `.sh`, `.bash` |
| Lua | `.lua` |
| Swift | `.swift` |
| Haskell | `.hs`, `.lhs` |
| Elixir | `.ex`, `.exs` |
| YAML | `.yml`, `.yaml` |
| TOML | `.toml` |
| HCL | `.tf`, `.hcl`, `.tfvars` |

---

## Лицензия

MIT License
