/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/home/presentation/home_page.dart';

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
      child: const MaterialApp(
        title: 'MesclaInvest',
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
