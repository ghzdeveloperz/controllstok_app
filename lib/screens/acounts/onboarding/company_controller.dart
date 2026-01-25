import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'company_state.dart';

class CompanyBusinessTypeCodes {
  static const restaurant = 'restaurant';
  static const market = 'market';
  static const bakery = 'bakery';
  static const pharmacy = 'pharmacy';
  static const store = 'store';
  static const workshop = 'workshop';
  static const industry = 'industry';
  static const distributor = 'distributor';
  static const other = 'other';
}

class CompanyController extends ChangeNotifier {
  // ===== Controllers =====
  final TextEditingController companyController = TextEditingController();
  final TextEditingController fantasyNameController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  /// ✅ necessário para o "Outro" digitável
  final TextEditingController customBusinessTypeController = TextEditingController();

  // ===== State =====
  CompanyState _state = CompanyState.initial();
  CompanyState get state => _state;

  // ===== Options =====
  /// ✅ valores "estáveis" (não dependem do idioma)
  final List<String> businessTypes = const [
    CompanyBusinessTypeCodes.restaurant,
    CompanyBusinessTypeCodes.market,
    CompanyBusinessTypeCodes.bakery,
    CompanyBusinessTypeCodes.pharmacy,
    CompanyBusinessTypeCodes.store,
    CompanyBusinessTypeCodes.workshop,
    CompanyBusinessTypeCodes.industry,
    CompanyBusinessTypeCodes.distributor,
    CompanyBusinessTypeCodes.other,
  ];

  CompanyController() {
    companyController.addListener(_onFieldsChanged);
    fantasyNameController.addListener(_onFieldsChanged);
    ownerController.addListener(_onFieldsChanged);
    phoneController.addListener(_onFieldsChanged);
    customBusinessTypeController.addListener(_onCustomBusinessChanged);
  }

  // ===== Getters (pra UI) =====
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  String get businessType => _state.businessType;
  String get customBusinessType => _state.customBusinessType;

  bool get useFantasyName => _state.useFantasyName;
  bool get useOwner => _state.useOwner;
  bool get usePhone => _state.usePhone;

  bool get acceptTerms => _state.acceptTerms;
  bool get acceptPrivacy => _state.acceptPrivacy;

  bool get hasBusinessType => _state.businessType.trim().isNotEmpty;
  bool get isOtherBusinessType => _state.businessType == CompanyBusinessTypeCodes.other;

  // ===== Validações =====
  bool get _companyOk => companyController.text.trim().isNotEmpty;

  bool get _fantasyOk {
    if (!useFantasyName) return true;
    return fantasyNameController.text.trim().isNotEmpty;
  }

  bool get _ownerOk {
    if (!useOwner) return true;
    return ownerController.text.trim().isNotEmpty;
  }

  bool get _phoneOk {
    if (!usePhone) return true;
    return phoneController.text.trim().isNotEmpty;
  }

  bool get _businessOk {
    if (!hasBusinessType) return false;
    if (!isOtherBusinessType) return true;
    return _state.customBusinessType.trim().isNotEmpty;
  }

  bool get _legalOk => acceptTerms && acceptPrivacy;

  /// ✅ botão só habilita com tudo certo
  bool get canFinish =>
      _companyOk && _fantasyOk && _ownerOk && _phoneOk && _businessOk && _legalOk;

  // ===== Mutations =====
  void _update(CompanyState newState) {
    _state = newState;
    notifyListeners();
  }

  void _onFieldsChanged() {
    notifyListeners();
  }

  void _onCustomBusinessChanged() {
    final raw = customBusinessTypeController.text;

    // sem espaços duplos
    final fixed = raw.replaceAll(RegExp(r'\s{2,}'), ' ').trimLeft();

    // limite 20 chars
    final limited = fixed.length > 20 ? fixed.substring(0, 20) : fixed;

    if (limited != raw) {
      customBusinessTypeController.value =
          customBusinessTypeController.value.copyWith(
        text: limited,
        selection: TextSelection.collapsed(offset: limited.length),
      );
    }

    if (limited != _state.customBusinessType) {
      _update(_state.copyWith(customBusinessType: limited));
    } else {
      notifyListeners();
    }
  }

  void setBusinessType(String value) {
    if (value == _state.businessType) return;

    if (value != CompanyBusinessTypeCodes.other) {
      customBusinessTypeController.clear();
      _update(_state.copyWith(businessType: value, customBusinessType: ''));
      return;
    }

    _update(_state.copyWith(businessType: value));
  }

  void setUseFantasyName(bool value) {
    if (value == _state.useFantasyName) return;

    if (!value) fantasyNameController.clear();

    _update(_state.copyWith(useFantasyName: value));
  }

  void setUseOwner(bool value) {
    if (value == _state.useOwner) return;

    if (!value) ownerController.clear();

    _update(_state.copyWith(useOwner: value));
  }

  void setUsePhone(bool value) {
    if (value == _state.usePhone) return;

    if (!value) phoneController.clear();

    _update(_state.copyWith(usePhone: value));
  }

  void setAcceptTerms(bool value) {
    if (value == _state.acceptTerms) return;
    _update(_state.copyWith(acceptTerms: value));
  }

  void setAcceptPrivacy(bool value) {
    if (value == _state.acceptPrivacy) return;
    _update(_state.copyWith(acceptPrivacy: value));
  }

  void setError(String? value) {
    _update(_state.copyWith(error: value));
  }

  void clearError() {
    _update(_state.copyWith(clearError: true));
  }

  void _setLoading(bool value) {
    _update(_state.copyWith(isLoading: value));
  }

  // ===== Save onboarding =====
  Future<bool> finish({
    required User user,
    required AppLocalizations l10n,
  }) async {
    final company = companyController.text.trim();

    if (company.isEmpty) {
      setError(l10n.companyErrorCompanyRequired);
      return false;
    }

    if (!hasBusinessType) {
      setError(l10n.companyErrorBusinessTypeRequired);
      return false;
    }

    if (isOtherBusinessType && customBusinessType.trim().isEmpty) {
      setError(l10n.companyErrorOtherBusinessTypeRequired);
      return false;
    }

    if (useFantasyName && fantasyNameController.text.trim().isEmpty) {
      setError(l10n.companyErrorFantasyRequired);
      return false;
    }

    if (useOwner && ownerController.text.trim().isEmpty) {
      setError(l10n.companyErrorOwnerRequired);
      return false;
    }

    if (usePhone && phoneController.text.trim().isEmpty) {
      setError(l10n.companyErrorPhoneRequired);
      return false;
    }

    if (!acceptTerms || !acceptPrivacy) {
      setError(l10n.companyErrorAcceptLegal);
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      final fantasyName = fantasyNameController.text.trim();
      final owner = ownerController.text.trim();
      final phone = phoneController.text.trim();

      final businessToSave = isOtherBusinessType
          ? customBusinessType.trim()
          : businessType;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'company': company,
        'fantasyName': useFantasyName ? fantasyName : null,
        'owner': useOwner ? owner : null,
        'phone': usePhone ? phone : null,
        'businessType': businessToSave, // ✅ agora salva code/valor estável
        'active': true,
        'plan': 'Grátis',
        'onboardingCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
        'acceptedTerms': acceptTerms,
        'acceptedPrivacy': acceptPrivacy,
      }, SetOptions(merge: true));

      return true;
    } catch (_) {
      setError(l10n.companyErrorSaveFailed);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    companyController.removeListener(_onFieldsChanged);
    fantasyNameController.removeListener(_onFieldsChanged);
    ownerController.removeListener(_onFieldsChanged);
    phoneController.removeListener(_onFieldsChanged);
    customBusinessTypeController.removeListener(_onCustomBusinessChanged);

    companyController.dispose();
    fantasyNameController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    customBusinessTypeController.dispose();
    super.dispose();
  }
}
