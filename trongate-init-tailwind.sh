#!/bin/bash
# Usage: bash trongate-init-tailwind.sh
# Run from the root of a Trongate project AFTER trongate-init.sh
# Installs Tailwind CSS v4 with a single global stylesheet

TARGET_DIR="$(pwd)"

# Check Node is installed
if ! command -v node &> /dev/null; then
  echo "Node.js is not installed. Please install it from https://nodejs.org and re-run this script."
  exit 1
fi

# Check npm is installed
if ! command -v npm &> /dev/null; then
  echo "npm is not installed. Please install Node.js from https://nodejs.org and re-run this script."
  exit 1
fi

echo "Installing Tailwind CSS v4..."

# Init package.json if it doesn't exist
if [ ! -f "$TARGET_DIR/package.json" ]; then
  npm init -y
  echo "Created package.json"
fi

# Install Tailwind v4 CLI
npm install tailwindcss @tailwindcss/cli

# Create input CSS file
mkdir -p "$TARGET_DIR/public/css"
cat > "$TARGET_DIR/public/css/app.css" << 'CSS'
@import "tailwindcss";
CSS
echo "Created public/css/app.css"

# Add watch script to package.json
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.scripts = pkg.scripts || {};
pkg.scripts['watch:css'] = 'npx @tailwindcss/cli -i ./public/css/app.css -o ./public/css/output.css --watch';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
"
echo "Added watch:css script to package.json"

# Append node_modules to .gitignore without overwriting
GITIGNORE="$TARGET_DIR/.gitignore"
touch "$GITIGNORE"

if ! grep -qF "node_modules/" "$GITIGNORE"; then
  echo "" >> "$GITIGNORE"
  echo "# Tailwind" >> "$GITIGNORE"
  echo "node_modules/" >> "$GITIGNORE"
  echo "Updated .gitignore"
fi

# Run initial build to generate output.css
echo "Running initial CSS build..."
npx @tailwindcss/cli -i ./public/css/app.css -o ./public/css/output.css

echo ""
echo "Done. Tailwind CSS v4 is ready."
echo ""
echo "Next steps:"
echo "  1. Add this to your template <head>:"
echo '     <link rel="stylesheet" href="<?= BASE_URL ?>public/css/output.css">'
echo "  2. Run 'npm run watch:css' while developing"
echo "  3. Commit output.css along with your other changes"
