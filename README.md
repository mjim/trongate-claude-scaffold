# Trongate Claude Scaffold

A scaffold for working with [Trongate PHP v2](https://trongate.io) and Claude Code in VS Code. Run one command on any new Trongate project to get a fully configured Claude environment with reference docs, spec and plan templates, slash commands, and Tailwind CSS v4 with custom Trongate-compatible styles.

---

## What It Includes

```
trongate-claude-scaffold/
  CLAUDE.md                          # Claude's operating manual for Trongate projects
  trongate-init.sh                   # Setup script - run once per new project
  _reference/
    trongate-memory.md               # AI-optimized Trongate v2 reference (read first)
    specs/SPEC_TEMPLATE.md           # Template for scoping new features
    plans/PLAN_TEMPLATE.md           # Template for implementation plans
  .claude/
    commands/
      new-spec.md                    # /new-spec - create a feature spec
      new-plan.md                    # /new-plan - create a plan from a spec
      commit.md                      # /commit - stage, commit, and push
      security-audit.md              # /security-audit - full codebase security scan
      update-docs.md                 # /update-docs - pull latest Trongate docs
  project-files/                     # Mirrors the destination paths in your project
    public/
      css/
        app.css                      # Tailwind entry point with dark mode setup
        trongate-tailwind.css        # Component styles using @apply
      js/
        theme-toggle.js              # Dark mode toggle with localStorage
    modules/
      templates/views/public.php     # Template that loads output.css and theme script
      welcome/views/default_homepage.php  # Welcome page with component showcase
```

The `project-files/` folder mirrors the exact paths these files will land at in your Trongate project. The init script simply copies them across.

When you run `trongate-init`, it also clones the [official Trongate docs repo](https://github.com/trongate/trongate-docs) into `_reference/trongate-docs-repo/` for deep reference when needed.

---

## One-Time Mac Setup

### 1. Save the scaffold

Clone or download this repo to:

```
~/Documents/scripts/trongate-claude-scaffold/
```

### 2. Add the shell alias

```bash
echo 'alias trongate-init="bash ~/Documents/scripts/trongate-claude-scaffold/trongate-init.sh"' >> ~/.zshrc
source ~/.zshrc
```

---

## Per-Project Usage

Navigate to the root of any new Trongate project and run:

```bash
trongate-init
```

The script will:

**Claude scaffold:**
- Create `CLAUDE.md` at the project root
- Create `_reference/` with the memory file and templates
- Create `.claude/commands/` with all slash commands
- Overwrite `.gitignore` with preferred Trongate defaults
- Clone the latest Trongate docs into `_reference/trongate-docs-repo/`

**Tailwind CSS v4:**
- Install Tailwind CSS v4 via npm
- Copy `public/css/app.css` (Tailwind entry point)
- Copy `public/css/trongate-tailwind.css` (component styles)
- Copy `public/js/theme-toggle.js` (dark mode toggle)
- Replace `modules/templates/views/public.php` to load Tailwind output and theme script
- Replace `modules/welcome/views/default_homepage.php` with a component showcase
- Add `watch:css` and `build:css` scripts to `package.json`
- Run an initial build to generate `public/css/output.css`

Then start the watcher:

```bash
npm run watch:css
```

Visit your project in the browser and you will see the component showcase. Try the theme toggle in the top-right corner to switch between light and dark mode.

---

## Slash Commands

Open Claude Code in VS Code and use these from any project:

| Command | What it does |
| --- | --- |
| `/new-spec [feature name]` | Creates a spec file in `_reference/specs/` |
| `/new-plan [spec filename]` | Creates an implementation plan from a spec |
| `/commit` | Stages all changes, writes a commit message, and pushes |
| `/security-audit` | Scans the codebase for security issues |
| `/update-docs` | Pulls the latest Trongate docs from GitHub |

### Typical workflow

```
/new-spec team registration form
/new-plan team-registration-form
# implement the plan one task at a time
/security-audit
/commit
```

---

## Tailwind Workflow

The scaffold uses Tailwind CSS v4 with `@apply` to create Trongate-compatible component classes. This means existing Trongate class names (`.button`, `.card`, `.modal`, etc.) work without changing any view files.

### Development

```bash
npm run watch:css
```

The watcher regenerates `public/css/output.css` whenever you change a PHP file or any CSS source file.

### Production

```bash
npm run build:css
```

Generates a minified `output.css`. Commit it along with your other changes - no build step needed on the server.

### Customizing Styles

All styles live in `public/css/trongate-tailwind.css`. Key sections:

1. CSS variables at the top control colors for both light and dark mode
2. Component classes in `@layer components` use `@apply` to compose Tailwind utilities
3. Utility classes in `@layer utilities` provide Trongate-compatible spacing helpers

### Dark Mode

Dark mode is enabled by default. The theme toggle in the top-right corner switches between light and dark, and the choice persists across sessions via localStorage. On first visit, the site follows the user's system preference.

To remove dark mode entirely:
1. Remove the `@custom-variant dark` line from `app.css`
2. Remove the `.dark` block from `trongate-tailwind.css`
3. Remove the script tag from `modules/templates/views/public.php`
4. Delete `public/js/theme-toggle.js`

---

## How Claude Uses the Reference Files

Claude reads reference files in this order to keep token usage low:

1. `_reference/trongate-memory.md` - AI-optimized Trongate v2 reference, covers 95% of cases
2. `_reference/trongate-docs-repo/` - full official docs, only when the memory file doesn't cover something
3. `_reference/specs/` - feature requirements before planning
4. `_reference/plans/` - implementation plans before coding

---

## Requirements

- macOS with zsh (or any Unix with bash)
- Git
- Node.js and npm
- [Claude Code](https://claude.ai/code) installed in VS Code
- A Trongate v2 project

---

## Acknowledgements

Thanks to [Dave Connelly](https://trongate.io) for building an AI-optimized framework and providing both the memory reference file and the [official docs repo](https://github.com/trongate/trongate-docs) that make this scaffold possible.
