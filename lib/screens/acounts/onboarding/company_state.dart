class CompanyState {
  final bool isLoading;
  final String? error;

  /// Tipo selecionado no bottom sheet:
  /// - '' = não selecionado (obrigatório selecionar)
  /// - 'Restaurante', 'Mercado', etc
  /// - 'Outro' (exige customBusinessType)
  final String businessType;

  /// Perguntas "Sim/Não" para campos condicionais
  final bool useFantasyName;
  final bool useOwner;
  final bool usePhone;

  /// Quando businessType == 'Outro', o usuário descreve aqui (até 20 chars)
  final String customBusinessType;

  const CompanyState({
    required this.isLoading,
    required this.businessType,
    required this.useFantasyName,
    required this.useOwner,
    required this.usePhone,
    required this.customBusinessType,
    this.error,
  });

  factory CompanyState.initial() {
    return const CompanyState(
      isLoading: false,
      error: null,
      businessType: '',
      useFantasyName: false,
      useOwner: false,
      usePhone: false,
      customBusinessType: '',
    );
  }

  CompanyState copyWith({
    bool? isLoading,
    String? businessType,
    bool? useFantasyName,
    bool? useOwner,
    bool? usePhone,
    String? customBusinessType,
    String? error,
    bool clearError = false,
  }) {
    return CompanyState(
      isLoading: isLoading ?? this.isLoading,
      businessType: businessType ?? this.businessType,
      useFantasyName: useFantasyName ?? this.useFantasyName,
      useOwner: useOwner ?? this.useOwner,
      usePhone: usePhone ?? this.usePhone,
      customBusinessType: customBusinessType ?? this.customBusinessType,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
