# Code-Indexer Skill

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai)

CLI-first semantic code indexing and navigation plugin for Claude Code.

**77x faster** than grep for symbol search | **17 languages** | **Tree-sitter powered**

## Installation

### One-liner (Claude Code + Codex)

```bash
curl -sSL https://raw.githubusercontent.com/lonmstalker/code-indexer-skill/master/install.sh | bash
```

### Claude Code (Plugin Marketplace)

```bash
/plugin marketplace add lonmstalker/code-indexer-skill
/plugin install code-indexer
```

### Codex CLI

```bash
# Global install
curl -sSL https://raw.githubusercontent.com/lonmstalker/code-indexer-skill/master/install.sh | bash -s -- --codex

# Or manual
mkdir -p ~/.codex/skills/code-indexer
curl -sSL https://raw.githubusercontent.com/lonmstalker/code-indexer-skill/master/plugins/code-indexer/skills/code-indexer/SKILL.md \
  -o ~/.codex/skills/code-indexer/SKILL.md
```

### Install Options

```bash
./install.sh                    # Both Claude + Codex, global
./install.sh --claude           # Claude Code only
./install.sh --codex            # Codex CLI only
./install.sh --local            # Current project only
./install.sh --uninstall        # Remove skill
```

The skill activates automatically on triggers: "find definition", "call graph", "symbols", "code-indexer".

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
- Claude Code or Codex CLI

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
├── install.sh
└── README.md
```

## Contributing

See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE)
