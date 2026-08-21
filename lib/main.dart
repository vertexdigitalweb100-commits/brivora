import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app/app.dart';
import 'core/services/notification_service.dart';
import 'core/providers/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Инициализация локальных уведомлений
  await NotificationService.initialize();

  // Загрузка сохранённого языка
  final localeController = LocaleController();
  await localeController.loadLocale();

  runApp(BrivoraApp(localeController: localeController));
}
