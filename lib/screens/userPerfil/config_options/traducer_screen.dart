import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Mesma key do LocaleStore (só para ler e marcar o selecionado ao abrir)
const _kLocaleOverrideKey = 'locale_override';

class TraducerScreen extends StatefulWidget {
  const TraducerScreen({super.key});

  @override
  State<TraducerScreen> createState() => _TraducerScreenState();
}

class _TraducerScreenState extends State<TraducerScreen> {
  String? _selectedLocale; // null = sistema
  bool _loading = true;

  String _query = '';
  final _searchController = TextEditingController();

  // Paleta premium (preto/branco)
  static const Color _bg = Color(0xFFF6F7F8);
  static const Color _surface = Colors.white;
  static const Color _ink = Color(0xFF0B0F14);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE7E9EE);

  final List<_LocaleOption> _options = const [
    _LocaleOption(
      title: 'Português (Brasil)',
      localeCode: 'pt',
      flag: '🇧🇷',
    ),
    _LocaleOption(
      title: 'Português (Portugal)',
      localeCode: 'pt_PT',
      flag: '🇵🇹',
    ),
    _LocaleOption(
      title: 'English',
      localeCode: 'en',
      flag: '🇺🇸',
    ),
    _LocaleOption(
      title: 'Español',
      localeCode: 'es',
      flag: '🇪🇸',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
    _searchController.addListener(() {
      final v = _searchController.text.trim().toLowerCase();
      if (v == _query) return;
      setState(() => _query = v);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleOverrideKey);

    if (!mounted) return;
    setState(() {
      _selectedLocale = (saved == null || saved.trim().isEmpty) ? null : saved;
      _loading = false;
    });
  }

  Future<void> _setLocale(String? localeCode) async {
    Locale? locale;
    if (localeCode == null) {
      locale = null; // sistema
    } else {
      final parts = localeCode.split(RegExp('[_-]'));
      final lang = parts[0];
      final country = parts.length > 1 ? parts[1] : null;
      locale = Locale(lang, country);
    }

    await LocaleController.set(locale);

    if (!mounted) return;
    setState(() => _selectedLocale = localeCode);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  List<_LocaleOption> get _filteredOptions {
    if (_query.isEmpty) return _options;
    return _options.where((o) {
      final hay = '${o.title} ${o.localeCode}'.toLowerCase();
      return hay.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final title = l10n?.languageTitle ?? 'Idioma';
    final systemTitle = l10n?.languageSystem ?? 'Idioma do sistema';
    final systemDesc = l10n?.languageSystemDescription ??
        'Usar o idioma do seu dispositivo automaticamente';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: _ink,
            letterSpacing: -0.2,
          ),
        ),
        iconTheme: const IconThemeData(color: _ink),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          children: [
            _SearchField(
              controller: _searchController,
              hintText: l10n?.searchLanguageHint ?? 'Buscar idioma...',
            ),
            const SizedBox(height: 14),

            _SectionLabel(text: l10n?.languageSectionPreferences ?? 'Preferências'),

            const SizedBox(height: 10),

            _LanguageCard(
              title: systemTitle,
              subtitle: systemDesc,
              leading: const _FlagCircle(text: '🌐'),
              selected: _selectedLocale == null,
              onTap: () => _setLocale(null),
            ),

            const SizedBox(height: 14),

            _SectionLabel(text: l10n?.languageSectionAvailable ?? 'Idiomas disponíveis'),
            const SizedBox(height: 10),

            ..._filteredOptions.map((opt) {
              final selected = _selectedLocale == opt.localeCode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LanguageCard(
                  title: opt.title,
                  subtitle: '', // não mostra código mais
                  leading: _FlagCircle(text: opt.flag),
                  trailingText: selected ? (l10n?.selectedLabel ?? 'Selecionado') : null,
                  selected: selected,
                  onTap: () => _setLocale(opt.localeCode),
                ),
              );
            }),

            if (_filteredOptions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Center(
                  child: Text(
                    l10n?.noLanguageFound ?? 'Nenhum idioma encontrado',
                    style: GoogleFonts.poppins(
                      color: _muted,
                      fontWeight: FontWeight.w600,
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

class _LocaleOption {
  final String title;
  final String localeCode;
  final String flag;

  const _LocaleOption({
    required this.title,
    required this.localeCode,
    required this.flag,
  });
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  static const Color _muted = Color(0xFF6B7280);
  static const Color _ink = Color(0xFF0B0F14);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _ink.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _muted,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _SearchField({
    required this.controller,
    required this.hintText,
  });

  static const Color _surface = Colors.white;
  static const Color _ink = Color(0xFF0B0F14);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14.5,
            color: _muted,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: _muted.withOpacity(0.9)),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => controller.clear(),
                icon: Icon(Icons.close_rounded, color: _muted.withOpacity(0.9)),
                tooltip: 'Limpar',
              );
            },
          ),
          filled: true,
          fillColor: _surface,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;
  final String? trailingText;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
    this.trailingText,
  });

  static const Color _surface = Colors.white;
  static const Color _ink = Color(0xFF0B0F14);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? _ink : _border;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: _ink.withOpacity(0.06),
        highlightColor: _ink.withOpacity(0.04),
        child: Ink(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 1.6 : 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13.2,
                            fontWeight: FontWeight.w500,
                            color: _muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (trailingText != null && selected) ...[
                  Text(
                    trailingText!,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _ink.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                _SelectPill(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlagCircle extends StatelessWidget {
  final String text;
  const _FlagCircle({required this.text});

  static const Color _ink = Color(0xFF0B0F14);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _ink,
        ),
      ),
    );
  }
}

class _SelectPill extends StatelessWidget {
  final bool selected;
  const _SelectPill({required this.selected});

  static const Color _ink = Color(0xFF0B0F14);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: selected ? _ink : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? _ink : _border, width: 1.2),
      ),
      child: Icon(
        Icons.check_rounded,
        size: 18,
        color: selected ? Colors.white : Colors.transparent,
      ),
    );
  }
}
