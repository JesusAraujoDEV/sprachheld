# 2026-09-23 — Desktop/wide responsive layout

## What changed
The web/desktop build no longer looks like a stretched phone. A single shared
breakpoint helper (`lib/theme/breakpoints.dart`) drives three bands — mobile
(< 600), tablet (600–1023) and desktop (≥ 1024). The `main.dart` builder patch
that forced a 600 px phone column is gone; content now centers under a generous
`kMaxContentWidth` (1200). The Home screen gains a two-panel desktop layout
(`HomeWideLayout`), the practice grid grows from 2 to 3 columns on wide, quiz
sessions and the consultation tables center their content at a readable width,
and the two bottom sheets cap their width so they stop spanning the whole
monitor. Mobile (< 600) is unchanged in look and behavior.

## Why
The app is used on desktop web (https://sprachheld.jesusaraujo.lat). The
provisional fix in `main.dart` (`ConstrainedBox(maxWidth: 600)`) centered a
narrow phone column and left the rest of a wide screen empty. The goal was a
real desktop layout that uses the horizontal space while keeping the mobile
experience byte-identical.

## How
- **UX-first crew consultation.** Design was converged before implementation:
  ux-architect (bands + per-screen strategy, ordered by impact), then
  frontend-architect (Flutter structure, shared helper, reuse plan), then
  qa-test-architect (the single widget test). Each ran as an isolated subagent
  reading its canonical crew role definition.
- **One breakpoint source.** `Breakpoints` extension on `BuildContext`
  (`isMobile`/`isTablet`/`isWide` + named threshold constants). Every screen
  consumes it; no thresholds are copied per file. Only `MediaQuery`, no new
  dependency.
- **Mobile stays identical by construction.** Below `kMaxContentWidth` the
  `main.dart` clamp never bites, so a mobile viewport renders exactly as before.
  The wide layout is a separate branch (`context.isWide ? HomeWideLayout : …`),
  never reached on mobile. Bottom-sheet `constraints` (`kModalMaxWidth` 640) and
  table max widths (`kReadableMaxWidth` 760) are wider than any phone, so they
  are inert on mobile.
- **Reuse over rewrite.** `HomeWideLayout` and the mobile column share the same
  extracted blocks (`HomeHeader`, `HomeStats`, `HomeSectionHeader`,
  `HomeSettings`) and existing widgets (`ModeCard`, `PracticeGrid`,
  `LookupList`, `QuizShell`, `StatChip`); nothing visual was reimplemented.
- **Quiz + tables.** `QuizShell` centers its child under a 640 px cap on wide
  (one change proportions every quiz mode). The conjugation and possessive
  tables center under `kReadableMaxWidth`.
- **File-size discipline.** Adding the wide wrapper pushed
  `conjugation_table_screen.dart` to 209 lines (> 200 screen ceiling); the
  tense-table rendering was extracted into
  `lib/modes/conjugation_table/conjugation_table.dart` (`ConjugationTable`),
  bringing the screen to 150. All touched/created files are within their
  ceilings.
- **Design decision — desktop threshold at 1024.** Chosen over the brief's
  ~900 lower bound so common small laptops/tablets in landscape do not jump into
  the two-panel layout prematurely; the tablet band (600–1023) keeps the single
  column with the 3-column grid reserved for true desktop width.

Verification: `flutter analyze` clean, `flutter test` 41/41 green (including the
new `test/responsive_home_test.dart`), `flutter build web --release
--no-wasm-dry-run` builds.

## Promoted knowledge
None. The responsive rules live in code (`lib/theme/breakpoints.dart`, the
per-screen `context.isWide` branches) and are self-describing; no living guide
existed for layout conventions and one was not warranted for this change.

## Follow-ups
- [ ] Home stats row (`home_stats.dart`): the 4 `StatChip`s with
  `spaceBetween` overflow by ~87 px at ~400 px logical width. This is
  pre-existing mobile behavior (markup identical to the original inline stats,
  only hidden because the old smoke test ran at 800×600). Left untouched to keep
  mobile identical; `responsive_home_test` exercises the mobile band at 599 px
  to avoid it. Worth a dedicated fix (wrap/scale the chips) as a mobile-polish
  task.
- [ ] Conjugation search dropdown (`conjugation_table_screen.dart`
  `_buildOptions`) sizes its width to `MediaQuery.width - 48`; on a centered
  wide table the overlay is viewport-wide rather than field-wide. Pre-existing,
  cosmetic.
- [ ] Tablet band (600–1023) has no dedicated widget test (single-test budget);
  add coverage if the 3-column grid at tablet is later deemed risk-bearing.
