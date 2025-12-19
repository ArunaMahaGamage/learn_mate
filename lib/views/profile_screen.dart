import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../viewmodels/auth_provider.dart';
import '../core/routes.dart';
import '../core/translation_helper.dart';

/// Provider to access current Firebase user (Existing)
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Load user data from Firebase
final userDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final authUser = ref.watch(firebaseUserProvider);
  
  return authUser.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) => snapshot.data());
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _selectedImage;
  bool _isUpdating = false;

  Future<void> _pickImage({required ImageSource source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile(
    User user,
    AuthController authController,
    String displayName,
  ) async {
    setState(() => _isUpdating = true);

    try {
      await authController.updateUserProfile(
        displayName: displayName.isNotEmpty ? displayName : null,
        profilePhotoFile: _selectedImage,
      );

      await user.reload();

      if (mounted) {
        setState(() => _selectedImage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _showEditProfileDialog(
    User user,
    AuthController authController,
    Map<String, dynamic>? userData,
  ) async {
    File? localSelectedImage = _selectedImage;
    final nameController = TextEditingController(
      text: userData?['displayName'] ?? user.displayName ?? '',
    );
    
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(getLocalizedString(ref, 'edit_profile')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display selected image or current profile
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        key: ValueKey(localSelectedImage?.path), // Force rebuild
                        backgroundImage: localSelectedImage != null
                            ? FileImage(localSelectedImage!)
                            : (userData?['profilePhotoBase64'] != null
                                ? MemoryImage(base64Decode(userData!['profilePhotoBase64']))
                                : const AssetImage('assets/default_avatar.png')
                                      as ImageProvider),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await showModalBottomSheet(
                              context: context,
                              builder: (bottomContext) => Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      getLocalizedString(ref, 'select_image_source'),
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt, color: Colors.blue),
                                      title: Text(getLocalizedString(ref, 'take_photo')),
                                      onTap: () {
                                        Navigator.pop(bottomContext);
                                        _pickImage(source: ImageSource.camera).then((_) {
                                          setDialogState(() {
                                            localSelectedImage = _selectedImage;
                                          });
                                        });
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.image, color: Colors.green),
                                      title: Text(getLocalizedString(ref, 'choose_gallery')),
                                      onTap: () {
                                        Navigator.pop(bottomContext);
                                        _pickImage(source: ImageSource.gallery).then((_) {
                                          setDialogState(() {
                                            localSelectedImage = _selectedImage;
                                          });
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: getLocalizedString(ref, 'display_name'),
                    hintText: getLocalizedString(ref, 'enter_your_name'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedImage = null);
                nameController.dispose();
                Navigator.pop(context);
              },
              child: Text(getLocalizedString(ref, 'cancel')),
            ),
            ElevatedButton(
              onPressed: _isUpdating
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _updateProfile(
                        user,
                        authController,
                        nameController.text,
                      );
                      nameController.dispose();
                    },
              child: _isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(getLocalizedString(ref, 'save')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(firebaseUserProvider);
    final userDataAsync = ref.watch(userDataProvider);
    final authController = ref.read(authControllerProvider);

    final profileTitle = getLocalizedString(ref, 'profile');
    
    return Scaffold(
      appBar: AppBar(title: Text(profileTitle)),
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
            
            return userDataAsync.when(
              data: (userData) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile photo with edit button
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: userData?['profilePhotoBase64'] != null
                                ? MemoryImage(base64Decode(userData!['profilePhotoBase64']))
                                : const AssetImage('assets/default_avatar.png')
                                      as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showEditProfileDialog(user, authController, userData),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // User name from Firestore
                      Text(
                        userData?['displayName'] ?? user.displayName ?? 'Unknown User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),

                      // Email address
                      Text(
                        user.email ?? 'No email available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label:  Text(getLocalizedString(ref, 'logout')),
                          onPressed: () async {
                            try {
                              await authController.signOut();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  Routes.login,
                                  (route) => false,
                                );
                              }
                            } catch (e) {
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
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error loading profile: $e', style: const TextStyle(color: Colors.red)),
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
