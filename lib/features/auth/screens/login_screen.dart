import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  void login() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    // Temporary dummy login.
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Login successful - API will be connected next",
            ),
          ),
        );
      },
    );
  }

  void openRegister() {
    // Registration navigation will be added next.
  }

  void forgotPassword() {
    // Forgot password will be implemented later.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const AuthHeader(
                      title: "Welcome Back",
                      subtitle:
                          "Login to your account",
                    ),

                    const SizedBox(height: 32),

                    Text(
                      "Username or Email",
                      style: AppTextStyles.label,
                    ),

                    const SizedBox(height: 8),

                    AppTextField(
                      label: "Username or Email",
                      controller:
                          usernameController,
                      validator:
                          Validators.required,
                    ),

                    const SizedBox(height: 18),

                    Text(
                      "Password",
                      style: AppTextStyles.label,
                    ),

                    const SizedBox(height: 8),

                    AppTextField(
                      label: "Password",
                      controller:
                          passwordController,
                      obscureText: true,
                      validator:
                          Validators.password,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment:
                          Alignment.centerRight,

                      child: TextButton(
                        onPressed:
                            forgotPassword,
                        child: const Text(
                          "Forgot Password?",
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    AppButton(
                      text: "Login",
                      loading: loading,
                      onPressed: login,
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: openRegister,
                        child: const Text(
                          "New user? Register",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}