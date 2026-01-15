#!/bin/bash
# Hook script for PostToolUse - triggers PR dashboard after gh pr create

# Read JSON input from stdin
INPUT=$(cat)

# Extract the Bash command from tool_input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Check if this was a gh pr create command
if [[ "$COMMAND" == *"gh pr create"* ]]; then
  echo "A PR was just created. Run /gh-dash:pr to display the PR dashboard with status, CI/CD checks, and live updates."
fi
