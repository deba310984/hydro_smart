import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/features/sensors/sensor_provider.dart';
import 'package:hydro_smart/features/auth/auth_controller.dart';
import 'package:hydro_smart/features/farm/farm_controller.dart';
import 'package:hydro_smart/features/subsidy/subsidy_screen.dart';
import 'package:hydro_smart/features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';
import 'package:hydro_smart/features/finance/finance_screen.dart';
import 'package:hydro_smart/features/marketplace/marketplace_screen.dart';
import 'package:hydro_smart/features/growth/growth_screen.dart';
import 'package:hydro_smart/features/ai_chat/chat_screen.dart';
import 'package:hydro_smart/core/theme/krishi_theme.dart';
import 'package:hydro_smart/core/theme/krishi_components.dart';
import 'package:hydro_smart/core/theme/warli_painter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _currentLanguage = 'EN';

  @override
  void initState() {
    super.initState();
    _initializeFarmController();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeFarmController() {
    final authState = ref.read(authStateProvider);

    authState.whenData((user) {
      if (user != null) {
        Future.microtask(() {
          ref.read(farmControllerProvider(user.uid).notifier).loadFarms();
        });
      }
    });
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'EN' ? 'HI' : 'EN';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return _buildDemoModeContent(context, isMobile);
        }
        return _buildDashboard(context, user.uid, isMobile);
      },
      loading: () => Scaffold(
        backgroundColor: KrishiTheme.parchment,
        body: Center(
          child: CircularProgressIndicator(color: KrishiTheme.primaryGreen),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: KrishiTheme.parchment,
        body: Center(child: Text("Auth Error: $error")),
      ),
    );
  }

  Widget _buildDemoModeContent(BuildContext context, bool isMobile) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: KrishiTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Warli art background
              Positioned.fill(
                child: CustomPaint(
                  painter: WarliPainter(
                    pattern: WarliPattern.village,
                    opacity: 0.04,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                children: [
                  // Profile header
                  FarmerProfileHeader(
                    name: _currentLanguage == 'EN'
                        ? 'Welcome, Farmer'
                        : 'स्वागत है, किसान',
                    kisanId: null,
                    currentLanguage: _currentLanguage,
                    onLanguageToggle: _toggleLanguage,
                    onNotificationTap: () {},
                  ),
                  // Live Mandi Tracker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MandiTracker(
                      prices: [
                        const MandiPrice(
                            crop: 'Wheat', price: 2125, change: 2.3),
                        const MandiPrice(
                            crop: 'Rice', price: 1950, change: -0.8),
                        const MandiPrice(
                            crop: 'Tomato', price: 45, change: 5.2),
                        const MandiPrice(
                            crop: 'Potato', price: 22, change: 1.1),
                        const MandiPrice(
                            crop: 'Onion', price: 35, change: -2.5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Main content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: KrishiTheme.parchment,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Featured card - Soil Health
                                SoilHealthCard(
                                  ph: 6.8,
                                  nitrogen: 72,
                                  phosphorus: 58,
                                  potassium: 85,
                                  moisture: 48,
                                  lastUpdated: 'Today, 10:30 AM',
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _currentLanguage == 'EN'
                                      ? 'Explore Features'
                                      : 'सुविधाओं का अन्वेषण करें',
                                  style: KrishiTheme.headlineSmall.copyWith(
                                    color: KrishiTheme.deepSoil,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _currentLanguage == 'EN'
                                      ? 'Smart farming at your fingertips'
                                      : 'आपकी उंगलियों पर स्मार्ट खेती',
                                  style: KrishiTheme.bodyMedium.copyWith(
                                    color: KrishiTheme.monsoonSky,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildFeatureGrid(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.eco_rounded,
        title: _currentLanguage == 'EN' ? 'Crop Advisor' : 'फसल सलाहकार',
        subtitle:
            _currentLanguage == 'EN' ? 'AI recommendations' : 'AI अनुशंसाएं',
        color: KrishiTheme.primaryGreen,
        pattern: WarliPattern.crops,
        emoji: '🌱',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => CropRecommendationPage())),
      ),
      _FeatureItem(
        icon: Icons.account_balance_wallet_rounded,
        title: _currentLanguage == 'EN' ? 'Finance' : 'वित्त',
        subtitle:
            _currentLanguage == 'EN' ? 'Track expenses' : 'खर्च ट्रैक करें',
        color: KrishiTheme.terracotta,
        pattern: WarliPattern.village,
        emoji: '💰',
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FinanceScreen())),
      ),
      _FeatureItem(
        icon: Icons.store_rounded,
        title: _currentLanguage == 'EN' ? 'Marketplace' : 'बाज़ार',
        subtitle: _currentLanguage == 'EN' ? 'Buy equipment' : 'उपकरण खरीदें',
        color: KrishiTheme.goldenWheat,
        pattern: WarliPattern.farmer,
        emoji: '🛒',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
      ),
      _FeatureItem(
        icon: Icons.trending_up_rounded,
        title: _currentLanguage == 'EN' ? 'Growth' : 'विकास',
        subtitle:
            _currentLanguage == 'EN' ? 'Monitor progress' : 'प्रगति देखें',
        color: KrishiTheme.freshLime,
        pattern: WarliPattern.sun,
        emoji: '📈',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GrowthTrackerScreen())),
      ),
      _FeatureItem(
        icon: Icons.smart_toy_rounded,
        title: _currentLanguage == 'EN' ? 'AI Assistant' : 'AI सहायक',
        subtitle:
            _currentLanguage == 'EN' ? 'Get expert help' : 'विशेषज्ञ सहायता',
        color: KrishiTheme.earthBrown,
        pattern: WarliPattern.mandala,
        emoji: '🤖',
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
      ),
      _FeatureItem(
        icon: Icons.account_balance_rounded,
        title: _currentLanguage == 'EN' ? 'Subsidies' : 'सब्सिडी',
        subtitle: _currentLanguage == 'EN' ? 'Gov schemes' : 'सरकारी योजनाएं',
        color: KrishiTheme.deepSoil,
        pattern: WarliPattern.village,
        emoji: '🏛️',
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SubsidyScreen())),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final item = features[index];
        return KrishiFeatureCard(
          heroTag: 'feature_${item.title}',
          icon: item.icon,
          title: item.title,
          subtitle: item.subtitle,
          accentColor: item.color,
          warliPattern: item.pattern,
          emoji: item.emoji,
          onTap: item.onTap,
        );
      },
    );
  }

  Widget _buildDashboard(BuildContext context, String userId, bool isMobile) {
    final farmState = ref.watch(farmControllerProvider(userId));

    if (farmState.isLoading && farmState.farms.isEmpty) {
      return Scaffold(
        backgroundColor: KrishiTheme.parchment,
        body: Center(
            child: CircularProgressIndicator(color: KrishiTheme.primaryGreen)),
      );
    }

    if (farmState.error != null && farmState.farms.isEmpty) {
      return Scaffold(
        backgroundColor: KrishiTheme.parchment,
        body: Center(child: Text("Error: ${farmState.error}")),
      );
    }

    if (farmState.farms.isEmpty) {
      return _buildDemoModeContent(context, isMobile);
    }

    final selectedFarm = farmState.selectedFarm ?? farmState.farms.first;
    final sensorDataAsync =
        ref.watch(sensorDataStreamProvider(selectedFarm.deviceId));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: KrishiTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Warli background
              Positioned.fill(
                child: CustomPaint(
                  painter: WarliPainter(
                    pattern: WarliPattern.farmer,
                    opacity: 0.03,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                children: [
                  // Farmer Profile Header
                  FarmerProfileHeader(
                    name: selectedFarm.name,
                    kisanId:
                        'KID${selectedFarm.deviceId.substring(0, 8).toUpperCase()}',
                    currentLanguage: _currentLanguage,
                    onLanguageToggle: _toggleLanguage,
                    onNotificationTap: () {},
                  ),
                  // Mandi Tracker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MandiTracker(
                      prices: [
                        const MandiPrice(
                            crop: 'Wheat', price: 2125, change: 2.3),
                        const MandiPrice(
                            crop: 'Rice', price: 1950, change: -0.8),
                        const MandiPrice(
                            crop: 'Tomato', price: 45, change: 5.2),
                        const MandiPrice(
                            crop: 'Potato', price: 22, change: 1.1),
                        const MandiPrice(
                            crop: 'Onion', price: 35, change: -2.5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Main content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: KrishiTheme.parchment,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: sensorDataAsync.when(
                            loading: () => Center(
                                child: CircularProgressIndicator(
                                    color: KrishiTheme.primaryGreen)),
                            error: (e, _) =>
                                Center(child: Text("Sensor Error: $e")),
                            data: (sensorData) {
                              if (sensorData.isEmpty) {
                                return Center(
                                  child: Text(
                                    _currentLanguage == 'EN'
                                        ? "No Sensor Data"
                                        : "कोई सेंसर डेटा नहीं",
                                    style: KrishiTheme.bodyLarge,
                                  ),
                                );
                              }
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Soil Health Card
                                    SoilHealthCard(
                                      ph: (sensorData['ph'] ?? 6.5).toDouble(),
                                      nitrogen: 72,
                                      phosphorus: 58,
                                      potassium: 85,
                                      moisture: (sensorData['humidity'] ?? 45)
                                          .toDouble(),
                                      lastUpdated: 'Live',
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _currentLanguage == 'EN'
                                          ? 'Sensor Readings'
                                          : 'सेंसर रीडिंग',
                                      style: KrishiTheme.headlineSmall.copyWith(
                                        color: KrishiTheme.deepSoil,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSensorGrid(sensorData),
                                    const SizedBox(height: 28),
                                    Text(
                                      _currentLanguage == 'EN'
                                          ? 'Quick Access'
                                          : 'त्वरित पहुँच',
                                      style: KrishiTheme.titleLarge.copyWith(
                                        color: KrishiTheme.deepSoil,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildQuickAccessRow(context),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorGrid(Map<String, dynamic> sensorData) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _SensorCard(
          title: _currentLanguage == 'EN' ? 'Temperature' : 'तापमान',
          value: sensorData['temperature'] ?? 0,
          unit: '°C',
          icon: Icons.thermostat_rounded,
          color: KrishiTheme.terracotta,
        ),
        _SensorCard(
          title: _currentLanguage == 'EN' ? 'Humidity' : 'नमी',
          value: sensorData['humidity'] ?? 0,
          unit: '%',
          icon: Icons.water_drop_rounded,
          color: KrishiTheme.primaryGreen,
        ),
        _SensorCard(
          title: _currentLanguage == 'EN' ? 'pH Level' : 'पीएच स्तर',
          value: sensorData['ph'] ?? 0,
          unit: '',
          icon: Icons.science_rounded,
          color: KrishiTheme.freshLime,
        ),
        _SensorCard(
          title: _currentLanguage == 'EN' ? 'Water Level' : 'जल स्तर',
          value: sensorData['waterLevel'] ?? 0,
          unit: '%',
          icon: Icons.waves_rounded,
          color: KrishiTheme.goldenWheat,
        ),
      ],
    );
  }

  Widget _buildQuickAccessRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickAccessPanel(
            icon: Icons.eco_rounded,
            label: _currentLanguage == 'EN' ? 'Crops' : 'फसलें',
            color: KrishiTheme.primaryGreen,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => CropRecommendationPage())),
          ),
          const SizedBox(width: 14),
          _QuickAccessPanel(
            icon: Icons.account_balance_wallet_rounded,
            label: _currentLanguage == 'EN' ? 'Finance' : 'वित्त',
            color: KrishiTheme.terracotta,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FinanceScreen())),
          ),
          const SizedBox(width: 14),
          _QuickAccessPanel(
            icon: Icons.store_rounded,
            label: _currentLanguage == 'EN' ? 'Shop' : 'दुकान',
            color: KrishiTheme.goldenWheat,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
          ),
          const SizedBox(width: 14),
          _QuickAccessPanel(
            icon: Icons.trending_up_rounded,
            label: _currentLanguage == 'EN' ? 'Growth' : 'विकास',
            color: KrishiTheme.freshLime,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GrowthTrackerScreen())),
          ),
          const SizedBox(width: 14),
          _QuickAccessPanel(
            icon: Icons.smart_toy_rounded,
            label: _currentLanguage == 'EN' ? 'AI Help' : 'AI सहायता',
            color: KrishiTheme.earthBrown,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AIChatScreen())),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final WarliPattern pattern;
  final String emoji;
  final VoidCallback onTap;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.pattern,
    required this.emoji,
    required this.onTap,
  });
}

class _SensorCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KrishiTheme.radiusMedium),
        boxShadow: KrishiTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Icon(Icons.north_east_rounded,
                  color: KrishiTheme.freshLime, size: 16),
            ],
          ),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: KrishiTheme.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style:
                KrishiTheme.bodySmall.copyWith(color: KrishiTheme.monsoonSky),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessPanel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessPanel({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          KrishiTheme.lightHaptic();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 80,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: KrishiTheme.labelStyle.copyWith(
                  color: KrishiTheme.deepSoil,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
