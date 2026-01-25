// lib/screens/widgets/relatorios/days/charts/line_chart_section.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../l10n/app_localizations.dart';

import '../../../../../firebase/firestore/movements_days.dart';
import '../widgets/legend_item.dart';

class LineChartSection extends StatelessWidget {
  final List<FlSpot> spotsAdd;
  final List<FlSpot> spotsRemove;
  final double minX;
  final double maxX;
  final double maxY;

  final List<Movement> refsAdd;
  final List<Movement> refsRemove;

  final ValueChanged<String> onSelectProductId;

  const LineChartSection({
    super.key,
    required this.spotsAdd,
    required this.spotsRemove,
    required this.minX,
    required this.maxX,
    required this.maxY,
    required this.refsAdd,
    required this.refsRemove,
    required this.onSelectProductId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          l10n.relatoriosCumulativeMovementsTitle,
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
            LegendItem(label: l10n.relatoriosEntries, color: const Color(0xFF27AE60)),
            const SizedBox(width: 20),
            LegendItem(label: l10n.relatoriosExits, color: const Color(0xFFE74C3C)),
          ],
        ),
        const SizedBox(height: 12),

        Expanded(
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spotsAdd,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                  ),
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
                ),
                LineChartBarData(
                  spots: spotsRemove,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE74C3C), Color(0xFFE74C3C)],
                  ),
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
                ),
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
                      return const Text('');
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
                    // ✅ garante lista sem null e sem estourar índice
                    return touchedSpots.map((spot) {
                      final isAdd = spot.barIndex == 0;
                      final refList = isAdd ? refsAdd : refsRemove;
                      final idx = spot.spotIndex;

                      if (idx < 0 || idx >= refList.length) {
                        return const LineTooltipItem(
                          '',
                          TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }

                      final movement = refList[idx];
                      onSelectProductId(movement.productId);

                      final timeStr = DateFormat('HH:mm').format(movement.timestamp);
                      final typeLabel = isAdd ? l10n.relatoriosEntry : l10n.relatoriosExit;

                      // Você quer usar: relatoriosLineTooltip(label, value)
                      // Aqui eu uso o movement.quantity como valor.
                      // Se você preferir mostrar o valor acumulado do gráfico, troque por: spot.y
                      final value = movement.quantity;

                      final tooltipText = '$timeStr\n${l10n.relatoriosLineTooltip(typeLabel, value)}';

                      return LineTooltipItem(
                        tooltipText,
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
    );
  }
}
