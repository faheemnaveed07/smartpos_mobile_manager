import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../controllers/auth_controller.dart';
import '../../core/utils/validators.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final AuthController _authController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text controllers for ALL fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
                  // Logo Animation (line 35)
                  BounceInDown(
                    child: Center(
                      child: Icon(
                        Icons.store_mall_directory,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title (line 46)
                  FadeInLeft(
                    child: Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Full Name Field (line 56) - YEH ADD KARO
                  FadeInUp(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null; // TODO: Add more validation if needed
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field (line 75) - SAME AS LOGIN
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
                      validator: (value) => Validators.validateEmail(value),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Field (line 94) - YEH ADD KARO
                  FadeInUp(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        hintText: '03001234567',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => Validators.validatePhone(value),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field (line 113) - SAME AS LOGIN
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
                      validator: (value) => Validators.validatePassword(value),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field (line 132) - YEH ADD KARO
                  FadeInUp(
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return Validators.validatePassword(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Signup Button (line 153)
                  Obx(() {
                    return _authController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : FadeInUp(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // TODO: Implement signup method in AuthController
                                    _authController.signUp(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                      _nameController.text,
                                      _phoneController.text,
                                    );
                                    Get.snackbar(
                                      'Success',
                                      'Account created! Please login.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                    );
                                    Get.offNamed('/login');
                                  }
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          );
                  }),
                  const SizedBox(height: 20),

                  // Login Link (line 173)
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () => Get.offNamed('/login'),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
