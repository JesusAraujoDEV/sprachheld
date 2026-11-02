/// URL base de la API de ranking propia (ver docs/decisions/0003-self-hosted-ranking-api.md).
/// No requiere clave: la API es de solo lectura/inserción de puntajes, sin
/// datos sensibles.
class RankingConfig {
  static const baseUrl = 'https://sprachheld-api.jesusaraujo.lat';
}
