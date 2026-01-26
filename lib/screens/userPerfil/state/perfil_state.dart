// lib/screens/userPerfil/state/perfil_state.dart
import 'package:firebase_auth/firebase_auth.dart';

class PerfilState {
  final bool isLoading;
  final String? errorMessage;

  final User? user;

  final String? companyName;
  final String? plan; // free|pro|max (ou variações antigas)
  final String? photoUrl;

  final bool isUploadingAvatar;

  const PerfilState({
    required this.isLoading,
    this.errorMessage,
    this.user,
    this.companyName,
    this.plan,
    this.photoUrl,
    required this.isUploadingAvatar,
  });

  const PerfilState.initial()
      : isLoading = true,
        errorMessage = null,
        user = null,
        companyName = null,
        plan = null,
        photoUrl = null,
        isUploadingAvatar = false;

  PerfilState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? user,
    String? companyName,
    String? plan,
    String? photoUrl,
    bool? isUploadingAvatar,
    bool clearError = false,
  }) {
    return PerfilState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
      companyName: companyName ?? this.companyName,
      plan: plan ?? this.plan,
      photoUrl: photoUrl ?? this.photoUrl,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
    );
  }
}
