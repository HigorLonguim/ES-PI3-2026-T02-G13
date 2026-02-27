/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/material.dart';

import '../features/home/presentation/home_page.dart';

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MesclaInvest',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
