// lib/screens/userPerfil/widgets/perfil_header.dart
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'perfil_plan_chip.dart';

class PerfilHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? planRaw;
  final bool isUploadingAvatar;

  final VoidCallback onEditCompany;
  final Future<void> Function() onPickAvatar;

  const PerfilHeader({
    super.key,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.planRaw,
    required this.isUploadingAvatar,
    required this.onEditCompany,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black,
                backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!)
                    : null,
                child: (photoUrl == null || photoUrl!.isEmpty)
                    ? Text(
                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              InkWell(
                onTap: isUploadingAvatar ? null : () async => onPickAvatar(),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isUploadingAvatar
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt, size: 18, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  right: 60,
                  child: IconButton(
                    onPressed: onEditCompany,
                    icon: const Icon(Icons.edit, size: 20, color: Colors.black54),
                    tooltip: l10n.profileEditCompanyTitle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),

          PerfilPlanChip(planRaw: planRaw),
        ],
      ),
    );
  }
}
