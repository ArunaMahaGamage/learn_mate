import 'dart:developer';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final _auth = FirebaseAuth.instance;

  /*Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }*/

  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Catch Firebase-specific errors
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      // Catch any other errors
      throw Exception('Login failed. Please try again.');
    }
  }

  /// Helper to convert Firebase error codes into user-friendly messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get currentUserEmail {
    return _auth.currentUser?.email;
  }

  /// Update user profile with new display name and/or profile photo
  Future<void> updateUserProfile({
    String? displayName,
    File? profilePhotoFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final updateData = <String, dynamic>{
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        updateData['displayName'] = displayName;
      }

      // Convert and add profile photo if provided
      if (profilePhotoFile != null) {
        final photoBase64 = await _convertImageToBase64(profilePhotoFile);
        updateData['profilePhotoBase64'] = photoBase64;
      }

      // Update Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));

      // Update Firebase Auth user profile
      await user.updateProfile(
        displayName: displayName ?? user.displayName,
      );

      // Refresh user data
      await user.reload();
      log('Profile updated successfully in Firestore');
    } catch (e) {
      log('Update profile error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Convert image file to base64 string
  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      log('Converting image to base64...');
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      log('Image converted to base64. Length: ${base64String.length}');
      return base64String;
    } catch (e) {
      log('Base64 conversion error: $e');
      throw Exception('Failed to convert image: $e');
    }
  }
}
