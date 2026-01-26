// lib/screens/widgets/relatorios/days/for_product/widgets/product_line_chart_card.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../firebase/firestore/movements_days.dart';
import '../../../../../models/report_period.dart';

class RelatoriosForProductLineChartCard extends StatelessWidget {
  final ReportPeriod period;
  final String productName;

  final String titleDay;
  final String titleMonth;

  final List<FlSpot> spotsAdd;
  final List<FlSpot> spotsRemove;

  final List<Movement> refsAdd;
  final List<Movement> refsRemove;

  final double minX;
  final double maxX;
  final double maxY;

  const RelatoriosForProductLineChartCard({
    super.key,
    required this.period,
    required this.productName,
    required this.titleDay,
    required this.titleMonth,
    required this.spotsAdd,
    required this.spotsRemove,
    required this.refsAdd,
    required this.refsRemove,
    required this.minX,
    required this.maxX,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final title = period.isMonth ? titleMonth : titleDay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = MediaQuery.of(context).size.height;
          final chartHeight = screenHeight * 0.4;

          return Container(
            height: chartHeight,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFF8F9FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 15,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF34495E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem(l10n.relatoriosEntries, const Color(0xFF27AE60)),
                      const SizedBox(width: 20),
                      _legendItem(l10n.relatoriosExits, const Color(0xFFE74C3C)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          _barAdd(),
                          _barRemove(),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text(
                              l10n.relatoriosTimeAxisLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 2,
                              getTitlesWidget: (value, meta) {
                                if (value % 2 == 0 && value >= 0 && value <= 24) {
                                  return Text(
                                    '${value.toInt().toString().padLeft(2, '0')}:00',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: maxY / 10,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7F8C8D),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          verticalInterval: 2,
                          horizontalInterval: maxY / 10,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: const Color(0xFFECF0F1),
                            strokeWidth: 0.5,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: const Color(0xFFECF0F1),
                            strokeWidth: 0.5,
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xFFBDC3C7), width: 1),
                        ),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(12),
                            tooltipMargin: 8,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final isAdd = spot.barIndex == 0;
                                final refList = isAdd ? refsAdd : refsRemove;
                                final idx = spot.spotIndex;

                                if (idx < 0 || idx >= refList.length) return null;

                                final movement = refList[idx];
                                final timeStr = DateFormat('HH:mm').format(movement.timestamp);
                                final typeLabel = isAdd ? l10n.relatoriosEntry : l10n.relatoriosExit;

                                // ✅ Usa a chave label/value que você já padronizou
                                final label = '$timeStr • $typeLabel (+${movement.quantity})';
                                final value = spot.y.toInt();

                                return LineTooltipItem(
                                  l10n.relatoriosLineTooltip(label, value),
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        minX: minX,
                        maxX: maxX,
                        minY: 0,
                        maxY: maxY,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF34495E),
          ),
        ),
      ],
    );
  }

  LineChartBarData _barAdd() {
    return LineChartBarData(
      spots: spotsAdd,
      isCurved: true,
      gradient: const LinearGradient(colors: [Color(0xFF27AE60), Color(0xFF2ECC71)]),
      barWidth: 5,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF27AE60).withValues(alpha: 0.2),
            const Color(0xFF2ECC71).withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 6,
          color: const Color(0xFF27AE60),
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
    );
  }

  LineChartBarData _barRemove() {
    return LineChartBarData(
      spots: spotsRemove,
      isCurved: true,
      gradient: const LinearGradient(colors: [Color(0xFFE74C3C), Color(0xFFE74C3C)]),
      barWidth: 5,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE74C3C).withValues(alpha: 0.2),
            const Color(0xFFE74C3C).withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 6,
          color: const Color(0xFFE74C3C),
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
    );
  }
}
