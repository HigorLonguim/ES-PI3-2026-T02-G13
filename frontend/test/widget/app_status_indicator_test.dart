// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/navigation/app_route.dart';
import 'package:frontend/core/widgets/app_status_indicator.dart';

void main() {
  testWidgets('showAppStatusSnackBar exibe toast no overlay global', (
    WidgetTester tester,
  ) async {
    late BuildContext buttonContext;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppRoute.navigatorKey,
        scaffoldMessengerKey: AppRoute.scaffoldMessengerKey,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showAppStatusSnackBar(
                      context: buttonContext,
                      message: 'Toast de teste',
                      type: AppStatusType.success,
                    );
                  },
                  child: Builder(
                    builder: (innerContext) {
                      buttonContext = innerContext;
                      return const Text('Disparar');
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Disparar'));
    await tester.pump();

    expect(find.text('Toast de teste'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Toast de teste'), findsNothing);
  });
}
