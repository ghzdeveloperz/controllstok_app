// lib/screens/widgets/relatorios/days/charts/pie_chart_section.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../firebase/firestore/movements_days.dart';

typedef PieTouchPayload = ({
  int index,
  String productId,
  String? imageUrl,
  String label,
});

class PieChartSection extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final Map<String, List<Movement>> grouped;

  /// 'all' | 'add' | 'remove'
  final String percentualMode;

  /// Estado controlado pelo pai
  final int touchedIndex;
  final String? touchedImageUrl;

  /// Callbacks para o pai controlar o estado do toque
  final ValueChanged<PieTouchPayload> onTouch;
  final VoidCallback onClearTouch;

  const PieChartSection({
    super.key,
    required this.sections,
    required this.grouped,
    required this.percentualMode,
    required this.touchedIndex,
    required this.touchedImageUrl,
    required this.onTouch,
    required this.onClearTouch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final modeLabel = percentualMode == 'add'
        ? l10n.relatoriosEntries
        : percentualMode == 'remove'
            ? l10n.relatoriosExits
            : l10n.relatoriosAll;

    // ✅ Se seu método gerado estiver como named placeholder, use a linha comentada:
    // final title = l10n.relatoriosPieTitle(modeLabel: modeLabel);

    final title = l10n.relatoriosPieTitle(modeLabel);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 48,
                  sectionsSpace: 3,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      // toque fora / sem seção tocada -> limpa
                      if (!event.isInterestedForInteractions ||
                          response?.touchedSection == null) {
                        onClearTouch();
                        return;
                      }

                      final index = response!.touchedSection!.touchedSectionIndex;

                      // proteção extra: índice inválido
                      if (index < 0 ||
                          index >= sections.length ||
                          index >= grouped.length) {
                        onClearTouch();
                        return;
                      }

                      // ⚠️ IMPORTANTE:
                      // a ordem de grouped.keys precisa ser a mesma usada ao criar "sections".
                      // Você comentou isso aí, então vamos manter consistente.
                      final productId = grouped.keys.elementAt(index);

                      final list = grouped[productId];
                      if (list == null || list.isEmpty) {
                        onClearTouch();
                        return;
                      }

                      final product = list.first;

                      onTouch((
                        index: index,
                        productId: productId,
                        imageUrl: product.image,
                        label: product.productName,
                      ));
                    },
                  ),
                  sections: sections.asMap().entries.map((entry) {
                    final index = entry.key;
                    final section = entry.value;
                    final isTouched = index == touchedIndex;

                    return section.copyWith(
                      radius: isTouched ? 68 : 56,
                      titleStyle: section.titleStyle?.copyWith(
                        fontSize: isTouched ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 🖼️ Imagem no canto inferior esquerdo (controlada pelo pai)
              if (touchedImageUrl != null && touchedImageUrl!.isNotEmpty)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(touchedImageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;

            if (index >= grouped.length) return const SizedBox.shrink();

            final productId = grouped.keys.elementAt(index);
            final list = grouped[productId];
            if (list == null || list.isEmpty) return const SizedBox.shrink();

            final product = list.first;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: section.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
