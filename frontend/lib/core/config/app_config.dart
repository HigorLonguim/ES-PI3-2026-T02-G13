// Autoria: Felipe Sousa - RA: 22018160

class AppConfig {
  static const bool recoverPasswordUseMock = bool.fromEnvironment(
    'RECOVER_PASSWORD_USE_MOCK',
    defaultValue: false,
  );
}
