#!/bin/bash
# Usage: bash trongate-init.sh
# Run from the root of a new Trongate project

SCAFFOLD_DIR="$(dirname "$0")"
TARGET_DIR="$(pwd)"

if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  echo "CLAUDE.md already exists. Skipping to avoid overwrite."
else
  cp "$SCAFFOLD_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  echo "Created CLAUDE.md"
fi

mkdir -p "$TARGET_DIR/_reference/specs"
mkdir -p "$TARGET_DIR/_reference/plans"
mkdir -p "$TARGET_DIR/.claude/commands"

cp "$SCAFFOLD_DIR/_reference/trongate-memory.md" "$TARGET_DIR/_reference/trongate-memory.md"
cp "$SCAFFOLD_DIR/_reference/specs/SPEC_TEMPLATE.md" "$TARGET_DIR/_reference/specs/SPEC_TEMPLATE.md"
cp "$SCAFFOLD_DIR/_reference/plans/PLAN_TEMPLATE.md" "$TARGET_DIR/_reference/plans/PLAN_TEMPLATE.md"
cp "$SCAFFOLD_DIR/.claude/commands/new-spec.md" "$TARGET_DIR/.claude/commands/new-spec.md"
cp "$SCAFFOLD_DIR/.claude/commands/new-plan.md" "$TARGET_DIR/.claude/commands/new-plan.md"
cp "$SCAFFOLD_DIR/.claude/commands/commit.md" "$TARGET_DIR/.claude/commands/commit.md"
cp "$SCAFFOLD_DIR/.claude/commands/security-audit.md" "$TARGET_DIR/.claude/commands/security-audit.md"
cp "$SCAFFOLD_DIR/.claude/commands/update-docs.md" "$TARGET_DIR/.claude/commands/update-docs.md"

# Fetch latest Trongate docs
echo "Fetching latest Trongate docs..."
if [ -d "$TARGET_DIR/_reference/trongate-docs-repo" ]; then
  cd "$TARGET_DIR/_reference/trongate-docs-repo" && git pull && cd "$TARGET_DIR"
  echo "Trongate docs updated."
else
  git clone --depth=1 https://github.com/trongate/trongate-docs.git "$TARGET_DIR/_reference/trongate-docs-repo"
  echo "Trongate docs cloned."
fi

echo "Done. Trongate Claude scaffold initialized in: $TARGET_DIR"
