// lib/screens/widgets/product_card/product_card_formatters.dart
import '../../../l10n/app_localizations.dart';
import 'product_status.dart';

class ProductCardFormatters {
  const ProductCardFormatters();

  String statusLabel(AppLocalizations l10n, ProductStockStatus status) {
    switch (status) {
      case ProductStockStatus.unavailable:
        return l10n.productStatusUnavailable;
      case ProductStockStatus.critical:
        return l10n.productStatusCritical;
      case ProductStockStatus.available:
        return l10n.productStatusAvailable;
    }
  }

  String stockLabel(AppLocalizations l10n, int quantity) {
    return l10n.productStockWithValue(quantity);
  }

  String currency(AppLocalizations l10n, double value) {
    // ✅ por enquanto usa sua string i18n (simples e consistente)
    // 🔥 futuro: trocar por NumberFormat.currency(locale: ...) sem mudar UI
    return l10n.currencyValue(value);
  }
}
