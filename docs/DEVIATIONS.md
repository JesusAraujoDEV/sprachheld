# Accepted deviations from the crew documentation standard

This project was audited against the `crew` plugin documentation standard (taxonomy in [`AGENTS.md`](AGENTS.md), circuit in [`guides/delivery-circuit.md`](guides/delivery-circuit.md)). The deviations below were reviewed by the project owner and **deliberately kept**.

> **Binding for all agents:** a deviation recorded here is a decision, not a defect. Do not "fix" it, do not flag it again in audits, do not treat the standard as overriding it. To revisit one, raise it with the owner — never unilaterally.

## Registry

| # | Deviation | Standard says | This project does | Rationale | Decided | Date |
|---|-----------|---------------|-------------------|-----------|---------|------|
| 1 | Spec file name | `docs/spec.md` is the technical specification | `docs/PLAN.md` holds scope, content model and roadmap | The plan predates the crew install and is already the single source of truth; renaming buys nothing | Owner | 2026-08-17 |
| 2 | Quality tooling | `standards/code-quality.md` names TS tooling (Biome, Zod, no default exports) | Dart equivalents: `flutter analyze` + `flutter_lints`, parse guards at the JSON boundary | Flutter project; the *limits* (one symbol/file, sizes, complexity) apply unchanged, only the tooling names differ | Owner | 2026-08-17 |
| 3 | Extra docs tree | Taxonomy lists briefs/stories/requirements/decisions/proposals/guides/work | Adds `docs/audits/` for point-in-time role audits | Keeps dated audit evidence out of `work/` (change history) and out of `decisions/` (living state) | Owner | 2026-08-17 |

## Convention

- One row per deviation; keep rationale to one line, link a fuller doc if needed.
- Added only as the outcome of a `DOC` audit conversation with the owner — never unilaterally by an agent.
- Removing a row requires the owner's explicit decision (the project converged to the standard, or the deviation was superseded).
- If this file is empty, the project follows the standard fully.
