# Code-Indexer CLI Usage Guide

Complete reference for the current `code-indexer` CLI API.

## MCP-first Note

If MCP tools are available, use MCP as the primary interface and treat this document as CLI fallback reference. See `docs/mcp-fallback.md` for MCP-first workflow.

## Installation

### From Source

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

### 1. Index Project

```bash
# Basic indexing
code-indexer index

# Index specific path
code-indexer index /path/to/project

# Continuous indexing
code-indexer index --watch

# Include dependencies
code-indexer index --deep-deps

# Performance/resource tuning
code-indexer index --profile eco
code-indexer index --profile balanced
code-indexer index --profile max
code-indexer index --durability safe
code-indexer index --threads 2 --throttle-ms 8
```

### 2. Verify Index Status

```bash
code-indexer stats
```

### 3. Query and Analyze

Choose commands by task (see Decision Tree below).

### 4. Optional: Daemon + Remote Queries

```bash
# Start daemon over unix socket
code-indexer serve --transport unix --socket /tmp/code-indexer.sock

# Send commands through daemon
code-indexer symbols "UserService" --remote /tmp/code-indexer.sock
code-indexer definition "UserRepository" --remote /tmp/code-indexer.sock
code-indexer stats --remote /tmp/code-indexer.sock
```

## Command Reference

### Index and Service

| Command | Description |
|---------|-------------|
| `code-indexer index [PATH]` | Index project at `PATH` (default: current dir) |
| `code-indexer index --watch` | Continuous indexing on file changes |
| `code-indexer index --deep-deps` | Also index dependencies |
| `code-indexer index --profile eco|balanced|max` | Resource profile for indexing |
| `code-indexer index --durability safe|fast` | Bulk write durability mode |
| `code-indexer index --threads N --throttle-ms N` | Manual CPU/thermal tuning |
| `code-indexer serve` | Start MCP server over stdio |
| `code-indexer serve --transport unix --socket <PATH>` | Start daemon over unix socket |
| `code-indexer stats [--remote <SOCK>]` | Show index statistics |
| `code-indexer clear` | Clear index database |

### Agent Context

| Command | Description |
|---------|-------------|
| `code-indexer prepare-context "<QUERY>"` | Build AI-ready context bundle from natural language query |
| `... --file <FILE> --task-hint <HINT>` | Improve locality and task intent |
| `... --agent-timeout-sec N --agent-max-steps N` | Tune orchestration limits |
| `... --agent-include-trace` | Include debug trace |
| `... --remote <SOCK>` | Execute through running daemon |

### Symbols and Navigation

| Command | Description |
|---------|-------------|
| `code-indexer symbols [QUERY]` | Search symbols, or list symbols when query omitted |
| `code-indexer symbols <QUERY> --fuzzy` | Fuzzy symbol search |
| `code-indexer symbols --kind function|type|all` | Filter by symbol kind |
| `code-indexer symbols ... --language <LANG> --file <FILE> --pattern <GLOB>` | Additional filters |
| `code-indexer definition <NAME>` | Find symbol definition |
| `code-indexer definition <NAME> --include-deps [--dep <NAME>]` | Include dependency definitions |
| `code-indexer references <NAME>` | Find references |
| `code-indexer references <NAME> --callers --depth N` | Include callers to specified depth |
| `code-indexer call-graph <FUNC> --direction in|out|both --depth N` | Analyze call graph |
| `code-indexer call-graph <FUNC> --include-possible` | Include uncertain call edges |
| `code-indexer outline <FILE> [--start-line N --end-line M --scopes]` | File structure and optional scopes |
| `code-indexer imports <FILE> [--resolve]` | File imports and optional definition resolution |

### Git Changes

| Command | Description |
|---------|-------------|
| `code-indexer changed` | Show all uncommitted symbol changes |
| `code-indexer changed --base <REF>` | Compare against git ref (default: `HEAD`) |
| `code-indexer changed --staged` | Show only staged changes |
| `code-indexer changed --unstaged` | Show only unstaged changes |
| `code-indexer changed --format full|compact|minimal` | Output mode |

### Dependencies

| Command | Description |
|---------|-------------|
| `code-indexer deps list [PATH] [--dev] [--format text|json]` | List project dependencies |
| `code-indexer deps index [PATH] [--name <NAME>] [--dev]` | Index dependency symbols |
| `code-indexer deps find <SYMBOL> [--dep <NAME>] [--limit N]` | Find symbol in indexed dependencies |
| `code-indexer deps source <SYMBOL> [--dep <NAME>] [--context N]` | Show source snippet for dependency symbol |
| `code-indexer deps info <NAME> [PATH]` | Show dependency metadata |

### Tags / Intent Layer

| Command | Description |
|---------|-------------|
| `code-indexer tags add-rule <TAG> --pattern "<GLOB>" [PATH]` | Add tag inference rule |
| `code-indexer tags remove-rule --pattern "<GLOB>" [PATH]` | Remove tag inference rule |
| `code-indexer tags list-rules [--format text|json] [PATH]` | List inference rules |
| `code-indexer tags preview <FILE> [PATH]` | Preview inferred tags for file |
| `code-indexer tags apply [PATH] [--db <DB>]` | Apply rules to index |
| `code-indexer tags stats [--db <DB>]` | Show tag statistics |

## Decision Tree

```
Need to solve something in code?
├── Text/string/comment → use rg (NOT code-indexer)
├── Need AI-ready context from NL query → code-indexer prepare-context "<QUERY>"
├── Symbol (function/type/class)?
│   ├── Exact name → code-indexer definition <NAME>
│   ├── Partial/list → code-indexer symbols <QUERY>
│   └── Typo tolerance → code-indexer symbols <QUERY> --fuzzy
├── References/usages → code-indexer references <NAME>
│   └── Callers chain → code-indexer references <NAME> --callers --depth N
├── Call graph → code-indexer call-graph <FUNC> --direction in|out|both --depth N
├── File structure → code-indexer outline <FILE>
├── Imports → code-indexer imports <FILE> [--resolve]
├── Git changes → code-indexer changed [--base REF] [--staged|--unstaged]
├── Dependency symbol/source → code-indexer deps find|source ...
└── Tag inference workflow → code-indexer tags <subcommand>
```

## Performance and Accuracy Tips

1. Run `code-indexer stats` before deep analysis.
2. Prefer `--profile eco` + `--throttle-ms` on thermally constrained laptops.
3. Avoid `--deep-deps` for short sessions.
4. Add `.code-index.db` to `.gitignore`.
5. Treat `--include-possible` call edges as hints, not facts.
6. Prefer modern commands over legacy `code-indexer query ...` (deprecated).

## Common Patterns

### Quick Project Overview

```bash
code-indexer index
code-indexer stats
code-indexer symbols "main" --kind function
code-indexer outline src/main.rs
```

### Prepare Context for External Agent

```bash
code-indexer prepare-context "where is auth token validated?" \
  --file src/auth/middleware.rs \
  --task-hint debugging \
  --agent-timeout-sec 60 \
  --agent-max-steps 6
```

### Refactoring Impact

```bash
code-indexer call-graph "TargetFn" --direction in --depth 3
code-indexer references "TargetType" --callers --depth 2
```

### Review Current Changes

```bash
code-indexer changed --base HEAD
code-indexer changed --staged
code-indexer changed --unstaged
```

### Dependency Investigation

```bash
code-indexer deps find "Serialize" --dep "serde"
code-indexer deps source "Serialize" --dep "serde" --context 15
```

### Tag Rules Setup

```bash
code-indexer tags add-rule "domain:auth" --pattern "**/auth/**" --confidence 0.8
code-indexer tags list-rules --format json
code-indexer tags apply
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Empty results | Index not created | `code-indexer index` |
| Stale data | Files changed | `code-indexer index` then `code-indexer stats` |
| Corrupted DB | Concurrent writes | `code-indexer clear && code-indexer index` |
| Slow indexing / hot CPU | High parallel load | Use `--profile eco` and `--throttle-ms` |
| `prepare-context` fails | Missing/invalid `agent.*` config | Fix root `.code-indexer.yml` agent config |
| `--remote` fails | Daemon/socket mismatch | Restart `serve` and verify socket path |
| `possible` call edges | Dynamic dispatch uncertainty | Verify manually |

## Supported Languages

Rust, Java, Kotlin, TypeScript, JavaScript, Python, Go, C#, C++, SQL, Bash, Lua, Swift, Haskell, Elixir, YAML, TOML, HCL
