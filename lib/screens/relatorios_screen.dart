// import 'package:mystoreday/screens/relatorios_months.dart'; // Comentado pois não será usado
// import 'package:mystoreday/screens/relatorios_years.dart'; // Comentado pois não será usado
import 'package:flutter/material.dart';
import 'dart:ui'; // Para BackdropFilter
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';

import 'widgets/relatorios/days/relatorios_days.dart';

/// =======================
/// ENUM DE PERÍODO
/// =======================
// enum PeriodType { daily, monthly, yearly } // Comentado para focar apenas em daily
enum PeriodType { daily } // Apenas daily para simplificar

/// =======================
/// TELA DE RELATÓRIOS
/// =======================
class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen>
    with TickerProviderStateMixin {
  PeriodType _selectedPeriod = PeriodType.daily; // Sempre daily
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            /// ---------- HEADER PREMIUM COM GLASSMORPHISM ----------
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.9),
                        Colors.white.withValues(alpha: 0.7),
                        Colors.grey.shade50.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reportsTitle,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 28,
                          color: Colors.black87,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// ---------- SELETOR DE PERÍODO PREMIUM (AGORA APENAS "DIA") ----------
                      _PeriodSelector(
                        selected: _selectedPeriod,
                        onChange: (value) {
                          // Não faz nada, pois sempre é daily
                          // (mantém a assinatura para quando você reativar Month/Year)
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 2),

            /// ---------- CONTEÚDO COM ANIMAÇÃO ----------
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// RENDERIZA POR PERÍODO (APENAS DAILY)
  /// =======================
  Widget _buildContent() {
    switch (_selectedPeriod) {
      case PeriodType.daily:
        return _buildDailyView();
      // case PeriodType.monthly: // Comentado
      //   return _buildMonthlyView();
      // case PeriodType.yearly: // Comentado
      //   return _buildYearlyView();
    }
  }

  /// =======================
  /// VIEWS ESTILIZADAS (GRÁFICOS PLACEHOLDER)
  /// =======================
  Widget _buildDailyView() {
    return const RelatoriosDays();
  }

  // Widget _buildMonthlyView() { // Comentado
  //   return const RelatoriosMonths();
  // }

  // Widget _buildYearlyView() { // Comentado
  //   return const RelatoriosYears();
  // }
}

/// =======================
/// SELETOR PREMIUM COM ANIMAÇÃO (AGORA APENAS "DIA")
/// =======================
class _PeriodSelector extends StatefulWidget {
  final PeriodType selected;
  final ValueChanged<PeriodType> onChange;

  const _PeriodSelector({required this.selected, required this.onChange});

  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade200.withValues(alpha: 0.8),
                Colors.grey.shade300.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildItem(l10n.reportsPeriodDay, PeriodType.daily),
              // _buildItem(l10n.reportsPeriodMonth, PeriodType.monthly), // Comentado
              // _buildItem(l10n.reportsPeriodYear, PeriodType.yearly), // Comentado
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(String label, PeriodType value) {
    final isSelected = widget.selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onChange(
          value,
        ), // Mesmo que não mude, mantém para consistência
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.grey.shade100.withValues(alpha: 0.7),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isSelected ? Colors.black : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
