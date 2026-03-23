// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/cupertino.dart';

class AppRoute<T> extends CupertinoPageRoute<T> {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  AppRoute(Widget page) : super(builder: (_) => page);
}
