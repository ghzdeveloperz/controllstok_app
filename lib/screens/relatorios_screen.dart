import 'package:flutter/material.dart';
import '../services/session_service.dart';
import 'relatorios_days.dart';
import 'package:google_fonts/google_fonts.dart';
import 'relatorios_months.dart';
import 'relatorios_years.dart';

enum PeriodType { daily, monthly, yearly }

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  PeriodType _selectedPeriod = PeriodType.daily;
  bool _loading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final login = await SessionService.getUserLogin();
    if (login != null) {
      setState(() => _userId = login);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  // ================= HEADER =================
  Widget _buildHeader() {
    // Header da página Relatórios com período selecionável
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
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
          Text(
            'Relatórios', // título principal da página
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _PeriodSelector(
            // Widget customizado para selecionar período
            selected: _selectedPeriod,
            onChange: (value) {
              setState(() => _selectedPeriod = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userId == null) {
      return const Center(child: Text('Nenhum usuário logado.'));
    }

    switch (_selectedPeriod) {
      case PeriodType.daily:
        return RelatoriosDays(userId: _userId!);
      case PeriodType.monthly:
        return RelatoriosMonths(userId: _userId!);
      case PeriodType.yearly:
        return RelatoriosYears(userId: _userId!);
    }
  }
}

/// =======================
/// SELETOR PREMIUM
/// =======================
class _PeriodSelector extends StatelessWidget {
  final PeriodType selected;
  final ValueChanged<PeriodType> onChange;

  const _PeriodSelector({required this.selected, required this.onChange});

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
