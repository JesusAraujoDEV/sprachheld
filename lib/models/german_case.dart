/// Los cuatro casos gramaticales del alemán. El caso que rige una preposición
/// (o el que impone movimiento vs. ubicación en las Wechselpräpositionen)
/// determina la forma del artículo — ver docs/PLAN-preposiciones.md §3.
enum GermanCase { nominativ, akkusativ, dativ, genitiv }

GermanCase germanCaseFromJson(String value) =>
    GermanCase.values.byName(value);
