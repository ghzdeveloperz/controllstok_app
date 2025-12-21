import 'package:flutter/material.dart';

/// =======================
/// ENUM DE PERÍODO
/// =======================
enum PeriodType {
  daily,
  monthly,
  yearly,
}

/// =======================
/// TELA DE RELATÓRIOS
/// =======================
class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  PeriodType _selectedPeriod = PeriodType.daily;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            /// ---------- HEADER CLARO ----------
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Relatórios',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// ---------- SELETOR DE PERÍODO ----------
                  _PeriodSelector(
                    selected: _selectedPeriod,
                    onChange: (value) {
                      setState(() => _selectedPeriod = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ---------- CONTEÚDO ----------
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// RENDERIZA POR PERÍODO
  /// =======================
  Widget _buildContent() {
    switch (_selectedPeriod) {
      case PeriodType.daily:
        return _buildDailyView();
      case PeriodType.monthly:
        return _buildMonthlyView();
      case PeriodType.yearly:
        return _buildYearlyView();
    }
  }

  /// =======================
  /// PLACEHOLDERS (GRÁFICOS)
  /// =======================
  Widget _buildDailyView() {
    return const Center(
      child: Text(
        'Gráficos Diários',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildMonthlyView() {
    return const Center(
      child: Text(
        'Gráficos Mensais',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildYearlyView() {
    return const Center(
      child: Text(
        'Gráficos Anuais',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

/// =======================
/// SELETOR PREMIUM
/// =======================
class _PeriodSelector extends StatelessWidget {
  final PeriodType selected;
  final ValueChanged<PeriodType> onChange;

  const _PeriodSelector({
    required this.selected,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildItem('Dia', PeriodType.daily),
          _buildItem('Mês', PeriodType.monthly),
          _buildItem('Ano', PeriodType.yearly),
        ],
      ),
    );
  }

  Widget _buildItem(String label, PeriodType value) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
