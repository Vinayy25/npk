import 'package:flutter/material.dart';
import 'package:npkapp/utils/colors.dart';
import 'package:npkapp/state/npk_state.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Default alert thresholds
  final Map<String, Map<String, dynamic>> _alertSettings = {
    'nitrogen': {
      'enabled': true,
      'minValue': 40.0,
      'maxValue': 80.0,
      'unit': 'ppm',
      'color': AppColors.nitrogen,
      'icon': Icons.grass_outlined,
    },
    'phosphorus': {
      'enabled': true,
      'minValue': 30.0,
      'maxValue': 60.0,
      'unit': 'ppm',
      'color': AppColors.phosphorus,
      'icon': Icons.spa_outlined,
    },
    'potassium': {
      'enabled': true,
      'minValue': 25.0,
      'maxValue': 50.0,
      'unit': 'ppm',
      'color': AppColors.potassium,
      'icon': Icons.water_drop_outlined,
    },
    'pH': {
      'enabled': true,
      'minValue': 6.0,
      'maxValue': 7.0,
      'unit': '',
      'color': Colors.amber,
      'icon': Icons.science_outlined,
    },
    'moisture': {
      'enabled': true,
      'minValue': 50.0,
      'maxValue': 70.0,
      'unit': '%',
      'color': Colors.lightBlue,
      'icon': Icons.water_outlined,
    },
  };

  // Notification frequency
  String _alertFrequency = 'Immediate';
  final List<String> _frequencyOptions = ['Immediate', 'Hourly', 'Daily'];

  // Plant profiles for quick settings
  final List<Map<String, dynamic>> _plantProfiles = [
    {
      'name': 'Tomatoes',
      'icon': Icons.agriculture, // Replace emoji with agriculture icon
      'color': Colors.red[600], // Add color for visual distinction
      'n': {'min': 40, 'max': 80},
      'p': {'min': 45, 'max': 70},
      'k': {'min': 40, 'max': 60},
      'pH': {'min': 6.0, 'max': 6.8},
    },
    {
      'name': 'Leafy Greens',
      'icon': Icons.eco, // Replace emoji with leaf/eco icon
      'color': Colors.green[700],
      'n': {'min': 50, 'max': 90},
      'p': {'min': 30, 'max': 50},
      'k': {'min': 30, 'max': 50},
      'pH': {'min': 6.0, 'max': 7.0},
    },
    {
      'name': 'Roses',
      'icon': Icons.local_florist, // Replace emoji with flower icon
      'color': Colors.pink[400],
      'n': {'min': 35, 'max': 75},
      'p': {'min': 45, 'max': 85},
      'k': {'min': 35, 'max': 60},
      'pH': {'min': 6.5, 'max': 7.0},
    },
    {
      'name': 'Custom',
      'icon': Icons.settings, // Replace emoji with settings icon
      'color': Colors.grey[700],
    },
  ];

  // Alert history
  List<Map<String, dynamic>> _alertHistory = [
    {
      'timestamp':
          DateTime.now().subtract(const Duration(hours: 1, minutes: 23)),
      'type': 'nitrogen',
      'message': 'Nitrogen levels below minimum threshold',
      'value': 38.5,
      'threshold': 40.0,
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      'type': 'pH',
      'message': 'pH level above maximum threshold',
      'value': 7.2,
      'threshold': 7.0,
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      'type': 'potassium',
      'message': 'Potassium levels below minimum threshold',
      'value': 22.3,
      'threshold': 25.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAlertSettings();
  }

  Future<void> _loadAlertSettings() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Load alert settings for each nutrient type
      for (final key in _alertSettings.keys) {
        if (prefs.containsKey('alert_${key}_enabled')) {
          setState(() {
            _alertSettings[key]!['enabled'] =
                prefs.getBool('alert_${key}_enabled') ?? true;
            _alertSettings[key]!['minValue'] =
                prefs.getDouble('alert_${key}_minValue') ??
                    _alertSettings[key]!['minValue'];
            _alertSettings[key]!['maxValue'] =
                prefs.getDouble('alert_${key}_maxValue') ??
                    _alertSettings[key]!['maxValue'];
          });
        }
      }

      // Load notification frequency
      final savedFrequency = prefs.getString('alert_frequency');
      if (savedFrequency != null &&
          _frequencyOptions.contains(savedFrequency)) {
        setState(() {
          _alertFrequency = savedFrequency;
        });
      }

      // Load alert history
      final historyJson = prefs.getString('alert_history');
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        setState(() {
          _alertHistory = historyList
              .map((item) {
                // Convert timestamp string back to DateTime
                return {
                  'timestamp': DateTime.parse(item['timestamp']),
                  'type': item['type'],
                  'message': item['message'],
                  'value': item['value'],
                  'threshold': item['threshold'],
                };
              })
              .toList()
              .cast<Map<String, dynamic>>();
        });
      }

      print('Alert settings loaded successfully');
    } catch (e) {
      print('Error loading alert settings: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    // Inside _buildConfigureTab method, after building all the UI elements:
// Add this near the end of the method, just before the return statement
    final npkState = Provider.of<NPKState>(context);  

       WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check current readings against thresholds
      // This should only run once after the UI is built
      checkCurrentReadings(npkState);
    });
    // Add this to detect dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alert Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Configure'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          if (_tabController.index == 1) // Only show when on History tab
            IconButton(
              icon: Icon(Icons.delete_outline),
              tooltip: 'Clear Alert History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear Alert History'),
                    content: Text(
                        'Are you sure you want to delete all alert history?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child:
                            Text('Clear', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          clearAlertHistory();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConfigureTab(isDarkMode),
          _buildHistoryTab(isDarkMode),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAlertSettings,
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildConfigureTab(bool isDarkMode) {
    return Consumer<NPKState>(
      builder: (context, npkState, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlantProfilesSection(isDarkMode),
              const SizedBox(height: 24),

              Text(
                'Alert Thresholds',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get notified when nutrient levels go outside these ranges',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Threshold settings for each nutrient
              _buildThresholdCard('nitrogen', 'Nitrogen (N)',
                  npkState.nitrogenData.value, isDarkMode),
              _buildThresholdCard('phosphorus', 'Phosphorus (P)',
                  npkState.phosphorusData.value, isDarkMode),
              _buildThresholdCard('potassium', 'Potassium (K)',
                  npkState.potassiumData.value, isDarkMode),
              _buildThresholdCard('pH', 'pH Level', npkState.pH, isDarkMode),
              _buildThresholdCard(
                  'moisture', 'Moisture', npkState.moisture, isDarkMode),

              const SizedBox(height: 24),

              // Notification settings
              Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Alert frequency
              Card(
                color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alert Frequency',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _alertFrequency,
                        dropdownColor:
                            isDarkMode ? Color(0xFF252525) : Colors.white,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          filled: isDarkMode,
                          fillColor: isDarkMode ? Color(0xFF303030) : null,
                        ),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        items: _frequencyOptions.map((String frequency) {
                          return DropdownMenuItem<String>(
                            value: frequency,
                            child: Text(frequency),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _alertFrequency = newValue;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'How often would you like to receive alerts when values are outside thresholds?',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Smart Schedule
              const SizedBox(height: 16),
              Card(
                color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Smart Monitoring',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Switch(
                            value: true,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              // Enable/disable smart monitoring
                            },
                          ),
                        ],
                      ),
                      Text(
                        'Automatically adjusts monitoring frequency based on soil conditions and growth stage',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlantProfilesSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plant Profiles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Quick settings for specific plants',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _plantProfiles
                .map((profile) => _buildPlantProfileCard(profile, isDarkMode))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantProfileCard(Map<String, dynamic> profile, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (profile['name'] != 'Custom') {
          _applyPlantProfile(profile);
        }
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  profile['icon'],
                  color: profile['color'],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  profile['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdCard(
      String key, String name, double currentValue, bool isDarkMode) {
    final settings = _alertSettings[key]!;
    final color = settings['color'] as Color;
    final icon = settings['icon'] as IconData;
    final unit = settings['unit'] as String;

    return Card(
      color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: settings['enabled'] as bool,
                  activeColor: color,
                  onChanged: (value) {
                    setState(() {
                      _alertSettings[key]!['enabled'] = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Current value indicator (update colors for dark mode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isInRange(key, currentValue)
                    ? (isDarkMode
                        ? Colors.green.withOpacity(0.15)
                        : Colors.green[50])
                    : (isDarkMode
                        ? Colors.red.withOpacity(0.15)
                        : Colors.red[50]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isInRange(key, currentValue)
                      ? (isDarkMode
                          ? Colors.green.withOpacity(0.7)
                          : Colors.green)
                      : (isDarkMode
                          ? Colors.red.withOpacity(0.7)
                          : Colors.red[300]!),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isInRange(key, currentValue)
                        ? Icons.check_circle
                        : Icons.warning,
                    size: 16,
                    color: _isInRange(key, currentValue)
                        ? (isDarkMode
                            ? Colors.green.withOpacity(0.9)
                            : Colors.green)
                        : (isDarkMode
                            ? Colors.red.withOpacity(0.9)
                            : Colors.red[300]),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Current: ${currentValue.toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isInRange(key, currentValue)
                          ? (isDarkMode
                              ? Colors.green.withOpacity(0.9)
                              : Colors.green[700])
                          : (isDarkMode
                              ? Colors.red.withOpacity(0.9)
                              : Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Slider for min value
            Row(
              children: [
                SizedBox(
                  width: 65,
                  child: Text(
                    'Min',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: settings['minValue'] as double,
                    activeColor: color,
                    inactiveColor: color.withOpacity(isDarkMode ? 0.3 : 0.2),
                    min: _getMinValueForKey(key),
                    max: _getMaxValueForKey(key),
                    divisions: _getDivisionsForKey(key),
                    label: '${settings['minValue'].toStringAsFixed(1)}$unit',
                    onChanged: (value) {
                      setState(() {
                        // Ensure min doesn't exceed max
                        if (value < settings['maxValue']) {
                          _alertSettings[key]!['minValue'] = value;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${settings['minValue'].toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            // Slider for max value
            Row(
              children: [
                SizedBox(
                  width: 65,
                  child: Text(
                    'Max',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: settings['maxValue'] as double,
                    activeColor: color,
                    inactiveColor: color.withOpacity(isDarkMode ? 0.3 : 0.2),
                    min: _getMinValueForKey(key),
                    max: _getMaxValueForKey(key),
                    divisions: _getDivisionsForKey(key),
                    label: '${settings['maxValue'].toStringAsFixed(1)}$unit',
                    onChanged: (value) {
                      setState(() {
                        // Ensure max doesn't go below min
                        if (value > settings['minValue']) {
                          _alertSettings[key]!['maxValue'] = value;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${settings['maxValue'].toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(bool isDarkMode) {
    if (_alertHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No alerts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alerts will appear here when triggered',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white60 : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alertHistory.length,
      itemBuilder: (context, index) {
        final alert = _alertHistory[index];
        final timestamp = alert['timestamp'] as DateTime;
        final type = alert['type'] as String;
        final settings = _alertSettings[type]!;
        final color = settings['color'] as Color;
        final icon = settings['icon'] as IconData;

        return Card(
          color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              alert['message'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${_getTimeAgo(timestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Value: ${alert['value']} ${settings['unit']} (Threshold: ${alert['threshold']} ${settings['unit']})',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyPlantProfile(Map<String, dynamic> profile) {
    setState(() {
      if (profile.containsKey('n')) {
        _alertSettings['nitrogen']!['minValue'] =
            profile['n']['min'].toDouble();
        _alertSettings['nitrogen']!['maxValue'] =
            profile['n']['max'].toDouble();
      }

      if (profile.containsKey('p')) {
        _alertSettings['phosphorus']!['minValue'] =
            profile['p']['min'].toDouble();
        _alertSettings['phosphorus']!['maxValue'] =
            profile['p']['max'].toDouble();
      }

      if (profile.containsKey('k')) {
        _alertSettings['potassium']!['minValue'] =
            profile['k']['min'].toDouble();
        _alertSettings['potassium']!['maxValue'] =
            profile['k']['max'].toDouble();
      }

      if (profile.containsKey('pH')) {
        _alertSettings['pH']!['minValue'] = profile['pH']['min'].toDouble();
        _alertSettings['pH']!['maxValue'] = profile['pH']['max'].toDouble();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied settings for ${profile['name']}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _saveAlertSettings() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF252525)
            : Colors.white,
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              'Saving settings...',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save alert settings for each nutrient
      for (final key in _alertSettings.keys) {
        await prefs.setBool(
            'alert_${key}_enabled', _alertSettings[key]!['enabled'] as bool);
        await prefs.setDouble('alert_${key}_minValue',
            _alertSettings[key]!['minValue'] as double);
        await prefs.setDouble('alert_${key}_maxValue',
            _alertSettings[key]!['maxValue'] as double);
      }

      // Save alert frequency
      await prefs.setString('alert_frequency', _alertFrequency);

      // Save alert history - convert DateTime to string for storage
      final historyList = _alertHistory.map((alert) {
        final alertCopy = Map<String, dynamic>.from(alert);
        alertCopy['timestamp'] =
            (alert['timestamp'] as DateTime).toIso8601String();
        return alertCopy;
      }).toList();

      await prefs.setString('alert_history', jsonEncode(historyList));

      // Close loading indicator
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addNewAlert(String type, double value, double threshold,
      bool isBelowThreshold) async {
    // Format the message based on whether value is below or above threshold
    final message = isBelowThreshold
        ? '$type levels below minimum threshold'
        : '$type levels above maximum threshold';

    // Create alert object
    final newAlert = {
      'timestamp': DateTime.now(),
      'type': type.toLowerCase(),
      'message': message,
      'value': value,
      'threshold': threshold,
    };

    // Add to history
    setState(() {
      _alertHistory.insert(
          0, newAlert); // Add to the beginning for chronological order

      // Limit history size (optional)
      if (_alertHistory.length > 100) {
        _alertHistory = _alertHistory.sublist(0, 100);
      }
    });

    // Save updated history
    final prefs = await SharedPreferences.getInstance();
    final historyList = _alertHistory.map((alert) {
      final alertCopy = Map<String, dynamic>.from(alert);
      alertCopy['timestamp'] =
          (alert['timestamp'] as DateTime).toIso8601String();
      return alertCopy;
    }).toList();

    await prefs.setString('alert_history', jsonEncode(historyList));
  }

  void checkCurrentReadings(NPKState npkState) {
    // Check each nutrient if alerts are enabled
    _checkNutrient('nitrogen', npkState.nitrogenData.value);
    _checkNutrient('phosphorus', npkState.phosphorusData.value);
    _checkNutrient('potassium', npkState.potassiumData.value);
    _checkNutrient('pH', npkState.pH);
    _checkNutrient('moisture', npkState.moisture);
  }

  void _checkNutrient(String key, double value) {
    if (!(_alertSettings.containsKey(key) &&
        _alertSettings[key]!['enabled'] as bool)) {
      return;
    }

    final minValue = _alertSettings[key]!['minValue'] as double;
    final maxValue = _alertSettings[key]!['maxValue'] as double;

    if (value < minValue) {
      addNewAlert(key, value, minValue, true);
    } else if (value > maxValue) {
      addNewAlert(key, value, maxValue, false);
    }
  }

  Future<void> clearAlertHistory() async {
    setState(() {
      _alertHistory.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alert_history', jsonEncode([]));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert history cleared'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  double _getMinValueForKey(String key) {
    switch (key) {
      case 'nitrogen':
      case 'phosphorus':
      case 'potassium':
        return 0.0;
      case 'pH':
        return 4.0;
      case 'moisture':
        return 0.0;
      default:
        return 0.0;
    }
  }

  double _getMaxValueForKey(String key) {
    switch (key) {
      case 'nitrogen':
      case 'phosphorus':
      case 'potassium':
        return 100.0;
      case 'pH':
        return 9.0;
      case 'moisture':
        return 100.0;
      default:
        return 100.0;
    }
  }

  int _getDivisionsForKey(String key) {
    switch (key) {
      case 'nitrogen':
      case 'phosphorus':
      case 'potassium':
        return 100;
      case 'pH':
        return 50;
      case 'moisture':
        return 100;
      default:
        return 100;
    }
  }

  bool _isInRange(String key, double value) {
    final minValue = _alertSettings[key]!['minValue'] as double;
    final maxValue = _alertSettings[key]!['maxValue'] as double;
    return value >= minValue && value <= maxValue;
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
