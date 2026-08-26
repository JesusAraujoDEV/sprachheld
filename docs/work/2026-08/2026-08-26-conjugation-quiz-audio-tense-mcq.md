# 2026-08-26 — TTS, tense filter and MCQ mode for the write-conjugation quiz

## What changed
`WriteConjugationScreen` gained three additions: an audio button (pronounces the infinitive), a Präsens/Präteritum/Ambos tense selector, and a toggle to switch from typing the answer to picking it from 4 multiple-choice options. The 3 wrong options are always real conjugations of the same verb (other person or tense), never random strings. The screen was split into `lib/modes/write_conjugation/{tense_selector,write_conjugation_options,write_text_input,distractor_pool}.dart` to stay under the 200-line screen ceiling; `distractor_pool.dart` ships a unit test. App version bumped to 1.2.0 (pubspec `1.2.0+3`).

## Why
User request: practice conjugation without always typing, hear pronunciation, and choose which tense to drill.

## How
Implemented by `kiro-cli` (Kiro's agent CLI) running unattended in an Orca-managed child worktree (`orca worktree create` off `main`, `orca terminal create --command kiro-cli`, task brief sent via `orca terminal send`). The brief pointed it at the existing patterns to reuse — `verb_quiz_screen.dart`'s MCQ shape, `option_chip.dart`, `audio_button.dart`, and `clock_quiz_screen.dart`'s `Wrap`-of-`SizedBox` layout (avoids the fixed-aspect-ratio clipping bug fixed there earlier) — and the file-size/one-symbol-per-file rule from `AGENTS.md`. Verified independently before merge: read every changed/new file, ran `flutter analyze` (clean) and `flutter test` (39/39) inside the worktree, then committed there and `git merge --no-ff` into `main` from the primary worktree. Kiro left its changes uncommitted; the merge commit and version bump were done manually after review.

## Promoted knowledge
None — the Orca/kiro-cli delegation recipe is a reusable workflow, not project-specific behavior; it belongs in the user's own tooling notes, not this repo's living docs.

## Follow-ups
- [ ] None
