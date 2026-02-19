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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeFarmController();
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text("Please login first"),
            ),
          );
        }

        // 🔥 DEBUG PRINT (SAFE)
        print("Current UID: ${user.uid}");

        return _buildDashboard(context, user.uid, isMobile);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text("Auth Error: $error")),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, String userId, bool isMobile) {
    final farmState = ref.watch(farmControllerProvider(userId));

    if (farmState.isLoading && farmState.farms.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (farmState.error != null && farmState.farms.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text("Error: ${farmState.error}"),
        ),
      );
    }

    if (farmState.farms.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Hydro Smart Dashboard")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  "No Farms Found",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  "Explore these features while setting up your farm",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              _DashboardButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CropRecommendationPage(),
                    ),
                  );
                },
                icon: Icons.eco,
                title: "Crop Recommendation",
                subtitle: "Get AI recommendations based on conditions",
              ),
              const SizedBox(height: 12),
              _DashboardButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FinanceScreen(),
                    ),
                  );
                },
                icon: Icons.attach_money,
                title: "Bills & Finance",
                subtitle: "Track expenses and profitability",
              ),
              const SizedBox(height: 12),
              _DashboardButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MarketplaceScreen(),
                    ),
                  );
                },
                icon: Icons.shopping_cart,
                title: "Marketplace",
                subtitle: "Buy equipment, nutrients & seeds",
              ),
              const SizedBox(height: 12),
              _DashboardButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GrowthTrackerScreen(),
                    ),
                  );
                },
                icon: Icons.trending_up,
                title: "Growth Tracker",
                subtitle: "Monitor crop growth progress",
              ),
              const SizedBox(height: 12),
              _DashboardButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AIChatScreen(),
                    ),
                  );
                },
                icon: Icons.chat,
                title: "AI Assistant",
                subtitle: "Get help with farming questions",
              ),
              const SizedBox(height: 12),
              _DashboardButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubsidyScreen(),
                    ),
                  );
                },
                icon: Icons.account_balance,
                title: "Government Subsidies",
                subtitle: "Explore agricultural subsidy schemes",
              ),
            ],
          ),
        ),
      );
    }

    final selectedFarm = farmState.selectedFarm ?? farmState.farms.first;

    final sensorDataAsync =
        ref.watch(sensorDataStreamProvider(selectedFarm.deviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hydro Smart Dashboard"),
      ),
      body: sensorDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Sensor Error: $e")),
        data: (sensorData) {
          if (sensorData.isEmpty) {
            return const Center(
              child: Text("No Sensor Data"),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SensorCard(
                  title: "Temperature",
                  value: sensorData['temperature'] ?? 0,
                  unit: "°C",
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _SensorCard(
                  title: "Humidity",
                  value: sensorData['humidity'] ?? 0,
                  unit: "%",
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _SensorCard(
                  title: "pH Level",
                  value: sensorData['ph'] ?? 0,
                  unit: "",
                  color: Colors.purple,
                ),
                const SizedBox(height: 16),
                _SensorCard(
                  title: "Water Level",
                  value: sensorData['waterLevel'] ?? 0,
                  unit: "%",
                  color: Colors.cyan,
                ),
                const SizedBox(height: 32),
                Text(
                  "Quick Access",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _QuickAccessPanel(
                        icon: Icons.eco,
                        label: "Crops",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CropRecommendationPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _QuickAccessPanel(
                        icon: Icons.attach_money,
                        label: "Finance",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FinanceScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _QuickAccessPanel(
                        icon: Icons.shopping_cart,
                        label: "Shop",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MarketplaceScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _QuickAccessPanel(
                        icon: Icons.trending_up,
                        label: "Growth",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GrowthTrackerScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _QuickAccessPanel(
                        icon: Icons.chat,
                        label: "AI Help",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AIChatScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final Color color;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            "${value.toStringAsFixed(1)} $unit",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String title;
  final String subtitle;

  const _DashboardButton({
    required this.onPressed,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.green[700], size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessPanel extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessPanel({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green[700], size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
