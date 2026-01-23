class LocaleOption {
  final String title;
  final String subtitle;
  final String code; // 'pt', 'pt_PT', 'en', 'es'
  final String flag; // emoji
  final List<String> searchTags;

  const LocaleOption({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.flag,
    this.searchTags = const [],
  });
}
