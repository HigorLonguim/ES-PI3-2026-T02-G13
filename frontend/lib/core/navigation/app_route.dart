// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show GlobalKey, ScaffoldMessengerState;

class AppRoute<T> extends CupertinoPageRoute<T> {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  AppRoute(Widget page) : super(builder: (_) => page);
}
