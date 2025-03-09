import 'package:flutter/material.dart';

class NutrientData {
  final String name;
  final String symbol;
  final double value;
  final String unit;
  final Color color;
  final List<num> trendData;
  final bool isOptimal;

  const NutrientData({
    required this.name,
    required this.symbol,
    required this.value,
    required this.unit,
    required this.color,
    required this.trendData,
    required this.isOptimal,
  });
}
