import 'package:flutter/material.dart';
import 'package:npkapp/state/theme_provider.dart';
import 'package:npkapp/utils/colors.dart';
import 'package:npkapp/state/npk_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // App settings
  bool _darkMode = false;
  bool _pushNotifications = true;

  String _refreshRate = '0.5 seconds';

  // Sensor settings
  bool _autoCalibration = true;
  String _sensorMode = 'Standard';

  // Default refresh rate options
  final List<String> _refreshRateOptions = [
    '0.5 seconds',
    '1 second',
    '5 seconds',
    '10 seconds',
    '30 seconds',
    '1 minute'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Get the current dark mode state from ThemeProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      setState(() {
        _darkMode = themeProvider.isDarkMode;
      });
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Load saved settings or use defaults
      _darkMode = prefs.getBool('darkMode') ?? false;
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _refreshRate = prefs.getString('refreshRate') ?? '0.5 seconds';
      _autoCalibration = prefs.getBool('autoCalibration') ?? true;
      _sensorMode = prefs.getString('sensorMode') ?? 'Standard';
    });
  }

  @override
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Apply refresh rate before saving
    _applyRefreshRateChange(_refreshRate);

    // Save all settings
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('pushNotifications', _pushNotifications);
    await prefs.setString('refreshRate', _refreshRate);
    await prefs.setBool('autoCalibration', _autoCalibration);
    await prefs.setString('sensorMode', _sensorMode);

    // Apply dark mode
    Provider.of<ThemeProvider>(context, listen: false).setDarkMode(_darkMode);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppearanceSection(),
          const SizedBox(height: 24),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildSensorSection(),
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save),
        label: const Text('Save'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Display', Icons.palette_outlined),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(),
                  ),
                  subtitle: Text(
                    'Use dark theme throughout the app',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  value: _darkMode,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    // Apply immediately for better UX
                    Provider.of<ThemeProvider>(context, listen: false)
                        .setDarkMode(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Data Management', Icons.storage_outlined),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Refresh Rate',
                    style: TextStyle(),
                  ),
                  subtitle: Text(
                    'How often to fetch new sensor data',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: _refreshRate,
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _refreshRate = newValue;
                        });
                      }
                    },
                    items: _refreshRateOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    'Push Notifications',
                    style: TextStyle(),
                  ),
                  subtitle: Text(
                    'Receive alerts when nutrient levels change',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  value: _pushNotifications,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    'Clear Historical Data',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'Delete all saved NPK readings and history',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onTap: () {
                    _showClearDataConfirmationDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSensorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sensor Settings', Icons.sensors_outlined),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Auto Calibration',
                    style: TextStyle(),
                  ),
                  subtitle: Text(
                    'Automatically calibrate sensor on startup',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  value: _autoCalibration,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _autoCalibration = value;
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    'Sensor Mode',
                    style: TextStyle(),
                  ),
                  subtitle: Text(
                    'Select operating mode for the NPK sensor',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: _sensorMode,
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _sensorMode = newValue;
                        });
                      }
                    },
                    items: <String>['Standard', 'High Precision', 'Power Save']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    'Calibrate Sensor',
                    style: TextStyle(),
                  ),
                  subtitle: Text(
                    'Run manual calibration process',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    // Show calibration dialog or navigate to calibration screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Calibration process would start here'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About', Icons.info_outline),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Version',
                    style: TextStyle(),
                  ),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    'Help & Support',
                    style: TextStyle(),
                  ),
                  subtitle: Text(
                    'Contact the developer for assistance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    _showHelpAndSupportDialog();
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    'Privacy Policy',
                    style: TextStyle(),
                  ),
                  subtitle: Text(
                    'View app privacy and usage terms',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    _showPrivacyPolicyDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showClearDataConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Data',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will permanently delete all historical NPK readings and reset app data. This action cannot be undone.',
          style: TextStyle(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Clear Data',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Clearing data...'),
            ],
          ),
        ),
      );

      // Clear data from Provider state
      await Provider.of<NPKState>(context, listen: false).clearHistoricalData();

      // Clear SharedPreferences except for the settings we just changed
      final prefs = await SharedPreferences.getInstance();
      final tempSettings = {
        'darkMode': _darkMode,
        'pushNotifications': _pushNotifications,
        'refreshRate': _refreshRate,
        'autoCalibration': _autoCalibration,
        'sensorMode': _sensorMode,
      };

      // Clear all preferences
      await prefs.clear();

      // Restore current settings
      for (var entry in tempSettings.entries) {
        if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value as bool);
        } else if (entry.value is String) {
          await prefs.setString(entry.key, entry.value as String);
        }
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All historical data has been cleared'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this method at the end of _SettingsScreenState class

  // Apply refresh rate change to NPKState
  void _applyRefreshRateChange(String refreshRate) {
    final npkState = Provider.of<NPKState>(context, listen: false);

    // Convert string refresh rate to milliseconds
    int milliseconds;
    switch (refreshRate) {
      case '0.5 seconds':
        milliseconds = 500;
        break;
      case '1 second':
        milliseconds = 1000;
        break;
      case '5 seconds':
        milliseconds = 5000;
        break;
      case '10 seconds':
        milliseconds = 10000;
        break;
      case '30 seconds':
        milliseconds = 30000;
        break;
      case '1 minute':
        milliseconds = 60000;
        break;
      default:
        milliseconds = 1000;
    }

    // Update the refresh rate in NPKState
    npkState.updateRefreshRate(milliseconds);
  }

  void _showHelpAndSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For any issues, questions, or feedback, please contact:',
              style: TextStyle(),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email, color: AppColors.primary),
              title: Text('Email'),
              subtitle: Text('vinaychandra166@gmail.com'),
              contentPadding: EdgeInsets.zero,
              dense: true,
              onTap: () {
                // Implement email launch functionality if needed
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email address copied to clipboard'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.phone, color: AppColors.primary),
              title: Text('Phone'),
              subtitle: Text('7996336041'),
              contentPadding: EdgeInsets.zero,
              dense: true,
              onTap: () {
                // Implement phone call functionality if needed
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone number copied to clipboard'),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy Policy & Terms',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Proprietary Software License',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This NPK Soil Sensor application is closed-source proprietary software. All rights reserved.',
                style: TextStyle(),
              ),
              const SizedBox(height: 16),
              Text(
                'Usage Terms:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• The software is provided as-is without warranties of any kind.',
                style: TextStyle(),
              ),
              Text(
                '• Unauthorized copying, modification, distribution, or reverse engineering of this application is strictly prohibited.',
                style: TextStyle(),
              ),
              Text(
                '• This application may collect anonymized usage data to improve functionality.',
                style: TextStyle(),
              ),
              const SizedBox(height: 16),
              Text(
                'Data Collection:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This application stores NPK sensor readings locally on your device. No personal data is transmitted to external servers unless explicitly enabled by the user for cloud backup features.',
                style: TextStyle(),
              ),
              const SizedBox(height: 16),
              Text(
                'Intellectual Property:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'All intellectual property rights including algorithms, user interface design, and functionality are owned exclusively by the developer and protected under copyright law.',
                style: TextStyle(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
