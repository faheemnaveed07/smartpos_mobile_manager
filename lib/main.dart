import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/splash/splash_screen.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialize karo yahan (line 9)
  await Firebase.initializeApp(
    options: FirebaseOptions(/* firebase project ki details yahan daalo */),
  );

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

      debugShowBaner: false, // Spelling check karo!
    );
  }
}
