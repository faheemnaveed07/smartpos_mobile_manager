import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'services/sqlite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SQLite Database and register globally
  final sqliteService = SQLiteService();
  final database = await sqliteService.database;
  Get.put<Database>(database); // Register database globally

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SmartPOS Mobile Manager',

      // Theme setup (line 23)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // GetX Routes (line 27)
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      debugShowCheckedModeBanner: false, // use correct parameter name
    );
  }
}
