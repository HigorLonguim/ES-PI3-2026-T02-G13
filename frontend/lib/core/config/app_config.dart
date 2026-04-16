// Autoria: Felipe Sousa - RA: 22018160

class AppConfig {
  static const bool recoverPasswordUseMock = bool.fromEnvironment(
    'RECOVER_PASSWORD_USE_MOCK',
    defaultValue: false,
  );

  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  static const String registerFunctionUrl = String.fromEnvironment(
    'REGISTER_FUNCTION_URL',
    defaultValue: '',
  );

  static const String firebaseWebApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: '',
  );
}
