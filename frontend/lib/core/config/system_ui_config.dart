/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void configureSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
}
