# Plan: [Feature Name]

**Date:** YYYY-MM-DD
**Spec:** `_reference/specs/[SPEC_FILE].md`
**Status:** In Progress | Complete | Blocked

## Summary
One paragraph describing what this plan implements and why.

## Branch
Before starting any tasks, create a new branch under the `feature/` subfolder.

- **Branch name:** `feature/[short-feature-slug]`
- Create it from an up-to-date `main` (or your base branch):
  ```bash
  git checkout main
  git pull
  git checkout -b feature/[short-feature-slug]
  ```
- All work for this plan happens on this branch. Do not commit directly to the base branch.

## Affected Files
List every file that will be created or modified.

- `modules/[module]/[Module].php` — 
- `modules/[module]/[Module]_model.php` — 
- `modules/[module]/views/[view].php` — 
- `config/config.php` — 

## Tasks

### Phase 1: [e.g. Database]
- [ ] Task 1
- [ ] Task 2

### Phase 2: [e.g. Controller]
- [ ] Task 1
- [ ] Task 2

### Phase 3: [e.g. Views]
- [ ] Task 1
- [ ] Task 2

### Phase 4: [e.g. Testing]
- [ ] Manually test happy path
- [ ] Test edge cases from spec
- [ ] Confirm no regressions in adjacent modules

## Notes
Anything Claude or the developer should know while implementing this plan.

- Once Phase 4 passes, merge this branch via pull request into the base branch, then delete the feature branch.
-