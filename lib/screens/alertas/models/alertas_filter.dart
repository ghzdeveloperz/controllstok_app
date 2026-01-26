// lib/screens/alertas/models/alertas_filter.dart
enum AlertasFilter {
  all,
  zero,
  critical,
}

extension AlertasFilterX on AlertasFilter {
  String toKey() {
    switch (this) {
      case AlertasFilter.all:
        return 'all';
      case AlertasFilter.zero:
        return 'zero';
      case AlertasFilter.critical:
        return 'critical';
    }
  }

  static AlertasFilter fromKey(String key) {
    switch (key) {
      case 'zero':
        return AlertasFilter.zero;
      case 'critical':
        return AlertasFilter.critical;
      case 'all':
      default:
        return AlertasFilter.all;
    }
  }
}
