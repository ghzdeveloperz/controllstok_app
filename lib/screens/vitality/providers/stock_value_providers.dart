// lib/screens/vitality/providers/stock_value_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/stock_value_repository.dart';

final stockValueRepositoryProvider = Provider<StockValueRepository>((ref) {
  return const StockValueRepository();
});

/// Total estimado do estoque (somando todos os produtos do user).
/// Retorna double (ex: 12345.67).
final stockTotalValueProvider = StreamProvider.family<double, String>(
  (ref, uid) {
    final repo = ref.watch(stockValueRepositoryProvider);
    return repo.watchTotalStockValue(uid: uid);
  },
);
