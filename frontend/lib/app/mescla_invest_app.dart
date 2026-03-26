// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/mescla_colors.dart';
import '../features/home/presentation/home_page.dart';
import '../core/navigation/app_route.dart';
import '../core/widgets/debug_menu_overlay.dart';

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'MesclaInvest',
        navigatorKey: AppRoute.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: MesclaColors.purpleStart,
          scaffoldBackgroundColor: MesclaColors.background,
        ),
        builder: (context, child) {
          const isDebug = String.fromEnvironment('DEBUG_MODE') == 'true';
          if (isDebug && child != null) {
            return DebugMenuOverlay(child: child);
          }
          return child ?? const SizedBox.shrink();
        },
        home: const HomePage(),
      ),
    );
  }
}
