import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // 3-second delay (line 18)
    await Future.delayed(const Duration(seconds: 3));

    // Check user logged in? (line 21)
    // TODO: Get.find<AuthController>().checkLoginStatus();

    Get.offNamed('/login'); // TODO: Logic daalna hai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation (line 32)
            BounceInDown(
              child: const Icon(
                Icons.store_mall_directory,
                size: 100,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            // App name fade in (line 40)
            FadeInUp(
              child: Text(
                'SmartPOS Manager',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
