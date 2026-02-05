# Code-Indexer CLI Usage Guide

Complete reference for the code-indexer CLI tool.

## Installation

### From Source (Recommended)

```bash
git clone https://github.com/lonmstalker/code-indexer
cd code-indexer
cargo build --release
sudo cp target/release/code-indexer /usr/local/bin/
```

### Via Cargo

```bash
cargo install --git https://github.com/lonmstalker/code-indexer
```

### Verify Installation

```bash
code-indexer --version
code-indexer --help
```

## Core Workflow

### 1. Index Your Project

```bash
# Basic indexing
code-indexer index

# Index specific path
code-indexer index /path/to/project

# Watch mode for continuous updates
code-indexer index --watch

# Include dependencies (slower, more context)
code-indexer index --deep-deps
```

### 2. Verify Index Status

```bash
code-indexer stats
```

### 3. Query and Analyze

Use the appropriate command based on your needs.

## Command Reference

### Indexing Commands

| Command | Description |
|---------|-------------|
| `code-indexer index [PATH]` | Index project at PATH (default: current dir) |
| `code-indexer index --watch` | Continuous indexing on file changes |
| `code-indexer index --deep-deps` | Include dependency sources |
| `code-indexer clear` | Clear the index database |
| `code-indexer stats` | Show index statistics |

### Search Commands

| Command | Description |
|---------|-------------|
| `code-indexer symbols <QUERY>` | Search symbols by name |
| `code-indexer symbols <QUERY> --fuzzy` | Fuzzy search with typo tolerance |
| `code-indexer symbols <QUERY> --kind function` | Filter by symbol kind |
| `code-indexer definition <NAME>` | Find symbol definition |
| `code-indexer references <NAME>` | Find all references |
| `code-indexer references <NAME> --callers` | Find direct callers |

### Analysis Commands

| Command | Description |
|---------|-------------|
| `code-indexer call-graph <FUNC>` | Build call graph |
| `code-indexer call-graph <FUNC> --direction in` | Incoming calls only |
| `code-indexer call-graph <FUNC> --direction out` | Outgoing calls only |
| `code-indexer call-graph <FUNC> --depth N` | Limit graph depth |
| `code-indexer outline <FILE>` | Show file structure |
| `code-indexer imports <FILE>` | List file imports |
| `code-indexer imports <FILE> --resolve` | Resolve import paths |

### Git Integration

| Command | Description |
|---------|-------------|
| `code-indexer changed` | Symbols changed in working tree |
| `code-indexer changed --base main` | Changes since branch divergence |

### Dependency Commands

| Command | Description |
|---------|-------------|
| `code-indexer deps list` | List indexed dependencies |
| `code-indexer deps index` | Index all dependencies |
| `code-indexer deps index --name NAME` | Index specific dependency |
| `code-indexer deps find <SYMBOL>` | Search in dependencies |
| `code-indexer deps info <NAME>` | Dependency details |

## Decision Tree

```
Need to find something in code?
├── Text/string/comment → use rg (NOT code-indexer)
├── Symbol (function/type/class)?
│   ├── Exact name → code-indexer definition <NAME>
│   ├── Partial name → code-indexer symbols <QUERY>
│   └── Has typo → code-indexer symbols <QUERY> --fuzzy
├── References/usages → code-indexer references <NAME>
│   └── Who calls function → code-indexer references <NAME> --callers
├── Call graph → code-indexer call-graph <FUNC> --direction in|out|both
├── File structure → code-indexer outline <FILE>
├── Imports → code-indexer imports <FILE> [--resolve]
├── Git changes → code-indexer changed [--base BRANCH]
└── Symbol in deps → code-indexer deps find <SYMBOL>
```

## Performance Tips

1. **Always run `code-indexer stats` first** — verify index exists
2. **Avoid `--deep-deps` for quick sessions** — adds minutes to indexing
3. **Use `--watch` for large projects** — incremental updates
4. **Add `.code-index.db` to `.gitignore`** — database is local

## Common Patterns

### Quick Project Overview

```bash
code-indexer index
code-indexer stats
code-indexer symbols "main" --kind function
code-indexer outline src/main.rs
```

### Prepare for Refactoring

```bash
code-indexer call-graph "TargetFn" --direction in --depth 3
code-indexer references "TargetType" --callers
```

### Review Changes

```bash
code-indexer changed --base main
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Empty results | Index not created | `code-indexer index` |
| Stale data | Files changed | `code-indexer index` (reindex) |
| Corrupted DB | Concurrent writes | `code-indexer clear && code-indexer index` |
| Slow indexing | Large project | Use `--watch` mode |
| `possible` calls | Dynamic dispatch | Verify manually |

## Supported Languages

| Language | Extensions |
|----------|------------|
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
