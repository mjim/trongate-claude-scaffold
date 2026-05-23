# Trongate Claude Scaffold

A scaffold for working with [Trongate PHP v2](https://trongate.io) and Claude Code in VS Code. Run one command on any new Trongate project to get a fully configured Claude environment with reference docs, spec and plan templates, and slash commands.

---

## What It Includes

```
trongate-scaffold/
  CLAUDE.md                          # Claude's operating manual for Trongate projects
  trongate-init.sh                   # Setup script — run once per new project
  _reference/
    trongate-memory.md               # AI-optimized Trongate v2 reference (read first)
    specs/
      SPEC_TEMPLATE.md               # Template for scoping new features
    plans/
      PLAN_TEMPLATE.md               # Template for implementation plans
  .claude/
    commands/
      new-spec.md                    # /new-spec — create a feature spec
      new-plan.md                    # /new-plan — create a plan from a spec
      commit.md                      # /commit — stage, commit, and push
      security-audit.md              # /security-audit — full codebase security scan
      update-docs.md                 # /update-docs — pull latest Trongate docs
```

When you run `trongate-init`, it also clones the [official Trongate docs repo](https://github.com/trongate/trongate-docs) into `_reference/trongate-docs-repo/` for deep reference when needed.

---

## One-Time Mac Setup

### 1. Save the scaffold

Clone or download this repo to:

```
~/Documents/scripts/trongate-scaffold/
```

### 2. Add the shell aliases

```bash
echo 'alias trongate-init="bash ~/Documents/scripts/trongate-claude-scaffold/trongate-init.sh"' >> ~/.zshrc
echo 'alias trongate-init-tailwind="bash ~/Documents/scripts/trongate-claude-scaffold/trongate-init-tailwind.sh"' >> ~/.zshrc
source ~/.zshrc
```

---

## Per-Project Usage

Navigate to the root of any new Trongate project and run:

```bash
trongate-init
```

The `trongate-init` script will:
- Create `CLAUDE.md` at the project root
- Create `_reference/` with the memory file and templates
- Create `.claude/commands/` with all slash commands
- Overwrite `.gitignore` with preferred Trongate defaults (`config/`, `config_*/`, `_reference/trongate-docs-repo/`)
- Clone the latest Trongate docs into `_reference/trongate-docs-repo/`

If you want Tailwind CSS included, run this immediately after:

```bash
trongate-init-tailwind
```

The Tailwind script will:
- Install Tailwind CSS v4 via npm
- Create `public/css/app.css` as the global input file
- Add a `watch:css` script to `package.json`
- Run an initial build to generate `public/css/output.css`
- Append `node_modules/` to `.gitignore` without overwriting it

Then add this to your template `<head>`:

```php
<link rel="stylesheet" href="<?= BASE_URL ?>public/css/output.css">
```

Run `npm run watch:css` while developing. Commit `output.css` along with your other changes — no build step needed on the server.

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

## How Claude Uses the Reference Files

Claude reads reference files in this order to keep token usage low:

1. `_reference/trongate-memory.md` — AI-optimized Trongate v2 reference, covers 95% of cases
2. `_reference/trongate-docs-repo/` — full official docs, only when the memory file doesn't cover something
3. `_reference/specs/` — feature requirements before planning
4. `_reference/plans/` — implementation plans before coding

---

## Requirements

- macOS with zsh
- Git
- [Claude Code](https://claude.ai/code) installed in VS Code
- A Trongate v2 project

---

## Acknowledgements

Thanks to [Dave Connelly](https://trongate.io) for building an AI-optimized framework and providing both the memory reference file and the [official docs repo](https://github.com/trongate/trongate-docs) that make this scaffold possible.
