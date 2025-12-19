import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/routes.dart';

/// Provider for FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Signup controller
class SignupController extends StateNotifier<AsyncValue<User?>> {
  SignupController(this._auth) : super(const AsyncValue.data(null));

  final FirebaseAuth _auth;

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      state = AsyncValue.data(userCredential.user);
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e.message ?? 'Signup failed', StackTrace.current);
    }
  }
}

/// Riverpod provider
final signupProvider =
StateNotifierProvider<SignupController, AsyncValue<User?>>((ref) {
  return SignupController(ref.read(firebaseAuthProvider));
});

/// Signup Screen UI
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupState = ref.watch(signupProvider);

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Login screen
            Navigator.pushReplacementNamed(context, Routes.login);
          },
        ),),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Name field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),

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

              // Signup button
              signupState.when(
                data: (user) {
                  if (user != null) {
                    Future.microtask(() => Navigator.pushReplacementNamed(
                        context, Routes.onboarding));
                    return const SizedBox.shrink();
                  }
                  return ElevatedButton(
                    onPressed: () => ref.read(signupProvider.notifier).register(
                      nameController.text.trim(),
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    ),
                    child: const Text('Create Account'),
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
