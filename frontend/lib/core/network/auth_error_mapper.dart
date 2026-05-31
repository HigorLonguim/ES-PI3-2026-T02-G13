// Autoria: Felipe Sousa - RA: 22018160

String? mapAuthErrorMessage(String? rawMessage) {
  if (rawMessage == null) {
    return null;
  }

  final normalized = rawMessage.trim();
  if (normalized.isEmpty) {
    return null;
  }

  final lower = normalized.toLowerCase();
  if (lower.contains('invalid authentication credentials') ||
      lower.contains('expected oauth 2 access token') ||
      lower.contains('login cookie')) {
    return 'Sessao expirada ou invalida. Faca login novamente.';
  }

  if (lower.contains('permission denied') ||
      lower.contains('unauthenticated')) {
    return 'Acesso nao autorizado. Faca login novamente.';
  }

  return normalized;
}
