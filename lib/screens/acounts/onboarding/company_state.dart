// lib/screens/acounts/onboarding/company_state.dart
class CompanyState {
  final bool isLoading;
  final String? error;

  final String businessType;
  final String customBusinessType;

  final bool useFantasyName;
  final bool useOwner;
  final bool usePhone;

  final bool acceptTerms;
  final bool acceptPrivacy;

  const CompanyState({
    required this.isLoading,
    required this.businessType,
    required this.customBusinessType,
    required this.useFantasyName,
    required this.useOwner,
    required this.usePhone,
    required this.acceptTerms,
    required this.acceptPrivacy,
    this.error,
  });

  factory CompanyState.initial() {
    return const CompanyState(
      isLoading: false,
      error: null,
      businessType: '', // ✅ começa vazio (sem default)
      customBusinessType: '',
      useFantasyName: false,
      useOwner: false,
      usePhone: false,
      acceptTerms: false,
      acceptPrivacy: false,
    );
  }

  CompanyState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? businessType,
    String? customBusinessType,
    bool? useFantasyName,
    bool? useOwner,
    bool? usePhone,
    bool? acceptTerms,
    bool? acceptPrivacy,
  }) {
    return CompanyState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      businessType: businessType ?? this.businessType,
      customBusinessType: customBusinessType ?? this.customBusinessType,
      useFantasyName: useFantasyName ?? this.useFantasyName,
      useOwner: useOwner ?? this.useOwner,
      usePhone: usePhone ?? this.usePhone,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      acceptPrivacy: acceptPrivacy ?? this.acceptPrivacy,
    );
  }
}
