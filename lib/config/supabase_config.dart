/// Configuración de Supabase para el ranking online (ver
/// docs/decisions/0001-supabase-leaderboard.md).
///
/// La clave anónima es PÚBLICA por diseño de Supabase — está pensada para vivir
/// en el cliente. Lo que protege los datos es Row Level Security (RLS), no el
/// secreto de esta clave: con ella solo se puede leer el ranking e insertar un
/// puntaje, nunca borrar ni alterar datos ajenos. La `service_role` key (que sí
/// es secreta) NUNCA entra acá.
class SupabaseConfig {
  static const url = 'https://uwlkhuxzhqkqnkwfgyua.supabase.co';
  static const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3bGtodXh6aHFrcW5rd2ZneXVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MjA2MDIsImV4cCI6MjA2OTk5NjYwMn0.GwdEXWvEUYE-1CE2sGuRq5Xi-i7xlzvYdc7FqXrduno';
}
