// lib/screens/vitality/ui/total_value_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalValueCard extends StatelessWidget {
  final String title;
  final String subtitle;

  final double? value;
  final bool isLoading;

  final bool isError;
  final String? message;

  const TotalValueCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
  })  : isLoading = false,
        isError = false,
        message = null;

  const TotalValueCard.loading({
    super.key,
    required this.title,
    required this.subtitle,
  })  : value = null,
        isLoading = true,
        isError = false,
        message = null;

  const TotalValueCard.error({
    super.key,
    required this.title,
    required this.subtitle,
    required this.message,
  })  : value = null,
        isLoading = false,
        isError = true;

  @override
  Widget build(BuildContext context) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    final formatted = NumberFormat.simpleCurrency(
      locale: localeTag,
      // se o device for pt-BR, o símbolo vira R$ automaticamente
    ).format(value ?? 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna esquerda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLoading
                      ? 'Carregando...'
                      : isError
                          ? 'Erro'
                          : formatted,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isError && (message ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    message!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Badge / ícone
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Icon(
              isError
                  ? Icons.error_outline_rounded
                  : isLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
