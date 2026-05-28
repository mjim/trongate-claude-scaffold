#!/bin/bash
# Usage: bash trongate-init.sh
# Run from the root of a new Trongate project
# Sets up Claude scaffold AND Tailwind CSS v4 in one go

SCAFFOLD_DIR="$(dirname "$0")"
TARGET_DIR="$(pwd)"

echo "========================================"
echo "Trongate Claude Scaffold with Tailwind"
echo "========================================"
echo ""

# ============================================
# PART 1: Claude scaffold files
# ============================================

echo "Installing Claude scaffold files..."

if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
  echo "  CLAUDE.md already exists. Skipping to avoid overwrite."
else
  cp "$SCAFFOLD_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  echo "  Created CLAUDE.md"
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

echo "  Created _reference/ and .claude/ directories"

# Write .gitignore with preferred defaults (overwrites existing)
cat > "$TARGET_DIR/.gitignore" << 'GITIGNORE'
# Trongate config (environment-specific, never commit)
config/
config_*/

# Trongate docs repo (cloned at runtime)
_reference/trongate-docs-repo/

# Tailwind
node_modules/
GITIGNORE
echo "  Created .gitignore"

# Fetch latest Trongate docs
echo ""
echo "Fetching latest Trongate docs..."
if [ -d "$TARGET_DIR/_reference/trongate-docs-repo" ]; then
  cd "$TARGET_DIR/_reference/trongate-docs-repo" && git pull && cd "$TARGET_DIR"
  echo "  Trongate docs updated."
else
  git clone --depth=1 https://github.com/trongate/trongate-docs.git "$TARGET_DIR/_reference/trongate-docs-repo"
  echo "  Trongate docs cloned."
fi

# ============================================
# PART 2: Tailwind CSS v4 setup
# ============================================

echo ""
echo "Installing Tailwind CSS v4..."

# Check Node is installed
if ! command -v node &> /dev/null; then
  echo "  ERROR: Node.js is not installed."
  echo "  Install it from https://nodejs.org and re-run this script."
  exit 1
fi

# Check npm is installed
if ! command -v npm &> /dev/null; then
  echo "  ERROR: npm is not installed."
  echo "  Install Node.js from https://nodejs.org and re-run this script."
  exit 1
fi

# Init package.json if it doesn't exist
if [ ! -f "$TARGET_DIR/package.json" ]; then
  cd "$TARGET_DIR" && npm init -y > /dev/null
  echo "  Created package.json"
fi

# Install Tailwind v4 CLI
echo "  Installing tailwindcss and @tailwindcss/cli via npm..."
cd "$TARGET_DIR" && npm install tailwindcss @tailwindcss/cli --silent
echo "  Tailwind packages installed"

# ============================================
# Copy project files
# The project-files/ folder in this scaffold mirrors the destination
# structure exactly. We just copy it on top of the project root.
# ============================================

# Public folder assets (CSS and JS go here so they're web-accessible)
mkdir -p "$TARGET_DIR/public/css"
mkdir -p "$TARGET_DIR/public/js"

cp "$SCAFFOLD_DIR/project-files/public/css/app.css" "$TARGET_DIR/public/css/app.css"
cp "$SCAFFOLD_DIR/project-files/public/css/trongate-tailwind.css" "$TARGET_DIR/public/css/trongate-tailwind.css"
cp "$SCAFFOLD_DIR/project-files/public/js/theme-toggle.js" "$TARGET_DIR/public/js/theme-toggle.js"

echo "  Created public/css/app.css (Tailwind entry point)"
echo "  Created public/css/trongate-tailwind.css (component styles)"
echo "  Created public/js/theme-toggle.js (dark mode toggle)"

# Replace the public.php template with our Tailwind-aware version
if [ -d "$TARGET_DIR/modules/templates/views" ]; then
  cp "$SCAFFOLD_DIR/project-files/modules/templates/views/public.php" "$TARGET_DIR/modules/templates/views/public.php"
  echo "  Updated modules/templates/views/public.php"
else
  echo "  WARNING: modules/templates/views/ not found. Skipping public.php replacement."
  echo "           You may need to manually update your template to load output.css"
fi

# Replace the welcome module: controller + under-construction page + showcase view
if [ -d "$TARGET_DIR/modules/welcome/views" ]; then
  # Controller sits directly in the module folder (Trongate v2 - no controllers/ subfolder)
  cp "$SCAFFOLD_DIR/project-files/modules/welcome/Welcome.php" "$TARGET_DIR/modules/welcome/Welcome.php"
  echo "  Updated modules/welcome/Welcome.php (adds /welcome/components route)"

  # Under-construction homepage (shows by default in all environments)
  cp "$SCAFFOLD_DIR/project-files/modules/welcome/views/default_homepage.php" "$TARGET_DIR/modules/welcome/views/default_homepage.php"
  echo "  Updated modules/welcome/views/default_homepage.php (under-construction page)"

  # Component showcase (lives at /welcome/components)
  cp "$SCAFFOLD_DIR/project-files/modules/welcome/views/components_showcase.php" "$TARGET_DIR/modules/welcome/views/components_showcase.php"
  echo "  Created modules/welcome/views/components_showcase.php (showcase at /welcome/components)"
else
  echo "  WARNING: modules/welcome/views/ not found. Skipping welcome module replacement."
fi

# Add watch script to package.json
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts = pkg.scripts || {};
pkg.scripts['watch:css'] = 'npx @tailwindcss/cli -i ./public/css/app.css -o ./public/css/output.css --watch';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"
echo "  Added watch:css script to package.json"

# Run initial build to generate output.css
echo ""
echo "Running initial CSS build..."
cd "$TARGET_DIR" && npx @tailwindcss/cli -i ./public/css/app.css -o ./public/css/output.css 2>&1 | tail -3

# ============================================
# DONE
# ============================================

echo ""
echo "========================================"
echo "Setup complete."
echo "========================================"
echo ""
echo "Your Trongate project is ready with:"
echo "  - Claude scaffold (CLAUDE.md, slash commands, reference docs)"
echo "  - Tailwind CSS v4 with custom Trongate-compatible styles"
echo "  - Dark mode support with theme toggle"
echo "  - Under-construction homepage (shown by default)"
echo "  - Component showcase at /welcome/components"
echo ""
echo "Next steps:"
echo "  1. Run 'npm run watch:css' while developing"
echo "  2. Visit /welcome/components to see the component reference"
echo "  3. Edit the under-construction page: update the contact email"
echo "     and company name in modules/welcome/views/default_homepage.php"
echo "  4. Commit output.css along with your other changes"
echo ""
echo "To customize styles:"
echo "  - Edit CSS variables in public/css/trongate-tailwind.css"
echo "  - Component styles live in @layer components block"
echo "  - Dark mode overrides live in the .dark block"
echo ""