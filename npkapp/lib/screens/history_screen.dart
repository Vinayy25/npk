import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:npkapp/state/npk_state.dart';
import 'package:npkapp/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TimeFrame _selectedTimeFrame = TimeFrame.day;

  @override
  Widget build(BuildContext context) {
    // Add this line to detect dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NPK History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              _showClearHistoryDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTimeFrameSelector(isDarkMode),
          Expanded(
            child: Consumer<NPKState>(
              builder: (context, npkState, child) {
                // Trigger data loading if needed
                if (npkState.historicalData.isEmpty && !npkState.isLoading) {
                  // Request a data refresh which might help populate historical data
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    npkState.refreshData();
                  });
                }

                final historicalData =
                    npkState.getAveragedHistoricalData(_selectedTimeFrame, 50);

                if (historicalData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color:
                              isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No historical data available',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isDarkMode ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Data will appear as readings are collected',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkMode ? Colors.white60 : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (npkState.isLoading)
                          CircularProgressIndicator(
                            color: AppColors.primary,
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () {
                              npkState.refreshData();
                            },
                            icon: Icon(Icons.refresh),
                            label: Text('Refresh Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHistoricalChart(historicalData, isDarkMode),
                      const SizedBox(height: 24),
                      Text(
                        'Statistical Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsSummary(historicalData, isDarkMode),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Readings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Last updated: ${_formatLastUpdated(npkState.lastUpdated)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildHistoricalTable(
                        historicalData.reversed.take(10).toList(),
                        isDarkMode,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Format timestamp into readable text
  String _formatLastUpdated(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, H:mm').format(lastUpdated);
    }
  }

  Widget _buildTimeFrameSelector(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _timeFrameButton(TimeFrame.hour, '1 Hour', isDarkMode),
            _timeFrameButton(TimeFrame.day, '24 Hours', isDarkMode),
            _timeFrameButton(TimeFrame.week, '7 Days', isDarkMode),
            _timeFrameButton(TimeFrame.month, '30 Days', isDarkMode),
            _timeFrameButton(TimeFrame.all, 'All Data', isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _timeFrameButton(TimeFrame timeFrame, String label, bool isDarkMode) {
    final isSelected = timeFrame == _selectedTimeFrame;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MaterialButton(
        onPressed: () {
          setState(() {
            _selectedTimeFrame = timeFrame;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        color: isSelected
            ? AppColors.primary.withOpacity(isDarkMode ? 0.2 : 0.1)
            : Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? AppColors.primary
                : (isDarkMode ? Colors.white70 : Colors.grey[700]),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricalChart(
      List<Map<String, dynamic>> historicalData, bool isDarkMode) {
    final dateFormat = DateFormat('MMM d, HH:mm');

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                strokeWidth: 1,
              );
            },
          ),
          backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: historicalData.length > 6
                    ? (historicalData.length / 6).ceil().toDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < historicalData.length) {
                    final timestamp =
                        historicalData[value.toInt()]['timestamp'];
                    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        dateFormat.format(date),
                        style: TextStyle(
                            fontSize: 9,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600]),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${value.toInt()}',
                      style: TextStyle(
                          fontSize: 10,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            _createLineDataForNutrient(historicalData, 'n', AppColors.nitrogen),
            _createLineDataForNutrient(
                historicalData, 'p', AppColors.phosphorus),
            _createLineDataForNutrient(
                historicalData, 'k', AppColors.potassium),
          ],
          minY: 0,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  final nutrient = spot.barIndex == 0
                      ? 'N'
                      : spot.barIndex == 1
                          ? 'P'
                          : 'K';
                  final color = spot.barIndex == 0
                      ? AppColors.nitrogen
                      : spot.barIndex == 1
                          ? AppColors.phosphorus
                          : AppColors.potassium;

                  return LineTooltipItem(
                    '$nutrient: ${spot.y.toStringAsFixed(1)} ppm',
                    TextStyle(color: color, fontWeight: FontWeight.w500),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
  // Add this method to the _HistoryScreenState class

  LineChartBarData _createLineDataForNutrient(
      List<Map<String, dynamic>> historicalData,
      String nutrientKey,
      Color color) {
    // Create spots for the line chart
    List<FlSpot> spots = [];

    // Loop through historical data and create spots
    for (int i = 0; i < historicalData.length; i++) {
      final data = historicalData[i];
      final value = data[nutrientKey].toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    // Return styled line chart bar data
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.2),
      ),
    );
  }

  Widget _buildStatsSummary(
      List<Map<String, dynamic>> historicalData, bool isDarkMode) {
    // Calculate statistics
    double nMin = double.infinity, nMax = 0, nAvg = 0;
    double pMin = double.infinity, pMax = 0, pAvg = 0;
    double kMin = double.infinity, kMax = 0, kAvg = 0;

    for (var data in historicalData) {
      // N stats
      final n = data['n'].toDouble();
      nMin = n < nMin ? n : nMin;
      nMax = n > nMax ? n : nMax;
      nAvg += n;

      // P stats
      final p = data['p'].toDouble();
      pMin = p < pMin ? p : pMin;
      pMax = p > pMax ? p : pMax;
      pAvg += p;

      // K stats
      final k = data['k'].toDouble();
      kMin = k < kMin ? k : kMin;
      kMax = k > kMax ? k : kMax;
      kAvg += k;
    }

    nAvg = nAvg / historicalData.length;
    pAvg = pAvg / historicalData.length;
    kAvg = kAvg / historicalData.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(
              'Nitrogen (N)', nMin, nMax, nAvg, AppColors.nitrogen, isDarkMode),
          Divider(
              height: 24,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          _buildStatRow('Phosphorus (P)', pMin, pMax, pAvg,
              AppColors.phosphorus, isDarkMode),
          Divider(
              height: 24,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          _buildStatRow('Potassium (K)', kMin, kMax, kAvg, AppColors.potassium,
              isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStatRow(String name, double min, double max, double avg,
      Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'Min: ${min.toStringAsFixed(1)} | Max: ${max.toStringAsFixed(1)} | Avg: ${avg.toStringAsFixed(1)} ppm',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoricalTable(
      List<Map<String, dynamic>> historicalData, bool isDarkMode) {
    final dateFormat = DateFormat('MMM d, HH:mm:ss');

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => isDarkMode ? Color(0xFF252525) : Colors.grey[100]!),
          dataRowColor: MaterialStateColor.resolveWith(
              (states) => isDarkMode ? Color(0xFF1E1E1E) : Colors.white),
          columns: [
            DataColumn(
                label: Text('Time',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('N (ppm)',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('P (ppm)',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('K (ppm)',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold))),
          ],
          rows: historicalData.map((data) {
            final timestamp =
                DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
            return DataRow(
              cells: [
                DataCell(Text(
                  dateFormat.format(timestamp),
                  style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87),
                )),
                DataCell(Text(
                  data['n'].toStringAsFixed(1),
                  style: TextStyle(color: AppColors.nitrogen),
                )),
                DataCell(Text(
                  data['p'].toStringAsFixed(1),
                  style: TextStyle(color: AppColors.phosphorus),
                )),
                DataCell(Text(
                  data['k'].toStringAsFixed(1),
                  style: TextStyle(color: AppColors.potassium),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Color(0xFF252525) : Colors.white,
          title: Text(
            'Clear History',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to clear all historical data? This action cannot be undone.',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Provider.of<NPKState>(context, listen: false)
                    .clearHistoricalData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
