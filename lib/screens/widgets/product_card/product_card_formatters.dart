// lib/screens/widgets/product_card/product_card_formatters.dart
import 'package:intl/intl.dart';

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
    // ✅ moeda automática pelo locale + sempre 2 casas decimais
    final f = NumberFormat.simpleCurrency(
      locale: l10n.localeName,
      decimalDigits: 2,
    );
    return f.format(value);
  }
}
