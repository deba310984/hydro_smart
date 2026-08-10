import 'package:flutter/material.dart';
import 'features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';
import 'features/dashboard/home_screen.dart';

class HydroSmartApp extends StatelessWidget {
  const HydroSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroSmart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: HomePage(),
      routes: {
        '/dashboard': (context) => const HomeScreen(),
        '/crops': (context) => const CropRecommendationPage(),
      },
    );
  }
}

/// Simple home page with navigation to crop panel
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HydroSmart'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Crop Recommendations Button
            ElevatedButton.icon(
              icon: const Icon(Icons.grass, size: 28),
              label: const Text(
                'Hydroponic Crops',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CropRecommendationPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),

            const SizedBox(height: 20),

            // Dashboard Button
            ElevatedButton.icon(
              icon: const Icon(Icons.dashboard, size: 28),
              label: const Text(
                'Dashboard',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),

            const SizedBox(height: 40),

            // Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌱 Crop Recommendation Panel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore 6 hydroponic crops with detailed information and advanced filtering by technique, season, duration, profit margin, difficulty, and market demand.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '✓ 6 sample crops with complete data\n'
                    '✓ 6 advanced filters\n'
                    '✓ Beautiful crop cards\n'
                    '✓ Real-time filtering\n'
                    '✓ Dark mode support',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative: If you want to add to existing dashboard
class DashboardWithCropButton extends StatelessWidget {
  const DashboardWithCropButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        children: [
          // Your existing dashboard items...

          // Add this:
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.grass, color: Colors.green),
                title: const Text('Hydroponic Crops'),
                subtitle: const Text('View & filter available crops'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CropRecommendationPage(),
                    ),
                  );
                },
              ),
            ),
          ),

          // ... rest of your dashboard
        ],
      ),
    );
  }
}
