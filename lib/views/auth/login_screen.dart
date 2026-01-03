import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smartpos_mobile_manager/core/utils/validators.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController _authController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo animation (line 29)
                  BounceInDown(
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/logo.svg', // TODO: Logo asset add karo
                        height: 120,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Welcome text (line 38)
                  FadeInLeft(
                    child: Text(
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  FadeInLeft(
                    child: Text(
                      'Sign in to your SmartPOS account',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email field (line 53)
                  FadeInUp(
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        // TODO: Email validation logic daalo
                        validator:
                        (value) => Validators.validateEmail(value);
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password field (line 69)
                  FadeInUp(
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        // TODO: Password validation logic daalo
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login button (line 85)
                  Obx(() {
                    return _authController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : FadeInUp(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _authController.login(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );
                                }
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                  }),
                  const SizedBox(height: 20),

                  // Signup link (line 104)
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Get.toNamed('/signup');
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
