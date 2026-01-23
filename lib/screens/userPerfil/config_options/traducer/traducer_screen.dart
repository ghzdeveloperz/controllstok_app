import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/locale_controller.dart';
import '../../../../core/locale_store.dart';
import '../../../../l10n/app_localizations.dart';

import 'data/locale_option.dart';
import 'data/locale_options.dart';

import 'widgets/confirm_locale_dialog.dart';
import 'widgets/language_card.dart';
import 'widgets/search_field.dart';
import 'widgets/section_label.dart';
import 'widgets/flag_circle.dart';

class TraducerScreen extends StatefulWidget {
  const TraducerScreen({super.key});

  @override
  State<TraducerScreen> createState() => _TraducerScreenState();
}

class _TraducerScreenState extends State<TraducerScreen> {
  bool _loading = true;

  /// Guarda o código no mesmo padrão do LocaleStore:
  /// null => sistema
  /// 'pt' | 'pt_PT' | 'en' | 'es'
  String? _selectedCode;

  String _query = '';
  final _searchController = TextEditingController();

  // Paleta premium (preto/branco)
  static const Color _bg = Color(0xFFF6F7F8);
  static const Color _surface = Colors.white;
  static const Color _ink = Color(0xFF0B0F14);
  static const Color _border = Color(0xFFE7E9EE);

  @override
  void initState() {
    super.initState();
    _bootstrap();

    _searchController.addListener(() {
      final v = _searchController.text.trim().toLowerCase();
      if (v == _query) return;
      setState(() => _query = v);
    });
  }

  Future<void> _bootstrap() async {
    // Lê do store (não do widget)
    final locale = await LocaleStore.load();
    final code = _localeToCode(locale);

    if (!mounted) return;
    setState(() {
      _selectedCode = code;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LocaleOption> get _filteredOptions {
    final all = kLocaleOptions;
    if (_query.isEmpty) return all;

    return all.where((o) {
      final hay = '${o.title} ${o.searchTags.join(" ")} ${o.code}'.toLowerCase();
      return hay.contains(_query);
    }).toList();
  }

  Locale? _codeToLocale(String? code) {
    if (code == null || code.trim().isEmpty) return null;

    final parts = code.split(RegExp('[_-]'));
    final lang = parts[0];
    final country = parts.length > 1 ? parts[1] : null;

    return Locale(lang, country);
  }

  String? _localeToCode(Locale? locale) {
    if (locale == null) return null;

    final cc = locale.countryCode;
    if (cc == null || cc.isEmpty) return locale.languageCode;

    return '${locale.languageCode}_$cc';
  }

  Future<void> _confirmAndSet(String? nextCode) async {
    // Se clicou no mesmo, não faz nada.
    if (nextCode == _selectedCode) return;

    final l10n = AppLocalizations.of(context);

    // final title = l10n?.languageTitle ?? 'Idioma';
    final confirmTitle = l10n?.languageConfirmTitle ?? 'Confirmar alteração';
    final confirmMsg = l10n?.languageConfirmMessage ??
        'Deseja aplicar este idioma agora? Você pode alterar novamente quando quiser.';
    final cancel = l10n?.cancel ?? 'Cancelar';
    final apply = l10n?.apply ?? 'Aplicar';

    final ok = await showConfirmLocaleDialog(
      context,
      title: confirmTitle,
      message: confirmMsg,
      cancelText: cancel,
      confirmText: apply,
    );

    if (ok != true) return;

    // Aplica imediatamente e persiste por dentro do controller/store.
    final locale = _codeToLocale(nextCode);
    await LocaleController.set(locale);

    if (!mounted) return;
    setState(() => _selectedCode = nextCode);

    // Volta para a tela anterior informando "true"
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pageTitle = l10n?.languageTitle ?? 'Idioma';

    final searchHint = l10n?.searchLanguageHint ?? 'Buscar idioma...';
    final sectionPrefs = l10n?.languageSectionPreferences ?? 'Preferências';
    final sectionAvailable = l10n?.languageSectionAvailable ?? 'Idiomas disponíveis';

    final systemTitle = l10n?.languageSystem ?? 'Idioma do sistema';
    final systemDesc = l10n?.languageSystemDescription ??
        'Usar o idioma do seu dispositivo automaticamente';

    final selectedLabel = l10n?.selectedLabel ?? 'Selecionado';
    final emptyText = l10n?.noLanguageFound ?? 'Nenhum idioma encontrado';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          pageTitle,
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
            SearchField(
              controller: _searchController,
              hintText: searchHint,
            ),
            const SizedBox(height: 14),

            SectionLabel(text: sectionPrefs),
            const SizedBox(height: 10),

            LanguageCard(
              title: systemTitle,
              subtitle: systemDesc,
              leading: const FlagCircle(text: '🌐'),
              selected: _selectedCode == null,
              trailingText: _selectedCode == null ? selectedLabel : null,
              onTap: () => _confirmAndSet(null),
            ),

            const SizedBox(height: 14),

            SectionLabel(text: sectionAvailable),
            const SizedBox(height: 10),

            ..._filteredOptions.map((opt) {
              final selected = _selectedCode == opt.code;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LanguageCard(
                  title: opt.title,
                  subtitle: opt.subtitle,
                  leading: FlagCircle(text: opt.flag),
                  selected: selected,
                  trailingText: selected ? selectedLabel : null,
                  onTap: () => _confirmAndSet(opt.code),
                ),
              );
            }),

            if (_filteredOptions.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Center(
                  child: Text(
                    emptyText,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6B7280),
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
