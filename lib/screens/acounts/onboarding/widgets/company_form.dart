// lib/screens/acounts/onboarding/widgets/company_form.dart
import 'package:flutter/material.dart';

import '../company_controller.dart';

// ✅ use os seus paths reais
import '../../../userPerfil/config_options/sobre_terms/terms_used.dart';
import '../../../userPerfil/config_options/sobre_terms/politic_privacity.dart';

class CompanyForm extends StatelessWidget {
  final CompanyController controller;
  final bool isLoading;
  final String? error;
  final Animation<double> animation;
  final VoidCallback onFinish;

  const CompanyForm({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.error,
    required this.animation,
    required this.onFinish,
  });

  InputDecoration _dec({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: Icon(icon, color: Colors.black54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _yesNoToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final yesSelected = value == true;
    final noSelected = value == false;

    Widget chip({
      required String text,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black12),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color.fromARGB(18, 0, 0, 0),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    )
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            chip(
              text: 'Não',
              selected: noSelected,
              onTap: () => onChanged(false),
            ),
            const SizedBox(width: 10),
            chip(
              text: 'Sim',
              selected: yesSelected,
              onTap: () => onChanged(true),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickBusinessType(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selecione o tipo de negócio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...controller.businessTypes.map((t) {
                  final active = t == controller.businessType;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      t,
                      style: TextStyle(
                        fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                    trailing: active
                        ? const Icon(Icons.check_rounded, color: Colors.black)
                        : null,
                    onTap: () => Navigator.pop(context, t),
                  );
                }),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) controller.setBusinessType(selected);
  }

  // ✅ MODAL CORRIGIDO (renderiza sua tela real dentro do bottom sheet)
  Future<void> _openLegalModal({
    required BuildContext context,
    required Widget page,
  }) async {
    final height = MediaQuery.of(context).size.height;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.white,
                child: SizedBox(
                  height: height * 0.92,
                  child: Stack(
                    children: [
                      Positioned.fill(child: page),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legalCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: isLoading ? null : onChanged,
            activeColor: Colors.black,
            checkColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            side: const BorderSide(color: Colors.black26, width: 1.2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 6,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.2,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: isLoading ? null : onLinkTap,
                  child: Text(
                    linkText,
                    style: const TextStyle(
                      fontSize: 13.2,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBusinessType = controller.businessType.trim().isNotEmpty;
    final isOther = controller.businessType == 'Outro';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // alerta animado
        SizeTransition(
          sizeFactor: animation,
          axisAlignment: -1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(15, 0, 0, 0),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Razão social (obrigatório)
        TextField(
          controller: controller.companyController,
          enabled: !isLoading,
          decoration: _dec(
            hint: "Razão social / nome da empresa",
            icon: Icons.business_outlined,
          ),
        ),
        const SizedBox(height: 18),

        // Nome fantasia (pergunta)
        _yesNoToggle(
          label: 'Sua empresa tem nome fantasia?',
          value: controller.useFantasyName,
          onChanged: isLoading ? (_) {} : controller.setUseFantasyName,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: controller.useFantasyName
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: controller.fantasyNameController,
                    enabled: !isLoading,
                    decoration: _dec(
                      hint: "Nome fantasia",
                      icon: Icons.storefront_outlined,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 18),

        // Responsável (pergunta)
        _yesNoToggle(
          label: 'Deseja informar um responsável?',
          value: controller.useOwner,
          onChanged: isLoading ? (_) {} : controller.setUseOwner,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: controller.useOwner
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: controller.ownerController,
                    enabled: !isLoading,
                    decoration: _dec(
                      hint: "Responsável",
                      icon: Icons.person_outline,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 18),

        // Telefone (pergunta)
        _yesNoToggle(
          label: 'Deseja informar telefone/WhatsApp?',
          value: controller.usePhone,
          onChanged: isLoading ? (_) {} : controller.setUsePhone,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: controller.usePhone
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: controller.phoneController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                    decoration: _dec(
                      hint: "Telefone / WhatsApp",
                      icon: Icons.phone_outlined,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 18),

        // Tipo de negócio (sem default)
        GestureDetector(
          onTap: isLoading ? null : () => _pickBusinessType(context),
          child: AbsorbPointer(
            child: TextField(
              enabled: !isLoading,
              decoration: _dec(
                hint: "Tipo de negócio",
                icon: Icons.category_outlined,
                suffix: const Icon(Icons.expand_more_rounded, color: Colors.black54),
              ).copyWith(
                hintText: hasBusinessType ? controller.businessType : "Tipo de negócio",
              ),
            ),
          ),
        ),

        // Se "Outro", campo custom obrigatório (até 20 chars)
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: isOther
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: controller.customBusinessTypeController,
                    enabled: !isLoading,
                    textInputAction: TextInputAction.done,
                    maxLength: 20,
                    decoration: _dec(
                      hint: "Descreva (até 20 caracteres)",
                      icon: Icons.edit_outlined,
                    ).copyWith(counterText: ""),
                    onChanged: (v) {
                      final fixed = v.replaceAll(RegExp(r'\s{2,}'), ' ');
                      if (fixed != v) {
                        controller.customBusinessTypeController.value =
                            controller.customBusinessTypeController.value.copyWith(
                          text: fixed,
                          selection: TextSelection.collapsed(offset: fixed.length),
                        );
                      }
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 22),

        // ✅ Checkboxes obrigatórios para finalizar
        _legalCheckbox(
          value: controller.acceptTerms,
          onChanged: (v) => controller.setAcceptTerms(v ?? false),
          label: "Eu li e concordo com os",
          linkText: "Termos de uso",
          onLinkTap: () {
            _openLegalModal(
              context: context,
              page: const TermsUsedScreen(),
            );
          },
        ),
        const SizedBox(height: 10),
        _legalCheckbox(
          value: controller.acceptPrivacy,
          onChanged: (v) => controller.setAcceptPrivacy(v ?? false),
          label: "Eu li e concordo com as",
          linkText: "Políticas de privacidade",
          onLinkTap: () {
            _openLegalModal(
              context: context,
              page: const PoliticPrivacityScreen(),
            );
          },
        ),

        const SizedBox(height: 26),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: controller.canFinish && !isLoading ? onFinish : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.black38,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text(
                    "Finalizar cadastro",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
