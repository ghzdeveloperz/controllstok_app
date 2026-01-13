import 'package:firebase_auth/firebase_auth.dart';

class RegisterState {
  final bool isLoading;
  final bool emailSent;
  final bool emailVerified;
  final bool showPassword;
  final bool showConfirmPassword;
  final String? error;
  final int passwordStrength;
  final User? tempUser;
  final int dotsCount;

  RegisterState({
    required this.isLoading,
    required this.emailSent,
    required this.emailVerified,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.passwordStrength,
    required this.dotsCount,
    this.error,
    this.tempUser,
  });

  factory RegisterState.initial() {
    return RegisterState(
      isLoading: false,
      emailSent: false,
      emailVerified: false,
      showPassword: false,
      showConfirmPassword: false,
      passwordStrength: 0,
      dotsCount: 0,
    );
  }

  RegisterState copyWith({
    bool? isLoading,
    bool? emailSent,
    bool? emailVerified,
    bool? showPassword,
    bool? showConfirmPassword,
    String? error,
    int? passwordStrength,
    User? tempUser,
    int? dotsCount,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      emailSent: emailSent ?? this.emailSent,
      emailVerified: emailVerified ?? this.emailVerified,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword:
          showConfirmPassword ?? this.showConfirmPassword,
      error: error,
      passwordStrength: passwordStrength ?? this.passwordStrength,
      tempUser: tempUser ?? this.tempUser,
      dotsCount: dotsCount ?? this.dotsCount,
    );
  }
}
