# claude-cli

Swift CLI tool that calls the Claude API to generate text content.

## Installation

```bash
swift build -c release
cp .build/release/claude-cli ~/bin/
```

Requires `ANTHROPIC_API_KEY` environment variable set in `~/.zshrc`.

## Usage

```bash
# Direct prompt
claude-cli "Explain monads in one sentence"

# With options
claude-cli -m claude-opus-4-6 --system "You are a poet" "Write a haiku about Swift"

# Pipe stdin
echo "Summarize this text" | claude-cli -t 200

# Pipe file + instruction
cat main.swift | claude-cli -s "You are a code reviewer" "Review this code"
```

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `-m, --model` | Model ID | `claude-sonnet-4-6` |
| `-t, --max-tokens` | Max output tokens | `4096` |
| `-s, --system` | System prompt | none |
| `-v, --verbose` | Show model/token info on stderr | off |
| `-h, --help` | Show help | — |

## Architecture

Single-file tool (~170 lines). No external dependencies — uses Foundation URLSession.

- `main.swift` — argument parsing, API call, response printing
- Output goes to stdout, errors/verbose info to stderr (safe for piping)
