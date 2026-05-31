// Autoria: Felipe Sousa - RA: 22018160

String formatCurrency(double value) {
  final isNegative = value < 0;
  final absValue = value.abs();
  final fixed = absValue.toStringAsFixed(2);
  final parts = fixed.split('.');
  final integer = parts.first;
  final decimal = parts.last;

  final buffer = StringBuffer();
  for (var i = 0; i < integer.length; i++) {
    final reverseIndex = integer.length - i;
    buffer.write(integer[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  final prefix = isNegative ? '-R\$ ' : 'R\$ ';
  return '$prefix${buffer.toString()},$decimal';
}

String formatCompactCurrency(double value) {
  if (value >= 1000000) {
    return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
  }

  return formatCurrency(value);
}

String formatPercent(double value) {
  final signal = value >= 0 ? '+' : '';
  return '$signal${value.toStringAsFixed(2)}%';
}
