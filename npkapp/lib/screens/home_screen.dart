import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:npkapp/models/nutrient_model.dart';
import 'package:npkapp/screens/alerts_screen.dart';
import 'package:npkapp/screens/history_screen.dart';
import 'package:npkapp/screens/settings_screen.dart';
import 'package:npkapp/utils/colors.dart';
import 'package:npkapp/widgets/circular_guide_widget.dart';
import 'package:npkapp/widgets/nutrient_chart.dart';
import 'package:npkapp/widgets/animated_gradient_background.dart';
import 'package:npkapp/state/npk_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    // Initial fetch not needed anymore since we're fetching periodically
    // The NPKState constructor starts the periodic fetching
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the state without listening
    final npkState = Provider.of<NPKState>(context, listen: false);

    // Move state changes to post-frame callback to avoid modifying state during build
    if (npkState.shouldResetAnimation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.reset();
        _animationController.forward();
        npkState.consumeAnimationReset();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use listen: false in build method and only listen in specific Consumers
    final npkState = Provider.of<NPKState>(context, listen: false);

    // In your build method, check for dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: _buildAnimatedTitle(isDarkMode),
        actions: [
          // New navigation icons in app bar
          IconButton(
            icon: const Icon(Icons.dashboard_rounded, color: AppColors.primary),
            tooltip: 'Dashboard',
            onPressed: () {
              // Already on dashboard
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded,
                color: AppColors.textSecondary),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Alerts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),

          // Existing refresh button
          Consumer<NPKState>(
            builder: (context, npkState, child) {
              return npkState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: 'Refresh',
                      onPressed: () {
                        // Use manual refresh which forces loading state
                        context.read<NPKState>().refreshData();
                      },
                    );
            },
          ),

          // Optional: settings button (if you want to keep it)
          IconButton(
            icon: const Icon(Icons.settings_rounded,
                color: AppColors.textPrimary),
            tooltip: 'Settings',
            onPressed: () {
              // Navigate to settings
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedGradientBackground(
        isDarkMode: isDarkMode, // Pass this to your animated background
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary section
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
                      )),
                      child: _buildSummarySection(),
                    ),

                    const SizedBox(height: 24),

                    // Gauges section
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                      )),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0)
                            .animate(CurvedAnimation(
                          parent: _animationController,
                          curve:
                              const Interval(0.2, 0.7, curve: Curves.easeOut),
                        )),
                        child: _buildGaugesSection(isDarkMode),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Trends section
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                      )),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0)
                            .animate(CurvedAnimation(
                          parent: _animationController,
                          curve:
                              const Interval(0.4, 0.9, curve: Curves.easeOut),
                        )),
                        child: _buildTrendsSection(isDarkMode),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recommendations section
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                      )),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0)
                            .animate(CurvedAnimation(
                          parent: _animationController,
                          curve:
                              const Interval(0.6, 1.0, curve: Curves.easeOut),
                        )),
                        child: _buildRecommendationsSection(isDarkMode),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      // Remove the bottom navigation bar
      // bottomNavigationBar: null,
    );
  }

  Widget _buildAnimatedTitle(bool isDarkMode) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Color(0xFF2E7D32), // Rich forest green
                Color(0xFF43A047), // Vibrant leaf green
                Color(0xFF00ACC1), // Teal blue (water/moisture)
                Color(0xFF1E88E5), // Bright blue (sky/freshness)
              ],
              stops: [0.1, 0.4, 0.7, 0.9],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(
              0,
              0,
              bounds.width * (0.5 + value * 0.5),
              bounds.height,
            ));
          },
          child: Row(
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    alignment: Alignment.centerLeft,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF43A047).withOpacity(0.2),
                        Color(0xFF00ACC1).withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2E7D32).withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color:
                        isDarkMode ? Colors.lightGreen[300] : Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NPK Sensor',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isDarkMode
                          ? Colors.white
                          : Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummarySection() {
    return Consumer<NPKState>(
      builder: (context, npkState, child) {
        // Fix: Create DateFormat instance correctly
        final dateFormat = DateFormat('HH:mm:ss');
        final updatedTime = dateFormat.format(npkState.lastUpdated);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soil Health',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      npkState.soilHealth,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                      'N',
                      npkState.nitrogenData.value.toInt().toString(),
                      npkState.nitrogenData.color),
                  _buildSummaryItem(
                      'P',
                      npkState.phosphorusData.value.toInt().toString(),
                      npkState.phosphorusData.color),
                  _buildSummaryItem(
                      'K',
                      npkState.potassiumData.value.toInt().toString(),
                      npkState.potassiumData.color),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Last updated: $updatedTime',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGaugesSection(bool isDarkMode) {
    return Consumer<NPKState>(
      builder: (context, npkState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time Readings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: CircularGaugeWidget(data: npkState.nitrogenData)),
                Expanded(
                    child: CircularGaugeWidget(data: npkState.phosphorusData)),
                Expanded(
                    child: CircularGaugeWidget(data: npkState.potassiumData)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendsSection(bool isDarkMode) {
    return Consumer<NPKState>(
      builder: (context, npkState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nutrient Trends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to detailed trends
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.timeline, size: 18),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDarkMode ? Colors.lightGreen[300] : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? Color(0xFF1E1E1E) : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: NutrientTrendChart(
                nitrogenData: npkState.nitrogenData,
                phosphorusData: npkState.phosphorusData,
                potassiumData: npkState.potassiumData,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationsSection(bool isDarkMode) {
    return Consumer<NPKState>(
      builder: (context, npkState, child) {
        final recommendations = npkState.getRecommendations();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? Color(0xFF1E1E1E) : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: recommendations.asMap().entries.map((entry) {
                  final recommendation = entry.value;
                  final isLast = entry.key == recommendations.length - 1;

                  return Column(
                    children: [
                      _buildRecommendationItem(
                        recommendation['title'],
                        recommendation['description'],
                        recommendation['color'],
                        recommendation['icon'],
                        isDarkMode,
                      ),
                      if (!isLast)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendationItem(String title, String description, Color color,
      IconData icon, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
