import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:npkapp/models/nutrient_model.dart';
import 'package:npkapp/utils/colors.dart';
import 'package:npkapp/services/http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NPKState extends ChangeNotifier {
  // Nutrient data
  NutrientData _nitrogenData = NutrientData(
    name: 'Nitrogen',
    symbol: 'N',
    value: 0.0,
    unit: 'ppm',
    color: AppColors.nitrogen,
    trendData: [0, 0, 0, 0, 0, 0, 0],
    isOptimal: false,
  );

  NutrientData _phosphorusData = NutrientData(
    name: 'Phosphorus',
    symbol: 'P',
    value: 0.0,
    unit: 'ppm',
    color: AppColors.phosphorus,
    trendData: [0, 0, 0, 0, 0, 0, 0],
    isOptimal: false,
  );

  NutrientData _potassiumData = NutrientData(
    name: 'Potassium',
    symbol: 'K',
    value: 0.0,
    unit: 'ppm',
    color: AppColors.potassium,
    trendData: [0, 0, 0, 0, 0, 0, 0],
    isOptimal: false,
  );

  // Additional soil data
  double _pH = 6.5;
  double _moisture = 68.0;
  String _soilHealth = 'Unknown';
  DateTime _lastUpdated = DateTime.now();

  // Timer for periodic data fetching
  Timer? _fetchTimer;

  // Data validation and status
  bool _dataReceived = false;
  bool _isFirstLoad = true;

  // Loading state
  bool _isLoading = false;
  String? _error;

  // Animation controller state
  bool _shouldResetAnimation = false;

  // Historical data storage
  List<Map<String, dynamic>> _historicalData = [];
  static const String _historicalDataKey = 'npk_historical_data';
  static const int _maxHistoricalEntries = 500; // Adjust based on your needs

  // Add these properties to NPKState class
  int _refreshRateMs = 1000; // Default refresh rate

  // Getters
  NutrientData get nitrogenData => _nitrogenData;
  NutrientData get phosphorusData => _phosphorusData;
  NutrientData get potassiumData => _potassiumData;
  double get pH => _pH;
  double get moisture => _moisture;
  String get soilHealth => _soilHealth;
  DateTime get lastUpdated => _lastUpdated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get shouldResetAnimation => _shouldResetAnimation;
  bool get dataReceived => _dataReceived;
  List<Map<String, dynamic>> get historicalData => _historicalData;

  // Constructor - start periodic data fetching
  NPKState() {
    _loadHistoricalData();
    _loadSettings();
    startPeriodicFetch();
  }

  // Start periodic data fetching
  void startPeriodicFetch() {
    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(Duration(milliseconds: _refreshRateMs), (_) {
      fetchData();
    });
  }

  // Stop periodic data fetching
  void stopPeriodicFetch() {
    _fetchTimer?.cancel();
    _fetchTimer = null;
  }

  // Method to reset animation flag after consumption
  void consumeAnimationReset() {
    _shouldResetAnimation = false;
  }

  // Method to fetch data from sensor via HTTP
  Future<void> fetchData() async {
    // Don't set loading state for automatic background updates
    if (_isFirstLoad) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      // Fetch data from FastAPI server
      final data = await HttpService.fetchNPKData();

      // Validate data
      if (HttpService.isValidNPKData(data)) {
        // Use safe parsing to avoid exceptions
        final n =
            _safeParse(data?['N']?.toString() ?? 'NA', _nitrogenData.value);
        final p =
            _safeParse(data?['P']?.toString() ?? 'NA', _phosphorusData.value);
        final k =
            _safeParse(data?['K']?.toString() ?? 'NA', _potassiumData.value);

        // Only update if we got valid numbers
        if (n != null && p != null && k != null) {
          // Update nitrogen data
          _nitrogenData = NutrientData(
            name: 'Nitrogen',
            symbol: 'N',
            value: n,
            unit: 'ppm',
            color: AppColors.nitrogen,
            trendData: [..._nitrogenData.trendData.sublist(1), n.toInt()],
            isOptimal: n >= 50, // Adjust threshold as needed
          );

          // Update phosphorus data
          _phosphorusData = NutrientData(
            name: 'Phosphorus',
            symbol: 'P',
            value: p,
            unit: 'ppm',
            color: AppColors.phosphorus,
            trendData: [..._phosphorusData.trendData.sublist(1), p.toInt()],
            isOptimal: p >= 35, // Adjust threshold as needed
          );

          // Update potassium data
          _potassiumData = NutrientData(
            name: 'Potassium',
            symbol: 'K',
            value: k,
            unit: 'ppm',
            color: AppColors.potassium,
            trendData: [..._potassiumData.trendData.sublist(1), k.toInt()],
            isOptimal: k >= 30, // Adjust threshold as needed
          );

          // Update timestamp and assess soil health
          _lastUpdated = DateTime.now();
          _assessSoilHealth();
          _dataReceived = true;
          _shouldResetAnimation = true;
          _error = null;

          // Add to historical data
          _addHistoricalDataPoint(n, p, k);
        } else if (_isFirstLoad) {
          _error = "Invalid sensor data format";
        }
      } else if (_isFirstLoad || !_dataReceived) {
        _error = "Sensor data unavailable";
      }
    } catch (e) {
      if (_isFirstLoad || !_dataReceived) {
        _error = "Failed to fetch sensor data";
      }
      print("Error updating NPK data: $e");
    } finally {
      _isFirstLoad = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Manual refresh - force loading state
  Future<void> refreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await fetchData();
  }

  // Assess overall soil health based on nutrient levels
  void _assessSoilHealth() {
    if (_nitrogenData.isOptimal &&
        _phosphorusData.isOptimal &&
        _potassiumData.isOptimal) {
      _soilHealth = 'Excellent';
    } else if (_nitrogenData.isOptimal && _phosphorusData.isOptimal) {
      _soilHealth = 'Good';
    } else if (!_potassiumData.isOptimal && !_phosphorusData.isOptimal) {
      _soilHealth = 'Poor';
    } else {
      _soilHealth = 'Fair';
    }
  }

  // Generate recommendations based on current nutrient levels
  List<Map<String, dynamic>> getRecommendations() {
    final recommendations = <Map<String, dynamic>>[];

    if (!_dataReceived) {
      recommendations.add({
        'title': 'Waiting for Data',
        'description': 'Connecting to NPK sensor...',
        'color': Colors.grey,
        'icon': Icons.hourglass_empty,
      });
      return recommendations;
    }

    // Check potassium levels
    if (!_potassiumData.isOptimal) {
      recommendations.add({
        'title': 'Increase Potassium',
        'description':
            'Consider adding wood ash or a specialized potassium fertilizer.',
        'color': AppColors.potassium,
        'icon': Icons.eco_rounded,
      });
    }

    // Check nitrogen levels
    if (_nitrogenData.value < 50) {
      recommendations.add({
        'title': 'Nitrogen Deficiency',
        'description':
            'Add compost or nitrogen-rich organic fertilizer to improve levels.',
        'color': AppColors.nitrogen,
        'icon': Icons.grass_rounded,
      });
    }

    // Check phosphorus levels
    if (_phosphorusData.value < 35) {
      recommendations.add({
        'title': 'Phosphorus Boost Needed',
        'description':
            'Add bone meal or rock phosphate to increase phosphorus levels.',
        'color': AppColors.phosphorus,
        'icon': Icons.water_drop_rounded,
      });
    }

    // If no recommendations, add a default one
    if (recommendations.isEmpty) {
      recommendations.add({
        'title': 'Soil Conditions Optimal',
        'description': 'Continue with your current soil management practices.',
        'color': Colors.green,
        'icon': Icons.check_circle_rounded,
      });
    }

    return recommendations;
  }

  @override
  void dispose() {
    // Cancel timer when the state is disposed
    stopPeriodicFetch();
    super.dispose();
  }

  // Helper method to safely parse string values to double
  double? _safeParse(String value, double fallback) {
    if (value == 'NA') {
      return null;
    }

    try {
      final parsed = double.parse(value);

      // Check for valid range and error codes
      if (parsed == 255 || parsed < 0 || parsed > 200) {
        return null;
      }

      return parsed;
    } catch (e) {
      print('Error parsing value "$value": $e');
      return null;
    }
  }

  // Load historical data from SharedPreferences
  Future<void> _loadHistoricalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_historicalDataKey);

      if (jsonData != null && jsonData.isNotEmpty) {
        final decoded = json.decode(jsonData) as List<dynamic>;
        _historicalData =
            decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        print('Loaded ${_historicalData.length} historical data points');

        // Initialize trend data from historical data if available
        if (_historicalData.isNotEmpty) {
          _initializeFromHistory();
        }
      }
    } catch (e) {
      print('Error loading historical data: $e');
      // Initialize with empty data if loading fails
      _historicalData = [];
    }
  }

  // Initialize current state from historical data
  void _initializeFromHistory() {
    if (_historicalData.isEmpty) return;

    // Get the latest entry
    final latest = _historicalData.last;

    // Extract recent trend data (up to 7 points)
    final trendLength = 7;
    final recentEntries = _historicalData.length < trendLength
        ? _historicalData
        : _historicalData.sublist(_historicalData.length - trendLength);

    List<int> nTrend = [];
    List<int> pTrend = [];
    List<int> kTrend = [];

    for (var entry in recentEntries) {
      nTrend.add(entry['n'].round());
      pTrend.add(entry['p'].round());
      kTrend.add(entry['k'].round());
    }

    // Pad with zeros if needed
    while (nTrend.length < 7) {
      nTrend.insert(0, 0);
      pTrend.insert(0, 0);
      kTrend.insert(0, 0);
    }

    // Update current state
    _nitrogenData = NutrientData(
      name: 'Nitrogen',
      symbol: 'N',
      value: latest['n'],
      unit: 'ppm',
      color: AppColors.nitrogen,
      trendData: nTrend,
      isOptimal: latest['n'] >= 50,
    );

    _phosphorusData = NutrientData(
      name: 'Phosphorus',
      symbol: 'P',
      value: latest['p'],
      unit: 'ppm',
      color: AppColors.phosphorus,
      trendData: pTrend,
      isOptimal: latest['p'] >= 35,
    );

    _potassiumData = NutrientData(
      name: 'Potassium',
      symbol: 'K',
      value: latest['k'],
      unit: 'ppm',
      color: AppColors.potassium,
      trendData: kTrend,
      isOptimal: latest['k'] >= 30,
    );

    // Also update other values if available
    if (latest.containsKey('pH')) _pH = latest['pH'];
    if (latest.containsKey('moisture')) _moisture = latest['moisture'];
    if (latest.containsKey('timestamp')) {
      _lastUpdated = DateTime.fromMillisecondsSinceEpoch(latest['timestamp']);
    }

    _dataReceived = true;
    _assessSoilHealth();
  }

  // Save historical data to SharedPreferences
  Future<void> _saveHistoricalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(_historicalData);
      await prefs.setString(_historicalDataKey, jsonData);
    } catch (e) {
      print('Error saving historical data: $e');
    }
  }

  // Add new data point to historical data
  void _addHistoricalDataPoint(double n, double p, double k) {
    final now = DateTime.now();
    final dataPoint = {
      'timestamp': now.millisecondsSinceEpoch,
      'datetime': now.toIso8601String(),
      'n': n,
      'p': p,
      'k': k,
      'pH': _pH,
      'moisture': _moisture,
      'soilHealth': _soilHealth,
    };

    _historicalData.add(dataPoint);

    // Limit the size of historical data to avoid excessive storage
    if (_historicalData.length > _maxHistoricalEntries) {
      _historicalData.removeAt(0);
    }

    // Save after update
    _saveHistoricalData();
  }

  // Clear historical data
  Future<void> clearHistoricalData() async {
    _historicalData = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historicalDataKey);
    notifyListeners();
  }

  // Get historical data for a specific timeframe
  List<Map<String, dynamic>> getHistoricalDataByTimeframe(TimeFrame timeFrame) {
    if (_historicalData.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoff;

    switch (timeFrame) {
      case TimeFrame.hour:
        cutoff = now.subtract(const Duration(hours: 1));
        break;
      case TimeFrame.day:
        cutoff = now.subtract(const Duration(days: 1));
        break;
      case TimeFrame.week:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case TimeFrame.month:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      default:
        return _historicalData;
    }

    final cutoffMillis = cutoff.millisecondsSinceEpoch;
    return _historicalData
        .where((data) => data['timestamp'] >= cutoffMillis)
        .toList();
  }

  // Get averaged historical data for charts (useful for larger datasets)
  List<Map<String, dynamic>> getAveragedHistoricalData(
      TimeFrame timeFrame, int maxPoints) {
    final filteredData = getHistoricalDataByTimeframe(timeFrame);
    if (filteredData.length <= maxPoints) {
      return filteredData;
    }

    // Need to average data to reduce points
    final pointsPerGroup = (filteredData.length / maxPoints).ceil();
    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < filteredData.length; i += pointsPerGroup) {
      final end = i + pointsPerGroup < filteredData.length
          ? i + pointsPerGroup
          : filteredData.length;
      final chunk = filteredData.sublist(i, end);

      double nSum = 0, pSum = 0, kSum = 0;
      for (var item in chunk) {
        nSum += item['n'];
        pSum += item['p'];
        kSum += item['k'];
      }

      final avgPoint = {
        'timestamp': chunk[chunk.length ~/ 2]['timestamp'],
        'datetime': chunk[chunk.length ~/ 2]['datetime'],
        'n': nSum / chunk.length,
        'p': pSum / chunk.length,
        'k': kSum / chunk.length,
      };

      result.add(avgPoint);
    }

    return result;
  }

  // Add a method to update refresh rate
  void updateRefreshRate(int milliseconds) {
    if (_refreshRateMs != milliseconds) {
      _refreshRateMs = milliseconds;
      // Restart timer with new refresh rate
      startPeriodicFetch();
    }
  }

  // Add method to load settings
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String refreshRateStr = prefs.getString('refreshRate') ?? '1 second';

      // Convert string refresh rate to milliseconds
      switch (refreshRateStr) {
        case '0.5 seconds':
          _refreshRateMs = 500;
          break;
        case '1 second':
          _refreshRateMs = 1000;
          break;
        case '5 seconds':
          _refreshRateMs = 5000;
          break;
        case '10 seconds':
          _refreshRateMs = 10000;
          break;
        case '30 seconds':
          _refreshRateMs = 30000;
          break;
        case '1 minute':
          _refreshRateMs = 60000;
          break;
        default:
          _refreshRateMs = 1000;
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }
}

// Add an enum for time frames
enum TimeFrame { hour, day, week, month, all }
