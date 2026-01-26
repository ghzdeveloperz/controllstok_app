// lib/screens/userPerfil/widgets/perfil_account_info_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import 'perfil_info_row.dart';

class PerfilAccountInfoSection extends StatelessWidget {
  final String email;
  final String uid;
  final DateTime? creationTime;
  final DateTime? lastSignInTime;

  final void Function(String text, String label) onCopy;

  const PerfilAccountInfoSection({
    super.key,
    required this.email,
    required this.uid,
    required this.creationTime,
    required this.lastSignInTime,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final createdLocal = creationTime?.toLocal();
    final lastLoginLocal = lastSignInTime?.toLocal();

    // 🔧 Se quiser deixar 100% por locale depois: use l10n.localeName aqui.
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return _CardSection(
      title: l10n.profileAccountInfoTitle,
      children: [
        PerfilInfoRow(icon: Icons.email, label: l10n.profileEmailLabel, value: email),
        const Divider(height: 20),
        PerfilInfoRow(
          icon: Icons.key,
          label: l10n.profileUidLabel,
          value: uid,
          isCopyable: true,
          onCopy: () => onCopy(uid, l10n.profileUidLabel),
        ),
        const Divider(height: 20),
        PerfilInfoRow(
          icon: Icons.calendar_today,
          label: l10n.profileCreatedAtLabel,
          value: createdLocal != null ? fmt.format(createdLocal) : l10n.commonNotAvailable,
        ),
        const Divider(height: 20),
        PerfilInfoRow(
          icon: Icons.access_time,
          label: l10n.profileLastLoginLabel,
          value: lastLoginLocal != null ? fmt.format(lastLoginLocal) : l10n.commonNotAvailable,
        ),
      ],
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CardSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ]),
    );
  }
}
