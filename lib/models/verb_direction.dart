/// Quiz direction for verb flashcards.
enum VerbDirection {
  /// Alemán → Español (show German, answer Spanish).
  deToEs,

  /// Español → Alemán (show Spanish, answer German).
  esToDe,

  /// Both directions mixed randomly (default, original behavior).
  mixed,
}
