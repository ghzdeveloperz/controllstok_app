// lib/screens/userPerfil/state/perfil_controller.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';




import 'perfil_state.dart';

final perfilControllerProvider =
    StateNotifierProvider.autoDispose<PerfilController, PerfilState>(
  (ref) => PerfilController(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  )..load(),
);

class PerfilController extends StateNotifier<PerfilState> {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  PerfilController({
    required this.auth,
    required this.firestore,
    required this.storage,
  }) : super(const PerfilState.initial());

  Future<void> load() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      await Future.delayed(const Duration(milliseconds: 350));

      final user = auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false, user: null);
        return;
      }

      await user.reload();
      final freshUser = auth.currentUser!;
      final doc = await firestore.collection('users').doc(freshUser.uid).get();
      final data = doc.data();

      final company = (data?['company'] ?? data?['companyName']) as String?;
      final plan = (data?['plan'] ?? data?['plano']) as String?;
      final photoUrl =
          (data?['photoUrl'] ?? data?['avatarUrl'] ?? data?['photoURL'])
              as String?;

      state = state.copyWith(
        user: freshUser,
        companyName: company,
        plan: plan,
        photoUrl: photoUrl,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateCompanyName(String newName) async {
    final user = state.user;
    if (user == null) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    await firestore.collection('users').doc(user.uid).set(
      {'company': trimmed},
      SetOptions(merge: true),
    );

    state = state.copyWith(companyName: trimmed);
  }

  Future<String?> pickAndUploadAvatar() async {
    final user = state.user;
    if (user == null) return null;
    if (state.isUploadingAvatar) return null;

    try {
      state = state.copyWith(isUploadingAvatar: true, clearError: true);

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) {
        state = state.copyWith(isUploadingAvatar: false);
        return null;
      }

      final uid = user.uid;
      final ref = storage.ref('users/$uid/avatar.jpg');

      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();

      await firestore.collection('users').doc(uid).set(
        {'photoUrl': url},
        SetOptions(merge: true),
      );

      state = state.copyWith(photoUrl: url, isUploadingAvatar: false);
      return url;
    } catch (e) {
      state = state.copyWith(
        isUploadingAvatar: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    state = state.copyWith(user: null);
  }

  /// Desativa conta (marca active=false) após reautenticação com senha
  Future<void> deactivateAccount({
    required String password,
  }) async {
    final user = state.user;
    if (user == null) throw FirebaseAuthException(code: 'no-user');

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(code: 'no-email');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);

    await firestore.collection('users').doc(user.uid).update({'active': false});
  }

  // ====== helpers de plano (sem i18n aqui: i18n fica na UI/formatter) ======
  String normalizedPlan(String? planRaw) {
    final p = (planRaw ?? '').trim().toLowerCase();
    if (p == 'pro' || p == 'pró') return 'pro';
    if (p == 'max') return 'max';
    return 'free';
  }
}
