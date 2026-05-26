/* Nome: Felipe Sousa de Almeida | RA: 22018160 */

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/mescla_invest_app.dart';
import 'core/config/app_config.dart';
import 'core/config/system_ui_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureSystemUI();
  await _startFirebase();
  runApp(const MesclaInvestApp());
}

Future<void> _startFirebase() async {
  try {
    if (AppConfig.firebaseWebApiKey.isEmpty ||
        AppConfig.firebaseProjectId.isEmpty ||
        AppConfig.firebaseAppId.isEmpty ||
        AppConfig.firebaseMessagingSenderId.isEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: AppConfig.firebaseWebApiKey,
        projectId: AppConfig.firebaseProjectId,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
      ),
    );
  } catch (_) {}
}
