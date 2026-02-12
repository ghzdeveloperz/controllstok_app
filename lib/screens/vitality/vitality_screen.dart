// lib/screens/vitality/vitality_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'providers/stock_value_providers.dart';
import 'ui/total_value_card.dart';

class VitalityScreen extends ConsumerWidget {
  final String uid;

  const VitalityScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mantive o l10n porque você vai usar depois (i18n real).
    final l10n = AppLocalizations.of(context)!;

    final totalValueAsync = ref.watch(stockTotalValueProvider(uid));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.auto_graph_rounded, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vida Útil',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Um resumo rápido do valor estimado do seu estoque.',
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: Colors.black.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 18),

            totalValueAsync.when(
              data: (value) => TotalValueCard(
                title: 'Saldo total',
                subtitle: 'Valor total estimado do estoque',
                value: value,
              ),
              loading: () => const TotalValueCard.loading(
                title: 'Saldo total',
                subtitle: 'Valor total estimado do estoque',
              ),
              error: (e, _) => TotalValueCard.error(
                title: 'Saldo total',
                // ✅ sem depender de uma key que não existe no teu l10n
                subtitle: 'Ocorreu um erro',
                message: e.toString(),
              ),
            ),

            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Em breve: indicadores e saúde do estoque.\n(Placeholder)',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
