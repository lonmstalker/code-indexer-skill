# Code-Indexer Skill

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai)

MCP-first semantic code indexing and navigation plugin for Claude Code and Codex.

**24 MCP tools** | **17 languages** | **Tree-sitter powered**

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
| **MCP-first Workflow** | Uses MCP tools as primary interface for agents |
| **AI-ready Context** | `prepare_context` / `get_context_bundle` for task context |
| **Semantic Navigation** | Definitions, references, call graph, outline, imports |
| **Project Compass** | Macro navigation via project-level MCP tools |
| **Tags / Intent Layer** | Manage file tag inference rules |
| **CLI Fallback** | Full CLI fallback when MCP is unavailable |

## Supported Languages

Rust, Java, Kotlin, TypeScript, JavaScript, Python, Go, C#, C++, SQL, Bash, Lua, Swift, Haskell, Elixir, YAML, TOML, HCL

## Documentation

- [Skill Definition](plugins/code-indexer/skills/code-indexer/SKILL.md) — MCP-first workflow and rules
- [MCP-first Guide](docs/mcp-fallback.md) — MCP-first, CLI fallback, and project MCP setup for Codex/Claude
- [CLI Usage Guide](docs/usage.md) — CLI command reference

## Requirements

- [code-indexer](https://github.com/lonmstalker/code-indexer) (MCP server + CLI)
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
