# CLAUDE.md — Project Operating Manual

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

---

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## Framework

This is a **Trongate PHP v2** application. Trongate has its own conventions that differ from Laravel, CodeIgniter, and generic PHP. Always follow Trongate patterns.

## Core Trongate Rules

- Modules live in `modules/[module_name]/`
- Controller sits directly in the module folder — no `controllers/` subfolder
- Controller file: UppercaseFirst snake_case (e.g. `Teams.php`)
- Class name matches filename without extension (e.g. `class Teams extends Trongate`)
- Model file sits at the same level as the controller: `Teams_model.php`, extends `Model`
- All DB work goes through `$this->db` — no raw PDO unless `$this->db` cannot handle it
- URLs follow: `[base_url]/[module]/[method]/[param]`
- Views rendered with `$this->view('file', $data)` or `$this->template('admin', $data)`
- No Eloquent, no Doctrine, no PSR-4 autoloading, no Laravel-style facades

## Third-Party Libraries

No Composer. No exceptions. If a package's functionality is needed, build it as a Trongate module instead. Never suggest `composer require` or introduce a `vendor/` folder.

## File Conventions

- No trailing `?>` in PHP files
- snake_case for methods and variables
- Views are plain PHP files — no Blade, no Twig
- Config lives in `config/config.php` — never hardcode base URLs

## Reference Folder

Use these in order — only go deeper if the current level doesn't cover it:

1. `_reference/trongate-memory.md` — read this first. Dense AI-optimized reference covering core philosophy, architecture, request flow, constants, base classes, DB methods, helpers, security, and common gotchas. Covers 95% of cases.
2. `_reference/trongate-docs-repo/` — full official Trongate docs cloned from GitHub. Only reference when trongate-memory.md doesn't cover something. Key folders: `php_framework/`, `reference/`, `trongate_css/`, `trongate_mx/`
3. `_reference/specs/` — plain-language feature requirements (read before planning)
4. `_reference/plans/` — step-by-step implementation plans (read before coding)

## Workflow

1. A spec is written first (`_reference/specs/FEATURE_NAME.md`)
2. A plan is generated from the spec (`_reference/plans/FEATURE_NAME_plan.md`)
3. Code is written following the plan, one task at a time
4. Mark tasks complete in the plan as you go

## What to Avoid

- No `controllers/` subfolders — that is the old v1 pattern
- No Composer installs — ever
- No empty constructors calling `parent::__construct()`
- No `namespace` declarations unless the project already uses them
- No rewriting of working code to match style preferences
- No new dependencies for problems Trongate already handles natively
- No multiple classes in one file
