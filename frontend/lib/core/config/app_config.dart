// Autoria: Felipe Sousa - RA: 22018160

class AppConfig {
  static const bool recoverPasswordUseMock = bool.fromEnvironment(
    'RECOVER_PASSWORD_USE_MOCK',
    defaultValue: false,
  );

  static const String authApiBaseUrl = String.fromEnvironment(
    'AUTH_API_BASE_URL',
    defaultValue: '',
  );

  static const String webHostName = String.fromEnvironment(
    'WEB_HOSTNAME',
    defaultValue: 'localhost',
  );

  static const String deviceHostIp = String.fromEnvironment(
    'DEVICE_HOST_IP',
    defaultValue: '',
  );
}
