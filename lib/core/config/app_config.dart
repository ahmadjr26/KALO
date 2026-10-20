class AppConfig {
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'KALO',
  );
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fgnrrlnvlgxbmfggivfd.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnbnJybG52bGd4Ym1mZ2dpdmZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIzMzkzOTksImV4cCI6MjEwNzkxNTM5OX0.ukKW2XakobbWozihxooDEqh5aOWHu7RIpUUBptyB5Ao',
  );
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );
  static const String geminiLegacyModel = String.fromEnvironment(
    'GEMINI_LEGACY_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );
}
