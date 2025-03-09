import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:npkapp/models/nutrient_model.dart';
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
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    // Initial fetch of data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NPKState>().fetchData();
    });
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
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use listen: false in build method and only listen in specific Consumers
    final npkState = Provider.of<NPKState>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: _buildAnimatedTitle(),
        actions: [
          Consumer<NPKState>(
            builder: (context, npkState, child) {
              return npkState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () {
                        context.read<NPKState>().fetchData();
                      },
                    );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded,
                color: AppColors.textPrimary),
            onPressed: () {
              // Navigate to settings
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedGradientBackground(
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
                        child: _buildGaugesSection(),
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
                        child: _buildTrendsSection(),
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
                        child: _buildRecommendationsSection(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_rounded), text: 'Dashboard'),
                Tab(icon: Icon(Icons.history_rounded), text: 'History'),
                Tab(icon: Icon(Icons.notifications_rounded), text: 'Alerts'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
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
                        Color(0xFF43A047).withValues(alpha: 0.2),
                        Color(0xFF00ACC1).withValues(alpha: 0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF2E7D32).withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF2E7D32),
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
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
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
                    style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
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
                  _buildSummaryItem(
                      'pH', npkState.pH.toStringAsFixed(1), Colors.amber),
                  _buildSummaryItem('Moisture', '${npkState.moisture.toInt()}%',
                      Colors.lightBlue),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Last updated: $updatedTime',
                style: GoogleFonts.poppins(
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGaugesSection() {
    return Consumer<NPKState>(
      builder: (context, npkState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time Readings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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

  Widget _buildTrendsSection() {
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
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to detailed trends
                  },
                  icon: const Icon(Icons.timeline, size: 18),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildRecommendationsSection() {
    return Consumer<NPKState>(
      builder: (context, npkState, child) {
        final recommendations = npkState.getRecommendations();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildRecommendationItem(
      String title, String description, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
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
