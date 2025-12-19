import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes.dart';
import '../viewmodels/auth_provider.dart';
import '../components/custom_button.dart';
import '../core/translation_helper.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Controllers for email & password
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(getLocalizedString(ref, 'login'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Center(child: Text('Rural Student Support', style: Theme.of(context).textTheme.headlineSmall)),
              const SizedBox(height: 50),
              Image.network(
                'https://mintbook.com/blog/wp-content/uploads/2019/08/5-Reasons-to-Invest-In-E-Learning-Tools-for-Your-Children.png',
                //width: 300,
                //height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 50),
              // Email field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),

              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),

              // Auth state handling
              authState.when(
                data: (user) {
                  if (user != null) {
                    Future.microtask(() => Navigator.pushReplacementNamed(
                        context, Routes.onboarding));
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      // Login with email/password
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: 'Login',
                          onPressed: () => ref
                              .read(authControllerProvider)
                              .signInWithEmail(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Register new account
                      /*SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: 'Register',
                          onPressed: () => {
                            //ref.read(authControllerProvider).registerWithEmail(emailController.text.trim(), passwordController.text.trim(),),
                            Future.microtask(() => Navigator.pushReplacementNamed(
                                context, Routes.signUp))
                          }),
                      ),*/
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () {
                            Future.microtask(() =>
                                Navigator.pushReplacementNamed(context, Routes.signUp));
                          },
                          child: const Text(
                            "Don't have an account? Register here",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Anonymous login
                      /*SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: 'Continue (Anonymous)',
                          onPressed: () =>
                              ref.read(authControllerProvider).signInAnonymously(),
                        ),
                      ),*/
                    ],
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text(
                  err.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
