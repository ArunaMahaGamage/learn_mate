import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

class ProfileState {
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final firebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});


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

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  final authController = ref.read(authControllerProvider);
  return ProfileViewModel(authController);
});



class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel(this._authController)
      : super(const ProfileState());

  final AuthController _authController;

  Future<void> updateProfile(
    User user,
    AuthController authController,
    String displayName,
    File? profileImage,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await authController.updateUserProfile(
        displayName: displayName.isNotEmpty ? displayName : null,
        profilePhotoFile: profileImage,
      );

      await user.reload();

          await _authController.updateUserProfile(
        displayName: displayName,
        profilePhotoFile: profileImage,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _authController.signOut();
  }
}