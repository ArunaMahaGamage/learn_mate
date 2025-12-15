import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/auth_provider.dart';
import '../core/routes.dart';

/// Provider to access current Firebase user (Existing)
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(firebaseUserProvider);
    // Get the AuthController instance
    final authController = ref.read(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              Future.microtask(
                () => Navigator.pushReplacementNamed(context, Routes.login),
              );
              return const Center(
                child: Text('No user logged in. Redirecting...'),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile photo
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                  ),
                  const SizedBox(height: 20),

                  // User name
                  Text(
                    user.displayName ?? 'Unknown User',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  // Email address
                  Text(
                    user.email ?? 'No email available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),

                  // --- LOGOUT FUNCTIONALITY ADDED HERE ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: () async {
                        try {
                          await authController.signOut();
                          // Navigate back to Login after successful logout
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.login,
                              (route) => false, // Clears all previous routes
                            );
                          }
                        } catch (e) {
                          // Handle logout error (e.g., show a Snackbar)
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logout Failed: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // ----------------------------------------
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
