# Code-Indexer Skill

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai)

CLI-first semantic code indexing and navigation plugin for Claude Code.

**77x faster** than grep for symbol search | **17 languages** | **Tree-sitter powered**

## Quick Start

**Step 1:** Add the plugin marketplace

```bash
/plugin marketplace add lonmstalker/code-indexer-skill
```

**Step 2:** Install the plugin

```bash
/plugin install code-indexer
```

That's it! The skill activates automatically on triggers like "find definition", "call graph", "symbols", "code-indexer".

## Features

| Feature | Description |
|---------|-------------|
| **Symbol Search** | Find functions, types, classes by name |
| **Definition Lookup** | Jump to symbol definitions instantly |
| **Reference Finding** | Locate all usages across codebase |
| **Call Graph Analysis** | Visualize function call relationships |
| **Fuzzy Search** | Typo-tolerant symbol matching |
| **Git Integration** | Track changed symbols between commits |
| **Dependency Search** | Search symbols in external libraries |

## Performance

Benchmark on 2160-file project:

| Operation | code-indexer | grep | Speedup |
|-----------|--------------|------|---------|
| Find definition | 0.007s | 0.539s | **77x** |
| Call graph | 0.007s | 0.380s | **54x** |
| Cross-module search | 0.011s | 0.363s | **33x** |

## Supported Languages

Rust, Java, Kotlin, TypeScript, JavaScript, Python, Go, C#, C++, SQL, Bash, Lua, Swift, Haskell, Elixir, YAML, TOML, HCL

## Documentation

- [CLI Usage Guide](docs/usage.md) — Complete command reference
- [MCP Fallback](docs/mcp-fallback.md) — MCP integration (when CLI unavailable)

## Requirements

- [code-indexer CLI](https://github.com/lonmstalker/code-indexer) installed and in PATH
- Claude Code

## Plugin Structure

```
code-indexer-skill/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── code-indexer/
│       └── skills/
│           └── code-indexer/
│               └── SKILL.md
├── docs/
│   ├── usage.md
│   └── mcp-fallback.md
└── README.md
```

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE)
