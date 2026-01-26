import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const int estoqueIndex = 0;
  static const int newProductIndex = 1;
  static const int scannerIndex = 2;
  static const int reportsIndex = 3;
  static const int alertsIndex = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SizedBox(
        // 🔽 ALTURA TOTAL (mantida como a versão compacta)
        // 👉 Se ainda quiser uma folguinha sem “engordar” muito: 85/86
        height: 84,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _NavItem(
                    index: estoqueIndex,
                    currentIndex: currentIndex,
                    icon: Icons.inventory_2_outlined,
                    label: l10n.homeTabStock,
                    onTap: onTap,
                  ),
                  _NavItem(
                    index: newProductIndex,
                    currentIndex: currentIndex,
                    icon: Icons.add_business_outlined,
                    label: l10n.homeTabNew,
                    onTap: onTap,
                  ),

                  // ✅ Scanner destacado (mas agora sem estourar pra baixo)
                  Transform.translate(
                    offset: const Offset(0, -1),
                    child: _ScannerItem(
                      isActive: currentIndex == scannerIndex,
                      label: l10n.homeTabScanner,
                      onTap: () => onTap(scannerIndex),
                    ),
                  ),

                  _NavItem(
                    index: reportsIndex,
                    currentIndex: currentIndex,
                    icon: Icons.bar_chart,
                    label: l10n.homeTabReports,
                    onTap: onTap,
                  ),
                  _NavItem(
                    index: alertsIndex,
                    currentIndex: currentIndex,
                    icon: Icons.notifications,
                    label: l10n.homeTabAlerts,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final String label;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;
    final activeColor = Colors.black;
    final inactiveColor = Colors.grey.shade400;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(0, isActive ? -2 : 0, 0),
              child: Icon(
                icon,
                size: 24,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 14 : 0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerItem extends StatelessWidget {
  final bool isActive;
  final String label;
  final VoidCallback onTap;

  const _ScannerItem({
    required this.isActive,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.black;
    final inactiveColor = Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // ✅ Ajuste principal: tira “sobrinha” de baixo
        // Antes era (horizontal: 6, vertical: 2)
        // 👇 Se ainda precisar de +1px, deixe vertical: 0
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 26,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
            ),

            // ✅ Aqui estava “comendo” altura e estourando 3px no fim
            // Antes: SizedBox(height: 4)
            const SizedBox(height: 2), // <-- ajuste manual: 1 / 0

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              // ✅ Barra um tiquinho menor pra caber certinho
              // Antes: 3
              height: 2.5, // <-- ajuste manual: 2 / 2.5 / 3
              width: isActive ? 14 : 0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
