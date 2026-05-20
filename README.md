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

### 2. Add the shell alias

```bash
echo 'alias trongate-init="bash ~/Documents/scripts/trongate-scaffold/trongate-init.sh"' >> ~/.zshrc
source ~/.zshrc
```

### 3. Set up your global gitignore

This keeps Claude files out of your Trongate project repos without modifying their `.gitignore`:

```bash
cat > ~/.gitignore_global << 'EOF'
# macOS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE & Editor
.phpintel/
.idea/
.vscode/
*.swp
*.swo

# Misc
*.bak
*.tmp
*.log

# Local dev only (Claude scaffold files)
_reference/
.claude/
CLAUDE.md
EOF

git config --global core.excludesfile ~/.gitignore_global
```

---

## Per-Project Usage

Navigate to the root of any new Trongate project and run:

```bash
trongate-init
```

This will:
- Create `CLAUDE.md` at the project root
- Create `_reference/` with the memory file and templates
- Create `.claude/commands/` with all slash commands
- Clone the latest Trongate docs into `_reference/trongate-docs-repo/`

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
