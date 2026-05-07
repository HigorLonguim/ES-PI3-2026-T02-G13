// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';

enum AppStatusType { success, error, warning, info }

class AppStatusIndicator extends StatelessWidget {
  const AppStatusIndicator({
    super.key,
    required this.message,
    required this.type,
  });

  final String message;
  final AppStatusType type;

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(type);

    return Container(
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(style.icon, color: style.iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: style.textColor,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showAppStatusSnackBar({
  required BuildContext context,
  required String message,
  required AppStatusType type,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.of(context);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        content: AppStatusIndicator(message: message, type: type),
      ),
    );
}

class _StatusStyle {
  const _StatusStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;
}

_StatusStyle _resolveStyle(AppStatusType type) {
  switch (type) {
    case AppStatusType.success:
      return const _StatusStyle(
        backgroundColor: Color(0xFF112A1E),
        borderColor: Color(0xFF1E7A4A),
        iconColor: Color(0xFF44D17A),
        textColor: Color(0xFFE9FFF1),
        icon: Icons.check_circle_rounded,
      );
    case AppStatusType.error:
      return const _StatusStyle(
        backgroundColor: Color(0xFF2B1218),
        borderColor: Color(0xFF8F2E45),
        iconColor: Color(0xFFF05A7E),
        textColor: Color(0xFFFFEBF0),
        icon: Icons.error_rounded,
      );
    case AppStatusType.warning:
      return const _StatusStyle(
        backgroundColor: Color(0xFF2B2312),
        borderColor: Color(0xFF9A6D20),
        iconColor: Color(0xFFFFC145),
        textColor: Color(0xFFFFF8E8),
        icon: Icons.warning_amber_rounded,
      );
    case AppStatusType.info:
      return const _StatusStyle(
        backgroundColor: Color(0xFF111E2D),
        borderColor: Color(0xFF1F5E8C),
        iconColor: Color(0xFF57A9FF),
        textColor: Color(0xFFEAF5FF),
        icon: Icons.info_rounded,
      );
  }
}
