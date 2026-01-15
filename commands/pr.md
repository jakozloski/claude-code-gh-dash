---
description: Display GitHub PR status dashboard with CI/CD checks and merge capability
argument-hint: "[pr-number] [--merge [squash|merge|rebase]]"
allowed-tools: Bash(gh:*), Bash(git:*), Bash(sleep:*)
---

# GitHub PR Dashboard

Display a clean, structured dashboard for the current branch's pull request.

## Step 1: Fetch PR Data

```bash
gh pr view --json number,title,state,baseRefName,headRefName,mergeable,reviewDecision,url,statusCheckRollup,reviews,comments,additions,deletions,changedFiles
```

## Step 2: Display Dashboard

**Output as plain text directly - NO bash commands like cat/echo/printf.**

Use this simple, clean format with consistent spacing:

```
┌─────────────────────────────────────────────────────────────────────┐
│ PR #98: test: add test comment for PR plugin testing v7             │
│ test/pr-plugin-test-7 → main                                        │
├─────────────────────────────────────────────────────────────────────┤
│ Status       OPEN · Mergeable ✅                                     │
│ Changes      3 files · +45 −12                                      │
├─────────────────────────────────────────────────────────────────────┤
│ CI/CD        [████████░░░░░░░░░░░░] 40%  (8/20)                     │
│              ✅ 6 passed   ⏳ 6 running   ⏭️ 8 skipped               │
├─────────────────────────────────────────────────────────────────────┤
│ ⏳ Running   Lint, Type Check, Unit Tests, Vercel                   │
├─────────────────────────────────────────────────────────────────────┤
│ 💬 Comments                                                         │
│   🐛 Bugbot: Removed test comment (diff now empty)                  │
│   🐰 CodeRabbit: ✅ LGTM - Trivial                                   │
│   📊 Coverage: 20.31% (1991/9802 lines)                             │
├─────────────────────────────────────────────────────────────────────┤
│ 🔗 Links                                                            │
│   PR:                                                               │
│   https://github.com/TypoSentry/typosentry/pull/98                  │
│                                                                     │
│   Preview:                                                          │
│   https://typosentry-git-test-pr-plugin-test-7-jakozloskis.vercel.app │
├─────────────────────────────────────────────────────────────────────┤
│ ⚡ Actions                                                          │
│   /gh-dash:pr --merge         (squash - default)                    │
│   /gh-dash:pr --merge merge   (merge commit)                        │
│   /gh-dash:pr --merge rebase  (rebase)                              │
└─────────────────────────────────────────────────────────────────────┘
```

## Step 3: CRITICAL Layout Rules

1. **NEVER truncate URLs** - Put long URLs on their own line, let them extend beyond the box if needed
2. **Simple borders** - Use single-line box characters: ┌ ┐ └ ┘ │ ─ ├ ┤
3. **No fixed width** - Don't try to align the right border perfectly, content is more important
4. **Section headers on own line** - Put "🔗 Links" on its own line, then content below
5. **Omit empty sections** - Don't show Reviews/Comments if there are none

## Step 4: Status Line Rules

Show status as: `OPEN · Mergeable ✅` or `OPEN · Mergeable ❌`

Only add review status if reviews exist:
- `OPEN · APPROVED ✅ · Mergeable ✅`
- `OPEN · Changes requested ❌ · Mergeable ✅`

Do NOT show "No reviews" - it's obvious and useless.

**Merge conflicts**: If mergeable is "CONFLICTING", show:
- `OPEN · ⚠️ CONFLICTS · Mergeable ❌`

## Step 4b: Changes Line

Always show the changes line with file count and lines:
- `Changes      3 files · +45 −12`
- Use green + for additions, red − for deletions (or just +/− symbols)
- Format: `{changedFiles} files · +{additions} −{deletions}`

## Step 5: Status Emojis

- ✅ = success, passed, completed, approved, LGTM
- ❌ = failure, error, failed, changes requested
- ⏳ = in_progress, pending, queued, running
- ⏭️ = skipped, neutral, cancelled

## Step 6: Bot Detection

- **CodeRabbit**: 🐰 icon
- **Cursor Bugbot / Bugbot Auto-Fix**: 🐛 icon
- **Coverage reports**: 📊 icon
- **Vercel**: ▲ icon
- **Human reviewers**: 👤 icon with @username

## Step 7: Handle --merge

If $ARGUMENTS contains `--merge`:
- `gh pr merge --squash` (default)
- `gh pr merge --merge` (if "merge" specified)
- `gh pr merge --rebase` (if "rebase" specified)

## Step 8: Live Updates - MANDATORY POLLING LOOP

⚠️ **THIS STEP IS NOT OPTIONAL - YOU MUST IMPLEMENT THE POLLING LOOP**

After displaying the dashboard, you MUST check if ANY status check in `statusCheckRollup` has a state of: `PENDING`, `QUEUED`, `IN_PROGRESS`, or `RUNNING` (case-insensitive).

**DO NOT STOP YOUR RESPONSE** if checks are still running. You must continue polling.

### Polling Algorithm (MANDATORY when checks are running):

```
iteration = 0
max_iterations = 60

WHILE iteration < max_iterations:
  1. Display the dashboard (Step 2 format)

  2. Check statusCheckRollup states:
     - Count checks with states: PENDING, QUEUED, IN_PROGRESS, RUNNING
     - If count == 0 → BREAK (all checks complete)

  3. Output: "⏳ Refreshing in 10s... (Ctrl+C to stop)"

  4. Execute: sleep 10

  5. Re-fetch PR data:
     gh pr view --json number,title,state,baseRefName,headRefName,mergeable,reviewDecision,url,statusCheckRollup,reviews,comments,additions,deletions,changedFiles

  6. iteration = iteration + 1

  7. CONTINUE to step 1

END WHILE
```

### Exit Conditions:
- **Success**: All checks have terminal states → Output: "✅ All checks complete!"
- **Timeout**: 60 iterations reached → Output: "⏱️ Timeout - checks still running after 10 minutes"

### CRITICAL REQUIREMENTS:

1. **DO NOT END YOUR RESPONSE** after showing the dashboard once if checks are pending
2. **DO NOT ASK THE USER** if they want to continue polling - just do it
3. **EXECUTE `sleep 10`** between each refresh - this is a real bash command
4. **KEEP LOOPING** until ALL checks reach terminal states (SUCCESS/FAILURE/ERROR/SKIPPED/CANCELLED/NEUTRAL)
5. **RE-FETCH DATA** on every iteration - do not reuse stale data

The polling loop is the core feature of this dashboard. Stopping early defeats the purpose.

## Edge Cases

- **No PR**: "No PR for current branch. Create one with: gh pr create"
- **Merged**: Show status as "✅ MERGED" - hide Actions section
- **Closed**: Show status as "❌ CLOSED" - hide Actions section
