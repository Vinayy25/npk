import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:npkapp/models/nutrient_model.dart';

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
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: Colors.grey[600],
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
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 100,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                String name;
                if (spot.barIndex == 0) {
                  name = nitrogenData.name;
                } else if (spot.barIndex == 1) {
                  name = phosphorusData.name;
                } else {
                  name = potassiumData.name;
                }
                return LineTooltipItem(
                  '${spot.y.toInt()} ppm',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '\n$name',
                      style: TextStyle(
                        color: spot.barIndex == 0
                            ? nitrogenData.color
                            : spot.barIndex == 1
                                ? phosphorusData.color
                                : potassiumData.color,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          _createLineData(nitrogenData, 0),
          _createLineData(phosphorusData, 1),
          _createLineData(potassiumData, 2),
        ],
      ),
    );
  }

  LineChartBarData _createLineData(NutrientData data, int index) {
    return LineChartBarData(
      spots: data.trendData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.toDouble());
      }).toList(),
      isCurved: true,
      color: data.color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: data.color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: data.color.withOpacity(0.15),
      ),
    );
  }
}
