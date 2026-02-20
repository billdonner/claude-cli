# claude-cli

A Swift command-line tool that calls the [Claude API](https://docs.anthropic.com/en/docs) to generate text content. Zero dependencies — just Foundation.

## Installation

```bash
git clone https://github.com/billdonner/claude-cli.git
cd claude-cli
swift build -c release
cp .build/release/claude-cli ~/bin/
```

Requires `ANTHROPIC_API_KEY` environment variable:

```bash
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshrc
source ~/.zshrc
```

## Usage

```bash
# Direct prompt
claude-cli "Explain monads in one sentence"

# Choose a model
claude-cli -m claude-opus-4-6 "Solve this hard problem"

# System prompt
claude-cli -s "You are a poet" "Write a haiku about Swift"

# Pipe a file for review
cat main.swift | claude-cli "Review this code for bugs"

# Pipe + instruction
cat data.json | claude-cli -s "You are a data analyst" "Summarize the trends"

# Verbose mode (shows model, token counts on stderr)
claude-cli -v "What is 2+2?"
```

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `-m, --model` | Model ID | `claude-sonnet-4-6` |
| `-t, --max-tokens` | Max output tokens | `4096` |
| `-s, --system` | System prompt | none |
| `-v, --verbose` | Show model/token info on stderr | off |
| `-h, --help` | Show help | — |

Output goes to **stdout**, errors and verbose info go to **stderr** — safe for piping into other tools (`| pbcopy`, `> output.md`, etc.).

## Workflow Examples

```bash
# Generate a commit message from staged changes
git diff --staged | claude-cli "Write a concise commit message"

# Explain unfamiliar code
cat weird_legacy.py | claude-cli "Explain what this does"

# Quick Q&A without leaving the terminal
claude-cli "Difference between actor and class in Swift?"

# Cheap/fast for simple tasks
claude-cli -m claude-haiku-4-5 "Classify this as bug or feature: user can't log in"
```

## Related Projects

This tool is part of a suite of projects monitored by [server-monitor](https://github.com/billdonner/server-monitor):

| Project | Repo | Description | Port |
|---------|------|-------------|------|
| **server-monitor** | [billdonner/server-monitor](https://github.com/billdonner/server-monitor) | Terminal + web dashboard for monitoring servers | 9860 |
| **server-monitor-ios** | [billdonner/server-monitor-ios](https://github.com/billdonner/server-monitor-ios) | iOS/WidgetKit companion app for server-monitor | — |
| **nagzerver** | [billdonner/nagzerver](https://github.com/billdonner/nagzerver) | Python API server for the Nagz ecosystem | 9800 |
| **nagz-web** | [billdonner/nagz-web](https://github.com/billdonner/nagz-web) | TypeScript/React web app for Nagz | 5173 |
| **nagz-ios** | [billdonner/nagz-ios](https://github.com/billdonner/nagz-ios) | SwiftUI iOS app for Nagz | — |
| **alities-engine** | [billdonner/alities-engine](https://github.com/billdonner/alities-engine) | Swift daemon for the Alities game engine | 9847 |
| **alities-mobile** | [billdonner/alities-mobile](https://github.com/billdonner/alities-mobile) | SwiftUI iOS app for Alities | — |
| **obo-server** | [billdonner/obo-server](https://github.com/billdonner/obo-server) | Python/FastAPI server for OBO flashcard decks | 9810 |
| **obo-gen** | [billdonner/obo-gen](https://github.com/billdonner/obo-gen) | Swift CLI generator — writes decks to Postgres | — |
| **obo** | [billdonner/obo](https://github.com/billdonner/obo) | OBO ecosystem hub (docs/planning) | — |
| **obo-ios** | [billdonner/obo-ios](https://github.com/billdonner/obo-ios) | SwiftUI iOS flashcard app | — |
| **monitor** | [billdonner/monitor](https://github.com/billdonner/monitor) | Server Monitor ecosystem hub (docs/planning) | — |
| **alities-trivwalk** | [billdonner/alities-trivwalk](https://github.com/billdonner/alities-trivwalk) | Python TrivWalk trivia game | — |
| **claude-cli** | [billdonner/claude-cli](https://github.com/billdonner/claude-cli) | This tool — Swift CLI for the Claude API | — |

## License

MIT
