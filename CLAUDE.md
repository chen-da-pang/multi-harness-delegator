# Claude Code Configuration

## Workflow

**This project enforces Matt workflow and writing-for-agents principles via Git hooks.**

Every change must follow:

1. **Spec ticket**: `/to-spec` → `.specs/vX.X.X-<name>.md`
2. **Create tickets**: `/to-tickets` → GitHub issues
3. **Branch naming**: `ticket-N-description`
4. **Implement**: Edit SKILL.md (follow `/writing-for-agents` principles)
5. **Commit**: Message must reference ticket (`Closes #N`)
6. **Review**: `/code-review` → `.reviews/vX.X.X-review.md`
7. **PR**: `/pr` → Create pull request

**Install hooks first**:
```bash
./scripts/install-hooks.sh
```

See `docs/GIT-HOOKS.md` for details.

## Agent skills

### Issue tracker

Issues are tracked in GitHub using the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Using default triage vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout: `CONTEXT.md` at repo root + `docs/adr/` for architectural decisions. See `docs/agents/domain.md`.
