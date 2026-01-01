import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';

import '../../export/days/export_excel_days.dart';
import '../../firebase/firestore/movements_days.dart';

class SalveModal extends StatefulWidget {
  final List<DateTime> days;
  final String uid;
  final List<Movement> movements;

  const SalveModal({
    super.key,
    required this.days,
    required this.uid,
    required this.movements,
  });

  static Future<void> show(
    BuildContext context, {
    required List<DateTime> days,
    required String uid,
    required List<Movement> movements,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (context, _, _) => SalveModal(
        days: days,
        uid: uid,
        movements: movements,
      ),
      transitionBuilder: (context, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<SalveModal> createState() => _SalveModalState();
}

class _SalveModalState extends State<SalveModal>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  /// ✅ EXPORTA E ABRE CORRETAMENTE
  Future<void> _exportExcelAndOpen(BuildContext rootContext) async {
    final messenger = ScaffoldMessenger.of(rootContext);

    if (widget.movements.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não há dados para exportar')),
      );
      return;
    }

    final days = widget.days.isNotEmpty
        ? widget.days.map(_normalize).toSet().toList()
        : widget.movements
            .map((m) => _normalize(m.timestamp))
            .toSet()
            .toList()
      ..sort();

    try {
      final file = await ExportExcelDays.export(
        days: days,
        uid: widget.uid,
        movements: widget.movements,
      );

      // ⏳ pequeno delay para o Android reassumir foco
      await Future.delayed(const Duration(milliseconds: 300));

      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Arquivo salvo em:\n${file.path}',
            ),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Excel aberto com sucesso!')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao exportar Excel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootContext = context;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _iconController,
              builder: (_, __) => Transform.rotate(
                angle: (_iconController.value - 0.5) * 0.2,
                child: const Icon(
                  Icons.save_alt,
                  size: 44,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Salvar Relatório',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),

            _UltraPremiumOptionButton(
              label: 'Exportar como Excel',
              icon: Icons.grid_on,
              gradientColors: const [
                Color(0xFF28A745),
                Color(0xFF20C997),
              ],
              onTap: () {
                HapticFeedback.heavyImpact();
                Navigator.of(context).pop();

                // 🔥 exporta FORA do modal
                _exportExcelAndOpen(rootContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ========================================================= */

class _UltraPremiumOptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _UltraPremiumOptionButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}
