# Audits — Point-in-time reviews

Output of an audit run by a role (`DOC` on documentation, `SEC` on data/permissions, `QA` on test coverage, `SC` on code-vs-spec). An audit is **evidence at a date**, not living truth: it is never updated in place — a new audit gets a new file.

## Convention

- One file per audit: `<YYYY-MM-DD>-<role>-<topic>.md`, kebab-case English.
- Always state: what was audited, against which standard, what was found, and what each finding became (story, requirement, ADR, deviation).
- Findings that are accepted as intentional go to [`../DEVIATIONS.md`](../DEVIATIONS.md); findings that need work leave this folder as `stories/` or `requirements/`.
- Files are immutable once written.
