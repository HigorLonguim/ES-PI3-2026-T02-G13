/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/cupertino.dart';

class AppRoute<T> extends CupertinoPageRoute<T> {
  AppRoute(Widget page) : super(builder: (_) => page);
}
