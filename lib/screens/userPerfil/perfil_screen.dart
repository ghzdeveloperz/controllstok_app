// lib/screens/userPerfil/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_navigator.dart';
import '../../l10n/app_localizations.dart';

import '../acounts/auth_choice/auth_choice_screen.dart';
import 'config_options/config_screen.dart';

import 'state/perfil_controller.dart';
import 'widgets/perfil_loading_skeleton.dart';
import 'widgets/perfil_error_state.dart';
import 'widgets/perfil_empty_state.dart';
import 'widgets/perfil_header.dart';
import 'widgets/perfil_account_info_section.dart';
import 'widgets/perfil_security_section.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(perfilControllerProvider);
    final controller = ref.read(perfilControllerProvider.notifier);

    if (state.isLoading) return const PerfilLoadingSkeleton();
    if (state.errorMessage != null) {
      return PerfilErrorState(
        message: l10n.profileLoadErrorWithValue(state.errorMessage!),
        onRetry: controller.load,
      );
    }
    if (state.user == null)
      return PerfilEmptyState(message: l10n.profileNoUser);

    final user = state.user!;
    final displayName = _resolveDisplayName(
      companyName: state.companyName,
      email: user.email,
      fallback: l10n.profileUserFallback,
    );

    final email = user.email ?? l10n.profileNoEmail;
    final uid = user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.profileTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            tooltip: l10n.profileOpenSettings,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ConfigScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PerfilHeader(
                displayName: displayName,
                email: email,
                photoUrl: state.photoUrl,
                planRaw: state.plan,
                isUploadingAvatar: state.isUploadingAvatar,
                onEditCompany: () => _showEditCompanyDialog(
                  context: context,
                  l10n: l10n,
                  initialValue: state.companyName ?? '',
                  onSave: controller.updateCompanyName,
                ),
                onPickAvatar: () async {
                  final url = await controller.pickAndUploadAvatar();
                  final currentState = ref.read(perfilControllerProvider);
                  if (url != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.profileAvatarUpdated),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  } else if (currentState.errorMessage != null &&
                      context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.profileAvatarUpdateError),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
              PerfilAccountInfoSection(
                email: email,
                uid: uid,
                creationTime: user.metadata.creationTime,
                lastSignInTime: user.metadata.lastSignInTime,
                onCopy: (text, label) {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.profileCopiedWithValue(label)),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              PerfilSecuritySection(
                onSignOut: () => _showConfirmationDialog(
                  context: context,
                  title: l10n.profileSignOutTitle,
                  message: l10n.profileSignOutConfirm,
                  cancelText: l10n.actionCancel,
                  confirmText: l10n.profileSignOutButton,
                  onConfirm: () async {
                    await controller.signOut();
                    AppNavigator.resetTo(const AuthChoiceScreen());
                  },
                ),
                onDeactivate: () => _showDeactivateAccountDialog(
                  context: context,
                  l10n: l10n,
                  onConfirm: (password) async {
                    try {
                      await controller.deactivateAccount(password: password);
                      AppNavigator.resetTo(const AuthChoiceScreen());
                    } on Exception catch (e) {
                      // mapeamento simples: você pode evoluir depois
                      final msg = _mapDeactivateError(l10n, e);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: Colors.black87,
                          ),
                        );
                      }
                      rethrow;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _resolveDisplayName({
    required String? companyName,
    required String? email,
    required String fallback,
  }) {
    if (companyName != null && companyName.trim().isNotEmpty) {
      return companyName.trim();
    }
    if (email != null && email.isNotEmpty && email.contains('@')) {
      return email.split('@').first;
    }
    return fallback;
  }

  static String _mapDeactivateError(AppLocalizations l10n, Object e) {
    final msg = e.toString();
    if (msg.contains('wrong-password')) return l10n.profileWrongPassword;
    if (msg.contains('no-email')) return l10n.profileNoEmailError;
    if (msg.contains('no-user')) return l10n.profileNoUser;
    return l10n.profileDeactivateGenericError;
  }
}

void _showEditCompanyDialog({
  required BuildContext context,
  required AppLocalizations l10n,
  required String initialValue,
  required Future<void> Function(String) onSave,
}) {
  final controller = TextEditingController(text: initialValue);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.profileEditCompanyTitle,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: l10n.profileCompanyNameLabel,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final newName = controller.text.trim();
            if (newName.isEmpty) return;
            await onSave(newName);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(
            l10n.actionSave,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

void _showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String cancelText,
  required String confirmText,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(confirmText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _showDeactivateAccountDialog({
  required BuildContext context,
  required AppLocalizations l10n,
  required Future<void> Function(String password) onConfirm,
}) {
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorText;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.profileDeactivateTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.profileDeactivateHint),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.profilePasswordLabel,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  errorText: errorText,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return l10n.profilePasswordRequired;
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;

                    setState(() {
                      isLoading = true;
                      errorText = null;
                    });

                    try {
                      await onConfirm(passwordController.text);
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (_) {
                      // erro já tratado via snackbar (mas deixamos espaço pra erro inline)
                      setState(() => isLoading = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    l10n.profileDeactivateButton,
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    ),
  );
}
