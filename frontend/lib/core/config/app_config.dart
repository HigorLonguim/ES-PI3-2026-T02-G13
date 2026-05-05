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

  static const String startupsFunctionUrl = String.fromEnvironment(
    'STARTUPS_FUNCTION_URL',
    defaultValue: '',
  );

  static const String walletFunctionUrl = String.fromEnvironment(
    'WALLET_FUNCTION_URL',
    defaultValue: '',
  );

  static const String creditWalletFunctionUrl = String.fromEnvironment(
    'CREDIT_WALLET_FUNCTION_URL',
    defaultValue: '',
  );

  static const String buyTokensFunctionUrl = String.fromEnvironment(
    'BUY_TOKENS_FUNCTION_URL',
    defaultValue: '',
  );

  static const String sellTokensFunctionUrl = String.fromEnvironment(
    'SELL_TOKENS_FUNCTION_URL',
    defaultValue: '',
  );

  static const String transactionsFunctionUrl = String.fromEnvironment(
    'TRANSACTIONS_FUNCTION_URL',
    defaultValue: '',
  );

  static const String privateQuestionFunctionUrl = String.fromEnvironment(
    'PRIVATE_QUESTION_FUNCTION_URL',
    defaultValue: '',
  );

  static const String marketOffersFunctionUrl = String.fromEnvironment(
    'MARKET_OFFERS_FUNCTION_URL',
    defaultValue: '',
  );

  static const String myOffersFunctionUrl = String.fromEnvironment(
    'MY_OFFERS_FUNCTION_URL',
    defaultValue: '',
  );

  static const String createOfferFunctionUrl = String.fromEnvironment(
    'CREATE_OFFER_FUNCTION_URL',
    defaultValue: '',
  );

  static const String cancelOfferFunctionUrl = String.fromEnvironment(
    'CANCEL_OFFER_FUNCTION_URL',
    defaultValue: '',
  );

  static const String acceptOfferFunctionUrl = String.fromEnvironment(
    'ACCEPT_OFFER_FUNCTION_URL',
    defaultValue: '',
  );
}
