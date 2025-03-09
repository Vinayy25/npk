import 'dart:async';
import 'package:flutter/material.dart';
import 'package:npkapp/models/nutrient_model.dart';
import 'package:npkapp/utils/colors.dart';

class NPKState extends ChangeNotifier {
  // Nutrient data
  NutrientData _nitrogenData = NutrientData(
    name: 'Nitrogen',
    symbol: 'N',
    value: 68.0,
    unit: 'ppm',
    color: AppColors.nitrogen,
    trendData: [45, 52, 60, 65, 68, 70, 68],
    isOptimal: true,
  );

  NutrientData _phosphorusData = NutrientData(
    name: 'Phosphorus',
    symbol: 'P',
    value: 42.0,
    unit: 'ppm',
    color: AppColors.phosphorus,
    trendData: [30, 35, 38, 40, 42, 43, 42],
    isOptimal: true,
  );

  NutrientData _potassiumData = NutrientData(
    name: 'Potassium',
    symbol: 'K',
    value: 25.0,
    unit: 'ppm',
    color: AppColors.potassium,
    trendData: [18, 20, 22, 24, 25, 25, 25],
    isOptimal: false,
  );

  // Additional soil data
  double _pH = 6.5;
  double _moisture = 68.0;
  String _soilHealth = 'Good';
  DateTime _lastUpdated = DateTime.now();

  // Loading state
  bool _isLoading = false;
  String? _error;

  // Animation controller state
  bool _shouldResetAnimation = false;

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

  // Method to reset animation flag after consumption
  void consumeAnimationReset() {
    // Only update the flag, no notification needed here
    _shouldResetAnimation = false;
  }

  // Method to fetch data from sensor (simulated for now)
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Update with mock data for now
      _nitrogenData = NutrientData(
        name: 'Nitrogen',
        symbol: 'N',
        value: 68.0 + (DateTime.now().second % 10 - 5),
        unit: 'ppm',
        color: AppColors.nitrogen,
        trendData: [
          ..._nitrogenData.trendData.sublist(1),
          _nitrogenData.value.toInt() + (DateTime.now().second % 7 - 3)
        ],
        isOptimal: true,
      );

      _phosphorusData = NutrientData(
        name: 'Phosphorus',
        symbol: 'P',
        value: 42.0 + (DateTime.now().second % 8 - 4),
        unit: 'ppm',
        color: AppColors.phosphorus,
        trendData: [
          ..._phosphorusData.trendData.sublist(1),
          _phosphorusData.value.toInt() + (DateTime.now().second % 5 - 2)
        ],
        isOptimal: true,
      );

      _potassiumData = NutrientData(
        name: 'Potassium',
        symbol: 'K',
        value: 25.0 + (DateTime.now().second % 6 - 3),
        unit: 'ppm',
        color: AppColors.potassium,
        trendData: [
          ..._potassiumData.trendData.sublist(1),
          _potassiumData.value.toInt() + (DateTime.now().second % 3 - 1)
        ],
        isOptimal: false,
      );

      _pH = 6.5 + (DateTime.now().second % 10 - 5) / 10;
      _moisture = 68.0 + (DateTime.now().second % 10 - 5);
      _lastUpdated = DateTime.now();

      // Assess soil health based on updated values
      _assessSoilHealth();
      _shouldResetAnimation = true;
    } catch (e) {
      _error = "Failed to fetch sensor data";
    } finally {
      _isLoading = false;
      notifyListeners(); // Single notification at the end
    }
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

    // Check pH levels
    if (_pH < 6.0) {
      recommendations.add({
        'title': 'Soil Too Acidic',
        'description':
            'Add garden lime to raise pH to the optimal range of 6.0-7.0.',
        'color': Colors.amber,
        'icon': Icons.science_rounded,
      });
    } else if (_pH > 7.5) {
      recommendations.add({
        'title': 'Soil Too Alkaline',
        'description':
            'Add sulfur or peat moss to lower pH to the optimal range.',
        'color': Colors.amber,
        'icon': Icons.science_rounded,
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
}
