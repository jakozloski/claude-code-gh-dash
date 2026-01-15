# gh-dash - GitHub PR Dashboard for Claude Code

A Claude Code plugin that displays GitHub PR status, CI/CD checks, and merge capability directly in your terminal.

## Features

- **Auto-trigger** - Dashboard automatically appears after creating a PR
- **Live updates** - Refreshes every 10s while checks are running
- **CI/CD status** - Visual progress bar with pass/fail/running counts
- **Bot detection** - Shows CodeRabbit, Cursor Bugbot, and coverage comments
- **Merge actions** - Merge PRs directly from the terminal

## Installation

### Option 1: Plugin Directory (recommended)

```bash
git clone https://github.com/jakozloski/claude-code-gh-dash.git
claude --plugin-dir /path/to/claude-code-gh-dash
```

Add to your shell config for permanent use:
```bash
alias claude="claude --plugin-dir /path/to/claude-code-gh-dash"
```

### Option 2: Per-project

Add to your project's `.claude/plugins.json`:
```json
{
  "plugins": ["github:jakozloski/claude-code-gh-dash"]
}
```

## Prerequisites

**GitHub CLI** - The plugin uses `gh` CLI for all GitHub operations:

```bash
brew install gh
gh auth login
```

## Usage

### View PR Status

```
/gh-dash:pr
```

### Output Example

```
┌────────────────────────────────────────────────────────────┐
│ PR #98: test: add test comment for PR plugin testing v7    │
│ test/pr-plugin-test-7 → main                               │
├────────────────────────────────────────────────────────────┤
│ Status       OPEN · Mergeable ✅                           │
│ Changes      3 files · +45 −12                             │
├────────────────────────────────────────────────────────────┤
│ CI/CD        [████████░░░░░░░░░░░░] 40%  (8/20)            │
│              ✅ 6 passed  ⏳ 6 running  ⏭️ 8 skipped      │
├────────────────────────────────────────────────────────────┤
│ ⏳ Running   Lint, Type Check, Unit Tests, Vercel          │
├────────────────────────────────────────────────────────────┤
│ 💬 Comments                                                │
│   🐛 Bugbot: Removed test comment (diff now empty)         │
│   🐰 CodeRabbit: ✅ LGTM - Trivial                         │
│   📊 Coverage: 20.31% (1991/9802 lines)                    │
├────────────────────────────────────────────────────────────┤
│ 🔗 Links                                                   │
│   PR: https://github.com/owner/repo/pull/98                │
│   Preview: https://your-preview-url.vercel.app             │
├────────────────────────────────────────────────────────────┤
│ ⚡ Actions                                                 │
│   /gh-dash:pr --merge         (squash - default)           │
│   /gh-dash:pr --merge merge   (merge commit)               │
│   /gh-dash:pr --merge rebase  (rebase)                     │
└────────────────────────────────────────────────────────────┘
```

### Merge a PR

```bash
# Squash merge (default)
/gh-dash:pr --merge

# Merge commit
/gh-dash:pr --merge merge

# Rebase
/gh-dash:pr --merge rebase
```

### Status Icons

| Icon | Meaning |
|------|---------|
| ✅ | Success / Approved / LGTM |
| ❌ | Failed / Changes requested |
| ⏳ | In Progress / Pending |
| ⏭️ | Skipped / Neutral |
| ⚠️ | Merge conflicts |

### Bot Icons

| Icon | Bot |
|------|-----|
| 🐰 | CodeRabbit |
| 🐛 | Cursor Bugbot |
| 📊 | Coverage reports |
| ▲ | Vercel |

## Auto-trigger Hook

The plugin includes a PostToolUse hook that automatically suggests running the PR dashboard after creating a PR with `gh pr create`.

The hook is located at `hooks/hooks.json` and uses a shell script (`hooks/pr-trigger.sh`) to detect when a PR is created.

**Note:** If using the plugin via `--plugin-dir`, the hook is automatically loaded. If you want to add it manually to your project, add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/claude-code-gh-dash/hooks/pr-trigger.sh"
          }
        ]
      }
    ]
  }
}
```

**Requires:** `jq` for JSON parsing (`brew install jq`)

## License

MIT
