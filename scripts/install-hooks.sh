#!/bin/bash
# Install Git hooks for Matt workflow enforcement

set -e

HOOKS_DIR=".git/hooks"

echo "📦 Installing Git hooks..."

# Create pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook: Enforce Matt workflow and writing-for-agents principles

set -e

echo "🔍 Checking Matt workflow compliance..."

# Check if SKILL.md is being modified
if git diff --cached --name-only | grep -q "SKILL.md"; then
  echo "📝 SKILL.md modified, running checks..."

  # Check writing-for-agents principles
  SKILL_CONTENT=$(git diff --cached SKILL.md)

  # Check for no-ops (weak words that don't change behavior)
  echo "  • Checking for no-ops..."
  if echo "$SKILL_CONTENT" | grep -qi "be thorough\|be careful\|make sure"; then
    echo "❌ Potential no-op detected: Use stronger leading words"
    echo "   Replace 'be thorough' → 'relentless', 'be careful' → specific criterion"
    exit 1
  fi

  # Check for negation without positive alternative
  echo "  • Checking for bare negation..."
  NEGATION_COUNT=$(echo "$SKILL_CONTENT" | grep -c "不要\|❌\|禁止" || true)
  POSITIVE_COUNT=$(echo "$SKILL_CONTENT" | grep -c "✓\|应该\|正确" || true)
  if [ "$NEGATION_COUNT" -gt "$POSITIVE_COUNT" ]; then
    echo "⚠️  Warning: More negation than positive guidance"
    echo "   Consider pairing prohibitions with target behavior"
  fi

  # Check for context pointer quality (frontmatter description)
  echo "  • Checking context pointer..."
  if ! head -10 SKILL.md | grep -q "^description:"; then
    echo "❌ Missing or weak context pointer in frontmatter"
    exit 1
  fi

  DESC=$(head -10 SKILL.md | grep "^description:" | cut -d: -f2-)
  DESC_LEN=$(echo "$DESC" | wc -c)
  if [ "$DESC_LEN" -gt 200 ]; then
    echo "⚠️  Warning: Context pointer too long (${DESC_LEN} chars > 200)"
    echo "   Consider progressive disclosure"
  fi
fi

# Check for spec ticket reference
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" =~ ^ticket-[0-9]+ ]]; then
  TICKET_NUM=$(echo "$BRANCH" | grep -o '[0-9]\+')
  echo "✅ Branch references ticket #$TICKET_NUM"
else
  echo "⚠️  Warning: Branch name doesn't reference a ticket (ticket-N)"
  echo "   Matt workflow: /to-spec → /to-tickets → implement"
fi

echo "✅ Pre-commit checks passed"
EOF

chmod +x "$HOOKS_DIR/pre-commit"
echo "✅ pre-commit hook installed"

# Create commit-msg hook
cat > "$HOOKS_DIR/commit-msg" << 'EOF'
#!/bin/bash
# Commit-msg hook: Enforce ticket reference in commit message

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Check if this is a merge commit
if grep -q "^Merge " "$COMMIT_MSG_FILE"; then
  exit 0
fi

# Check for ticket reference (#N or Closes #N)
if ! echo "$COMMIT_MSG" | grep -qE "(#[0-9]+|Closes #[0-9]+)"; then
  echo "❌ Commit message must reference a ticket"
  echo ""
  echo "Matt workflow requires:"
  echo "  1. /to-spec → Create spec"
  echo "  2. /to-tickets → Create GitHub issues"
  echo "  3. Reference ticket in commit: 'Closes #N'"
  echo ""
  echo "Your commit message:"
  echo "---"
  cat "$COMMIT_MSG_FILE"
  echo "---"
  echo ""
  echo "Add 'Closes #N' to your commit message"
  exit 1
fi

# Check if referenced ticket exists (requires gh CLI)
if command -v gh &> /dev/null; then
  TICKET=$(echo "$COMMIT_MSG" | grep -oE "#[0-9]+" | head -1 | tr -d '#')
  if ! gh issue view "$TICKET" &> /dev/null; then
    echo "⚠️  Warning: Ticket #$TICKET not found on GitHub"
    echo "   Did you run /to-tickets?"
  fi
fi

exit 0
EOF

chmod +x "$HOOKS_DIR/commit-msg"
echo "✅ commit-msg hook installed"

echo ""
echo "🎉 Git hooks installed successfully!"
echo "See docs/GIT-HOOKS.md for details"
