import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:npkapp/models/nutrient_model.dart';
import 'package:npkapp/utils/colors.dart';

class NutrientTrendChart extends StatelessWidget {
  final NutrientData nitrogenData;
  final NutrientData phosphorusData;
  final NutrientData potassiumData;

  const NutrientTrendChart({
    super.key,
    required this.nitrogenData,
    required this.phosphorusData,
    required this.potassiumData,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value >= 0 && value < days.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          _createLineData(nitrogenData),
          _createLineData(phosphorusData),
          _createLineData(potassiumData),
        ],
      ),
    );
  }

  LineChartBarData _createLineData(NutrientData data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.trendData.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.trendData[i].toDouble()));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: data.color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: data.color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: data.color.withOpacity(0.1),
      ),
    );
  }
}
